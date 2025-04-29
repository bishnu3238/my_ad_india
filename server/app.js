const express = require('express');
const http = require('http');
const socketIO = require('socket.io');
const mysql = require('mysql2/promise');
const cors = require('cors');
const dotenv = require('dotenv');
const path = require('path');
const multer = require('multer');
const fs = require('fs');




// Load environment variables
dotenv.config();

// Initialize Express app
const app = express();
const server = http.createServer(app);
const io = socketIO(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
});

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Create uploads directory if it doesn't exist
const uploadDir = process.env.UPLOAD_DIR || './uploads';
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}
app.use('/uploads', express.static(path.join(__dirname, uploadDir)));

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const dir = `${uploadDir}/chat`;
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    cb(null, dir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  }
});
const upload = multer({ storage: storage });

// Database connection pool
const pool = mysql.createPool({
  host: process.env.MYSQL_HOST || 'localhost',
  user: process.env.MYSQL_USER || 'root',
  password: process.env.MYSQL_PASSWORD || '',
  database: process.env.MYSQL_DATABASE || 'ead',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Test database connection
async function testDBConnection() {
  try {
    const connection = await pool.getConnection();
    console.log('Database connection successful');
    connection.release();
  } catch (error) {
    console.error('Database connection failed:', error);
    process.exit(1);
  }
}

testDBConnection();

// Socket.IO connection handling
io.on('connection', (socket) => {
  console.log('New client connected:', socket.id);
  
  // User authentication and status update
  socket.on('authenticate', async (data) => {
    try {
      const { userType, userId } = data;
      
      // Update user status to online
      await updateUserStatus(userType, userId, true, socket.id);
      
      // Join user to their personal room
      socket.join(`${userType}_${userId}`);
      
      console.log(`User authenticated: ${userType} ${userId}`);
      
      // Notify user's contacts that they're online
      io.emit('user_status_changed', { userType, userId, isOnline: true });
      
      // Send acknowledgment back to client
      socket.emit('authenticated', { success: true });
    } catch (error) {
      console.error('Authentication error:', error);
      socket.emit('authenticated', { success: false, error: error.message });
    }
  });
  
  // Handle new message
  socket.on('send_message', async (data) => {
    try {
      const { conversationId, senderType, senderId, receiverType, receiverId, message, messageType, fileUrl } = data;
      
      // If conversation doesn't exist, create it
      let convoId = conversationId;
      if (!convoId) {
        const customerId = senderType === 'customer' ? senderId : receiverId;
        const merchantId = senderType === 'merchant' ? senderId : receiverId;
        convoId = await getOrCreateConversation(customerId, merchantId);
      }
      
      // Save message to database
      const msgId = await saveMessage(convoId, senderType, senderId, message, messageType, fileUrl);
      
      // Update conversation with last message
      await updateConversationLastMessage(convoId, message);
      
      // Get sender details
      let senderName, senderImage;
      if (senderType === 'customer') {
        const [rows] = await pool.execute('SELECT username, image FROM customers WHERE id = ?', [senderId]);
        if (rows.length > 0) {
          senderName = rows[0].username;
          senderImage = rows[0].image;
        }
      } else {
        const [rows] = await pool.execute('SELECT username, company_logo FROM merchant WHERE id = ?', [senderId]);
        if (rows.length > 0) {
          senderName = rows[0].username;
          senderImage = rows[0].company_logo;
        }
      }
      
      // Prepare message data to send
      const messageData = {
        id: msgId,
        conversation_id: convoId,
        sender_type: senderType,
        sender_id: senderId,
        message,
        message_type: messageType,
        file_url: fileUrl,
        is_read: false,
        created_at: new Date().toISOString(),
        sender_name: senderName || 'Unknown',
        sender_image: senderImage || ''
      };
      
      // Send to sender's room (for multi-device support)
      socket.to(`${senderType}_${senderId}`).emit('new_message', messageData);
      
      // Send to receiver's room
      socket.to(`${receiverType}_${receiverId}`).emit('new_message', messageData);
      
      // Send acknowledgment back to sender
      socket.emit('message_sent', { success: true, messageId: msgId });
      socket.emit('new_message', messageData);
    } catch (error) {
      console.error('Send message error:', error);
      socket.emit('message_sent', { success: false, error: error.message });
    }
  });
  
  // Handle message read status
  socket.on('mark_as_read', async (data) => {
    try {
      const { conversationId, userType, userId } = data;
      
      // Update messages as read
      await markMessagesAsRead(conversationId, userType, userId);
      
      // Get the other user in the conversation
      const [rows] = await pool.execute(
        'SELECT customer_id, merchant_id FROM conversations WHERE id = ?',
        [conversationId]
      );
      
      if (rows.length > 0) {
        const { customer_id, merchant_id } = rows[0];
        const otherType = userType === 'customer' ? 'merchant' : 'customer';
        const otherId = userType === 'customer' ? merchant_id : customer_id;
        
        // Notify the other user that messages were read
        io.to(`${otherType}_${otherId}`).emit('messages_read', {
          conversationId,
          readByType: userType,
          readById: userId
        });
      }
      
      socket.emit('mark_read_success', { success: true });
    } catch (error) {
      console.error('Mark as read error:', error);
      socket.emit('mark_read_success', { success: false, error: error.message });
    }
  });
  
  // Handle typing indicator
  socket.on('typing', (data) => {
    const { conversationId, userType, userId, receiverType, receiverId } = data;
    
    // Emit typing event to the other user
    socket.to(`${receiverType}_${receiverId}`).emit('user_typing', {
      conversationId,
      userType,
      userId
    });
  });
  
  // Handle call initiation
  socket.on('initiate_call', async (data) => {
    try {
      const { conversationId, callerType, callerId, receiverType, receiverId, callType } = data;
      
      // Save call log to database
      const callId = await saveCallLog(conversationId, callerType, callerId, receiverType, receiverId, callType);
      
      // Get caller details
      let callerName, callerImage;
      if (callerType === 'customer') {
        const [rows] = await pool.execute('SELECT username, image FROM customers WHERE id = ?', [callerId]);
        if (rows.length > 0) {
          callerName = rows[0].username;
          callerImage = rows[0].image;
        }
      } else {
        const [rows] = await pool.execute('SELECT username, company_logo FROM merchant WHERE id = ?', [callerId]);
        if (rows.length > 0) {
          callerName = rows[0].username;
          callerImage = rows[0].company_logo;
        }
      }
      
      // Prepare call data
      const callData = {
        callId,
        conversationId,
        callerType,
        callerId,
        callType,
        callerName,
        callerImage,
        timestamp: new Date().toISOString()
      };
      
      // Send to receiver's room
      socket.to(`${receiverType}_${receiverId}`).emit('incoming_call', callData);
      
      // Send acknowledgment back to caller
      socket.emit('call_initiated', { success: true, callId });
    } catch (error) {
      console.error('Call initiation error:', error);
      socket.emit('call_initiated', { success: false, error: error.message });
    }
  });
  
  // Handle call response (answer/reject)
  socket.on('call_response', async (data) => {
    try {
      const { callId, response, receiverType, receiverId, callerType, callerId } = data;
      
      // Update call log status
      await updateCallStatus(callId, response);
      
      // Send response to caller
      socket.to(`${callerType}_${callerId}`).emit('call_response', {
        callId,
        response,
        receiverType,
        receiverId
      });
      
      socket.emit('response_sent', { success: true });
    } catch (error) {
      console.error('Call response error:', error);
      socket.emit('response_sent', { success: false, error: error.message });
    }
  });
  
  // Handle call end
  socket.on('end_call', async (data) => {
    try {
      const { callId, endedByType, endedById, otherType, otherId } = data;
      
      // Update call log with end time
      await endCallLog(callId);
      
      // Notify the other user
      socket.to(`${otherType}_${otherId}`).emit('call_ended', {
        callId,
        endedByType,
        endedById
      });
      
      socket.emit('call_end_success', { success: true });
    } catch (error) {
      console.error('End call error:', error);
      socket.emit('call_end_success', { success: false, error: error.message });
    }
  });
  
  // Handle inquiry submission
  socket.on('submit_inquiry', async (data) => {
    try {
      const { conversationId, customerId, merchantId, inquiryText } = data;
      
      // Save inquiry to database
      const inquiryId = await saveInquiry(conversationId, customerId, merchantId, inquiryText);
      
      // Also save as a message
      await saveMessage(conversationId, 'customer', customerId, inquiryText, 'inquiry');
      
      // Update conversation with last message
      await updateConversationLastMessage(conversationId, inquiryText);
      
      // Get customer details
      const [rows] = await pool.execute('SELECT username, image FROM customers WHERE id = ?', [customerId]);
      let customerName = 'Unknown';
      let customerImage = '';
      
      if (rows.length > 0) {
        customerName = rows[0].username;
        customerImage = rows[0].image;
      }
      
      // Notify merchant about new inquiry
      socket.to(`merchant_${merchantId}`).emit('new_inquiry', {
        inquiryId,
        conversationId,
        customerId,
        inquiryText,
        customerName,
        customerImage,
        createdAt: new Date().toISOString()
      });
      
      socket.emit('inquiry_submitted', { success: true, inquiryId });
    } catch (error) {
      console.error('Inquiry submission error:', error);
      socket.emit('inquiry_submitted', { success: false, error: error.message });
    }
  });
  
  // Handle disconnection
  socket.on('disconnect', async () => {
    try {
      // Find user by socket ID and update status
      const [rows] = await pool.execute(
        'SELECT user_type, user_id FROM user_status WHERE socket_id = ?',
        [socket.id]
      );
      
      if (rows.length > 0) {
        const { user_type, user_id } = rows[0];
        
        // Update user status to offline
        await updateUserStatus(user_type, user_id, false, null);
        
        // Notify contacts that user is offline
        io.emit('user_status_changed', {
          userType: user_type,
          userId: user_id,
          isOnline: false
        });
        
        console.log(`User disconnected: ${user_type} ${user_id}`);
      }
      
      console.log('Client disconnected:', socket.id);
    } catch (error) {
      console.error('Disconnect error:', error);
    }
  });
});

// Database helper functions
async function updateUserStatus(userType, userId, isOnline, socketId) {
  try {
    await pool.execute(
      `INSERT INTO user_status (user_type, user_id, is_online, socket_id, last_active) 
       VALUES (?, ?, ?, ?, NOW()) 
       ON DUPLICATE KEY UPDATE 
       is_online = ?, socket_id = ?, last_active = NOW()`,
      [userType, userId, isOnline, socketId, isOnline, socketId]
    );
    return true;
  } catch (error) {
    console.error('Error updating user status:', error);
    throw error;
  }
}

// Improved getOrCreateConversation function
async function getOrCreateConversation(customerId, merchantId) {
  try {
    // Convert IDs to integers to ensure type consistency
    const customerIdInt = parseInt(customerId, 10);
    const merchantIdInt = parseInt(merchantId, 10);
    
    if (isNaN(customerIdInt) || isNaN(merchantIdInt)) {
      throw new Error('Invalid customer or merchant ID');
    }
    
    // First verify that both customer and merchant exist
    const [customerRows] = await pool.execute(
      'SELECT id FROM customers WHERE id = ?',
      [customerIdInt]
    );
    
    if (customerRows.length === 0) {
      throw new Error(`Customer with ID ${customerIdInt} does not exist`);
    }
    
    const [merchantRows] = await pool.execute(
      'SELECT id FROM merchant WHERE id = ?',
      [merchantIdInt]
    );
    
    if (merchantRows.length === 0) {
      throw new Error(`Merchant with ID ${merchantIdInt} does not exist`);
    }
    
    // Check if conversation exists
    const [rows] = await pool.execute(
      'SELECT id FROM conversations WHERE customer_id = ? AND merchant_id = ?',
      [customerIdInt, merchantIdInt]
    );
    
    if (rows.length > 0) {
      return rows[0].id;
    }
    
    // Create new conversation
    const [result] = await pool.execute(
      'INSERT INTO conversations (customer_id, merchant_id) VALUES (?, ?)',
      [customerIdInt, merchantIdInt]
    );
    
    return result.insertId;
  } catch (error) {
    console.error('Error getting/creating conversation:', error);
    throw error;
  }
}

async function saveMessage(conversationId, senderType, senderId, message, messageType = 'text', fileUrl = null) {
  try {
    const [result] = await pool.execute(
      `INSERT INTO messages 
       (conversation_id, sender_type, sender_id, message, message_type, file_url) 
       VALUES (?, ?, ?, ?, ?, ?)`,
      [conversationId, senderType, senderId, message, messageType, fileUrl]
    );
    
    return result.insertId;
  } catch (error) {
    console.error('Error saving message:', error);
    throw error;
  }
}

async function updateConversationLastMessage(conversationId, lastMessage) {
  try {
    await pool.execute(
      `UPDATE conversations 
       SET last_message = ?, last_message_time = NOW(), updated_at = NOW() 
       WHERE id = ?`,
      [lastMessage, conversationId]
    );
    return true;
  } catch (error) {
    console.error('Error updating conversation:', error);
    throw error;
  }
}

async function markMessagesAsRead(conversationId, userType, userId) {
  try {
    // Mark messages as read where the sender is not the current user
    await pool.execute(
      `UPDATE messages 
       SET is_read = TRUE 
       WHERE conversation_id = ? AND sender_type != ? AND sender_id != ?`,
      [conversationId, userType, userId]
    );
    return true;
  } catch (error) {
    console.error('Error marking messages as read:', error);
    throw error;
  }
}

async function saveCallLog(conversationId, callerType, callerId, receiverType, receiverId, callType) {
  try {
    const [result] = await pool.execute(
      `INSERT INTO call_logs 
       (conversation_id, caller_type, caller_id, receiver_type, receiver_id, call_type, status) 
       VALUES (?, ?, ?, ?, ?, ?, 'ongoing')`,
      [conversationId, callerType, callerId, receiverType, receiverId, callType]
    );
    
    return result.insertId;
  } catch (error) {
    console.error('Error saving call log:', error);
    throw error;
  }
}

async function updateCallStatus(callId, status) {
  try {
    await pool.execute(
      `UPDATE call_logs 
       SET status = ?, start_time = CASE WHEN ? = 'answered' THEN NOW() ELSE NULL END 
       WHERE id = ?`,
      [status, status, callId]
    );
    return true;
  } catch (error) {
    console.error('Error updating call status:', error);
    throw error;
  }
}

async function endCallLog(callId) {
  try {
    await pool.execute(
      `UPDATE call_logs 
       SET end_time = NOW(), status = CASE WHEN status = 'ongoing' THEN 'answered' ELSE status END 
       WHERE id = ?`,
      [callId]
    );
    return true;
  } catch (error) {
    console.error('Error ending call log:', error);
    throw error;
  }
}

async function saveInquiry(conversationId, customerId, merchantId, inquiryText) {
  try {
    const [result] = await pool.execute(
      `INSERT INTO inquiries 
       (conversation_id, customer_id, merchant_id, inquiry_text) 
       VALUES (?, ?, ?, ?)`,
      [conversationId, customerId, merchantId, inquiryText]
    );
    
    return result.insertId;
  } catch (error) {
    console.error('Error saving inquiry:', error);
    throw error;
  }
}

// API Routes
// Get conversations for a user
app.get('/api/conversations/:userType/:userId', async (req, res) => {
  try {
    const { userType, userId } = req.params;
    
    let query;
    let params;
    
    if (userType === 'customer') {
      query = `
        SELECT c.*, 
               m.username as merchant_name, m.company_name, m.company_logo as merchant_image,
               (SELECT COUNT(*) FROM messages WHERE conversation_id = c.id AND sender_type != ? AND sender_id != ? AND is_read = FALSE) as unread_count
        FROM conversations c
        JOIN merchant m ON c.merchant_id = m.id
        WHERE c.customer_id = ?
        ORDER BY c.updated_at DESC
      `;
      params = [userType, userId, userId];
    } else {
      query = `
        SELECT c.*, 
               cu.username as customer_name, cu.image as customer_image,
               (SELECT COUNT(*) FROM messages WHERE conversation_id = c.id AND sender_type != ? AND sender_id != ? AND is_read = FALSE) as unread_count
        FROM conversations c
        JOIN customers cu ON c.customer_id = cu.id
        WHERE c.merchant_id = ?
        ORDER BY c.updated_at DESC
      `;
      params = [userType, userId, userId];
    }
    
    const [rows] = await pool.execute(query, params);
    
    res.json({ success: true, conversations: rows });
  } catch (error) {
    console.error('Error fetching conversations:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get messages for a conversation
app.get('/api/messages/:conversationId', async (req, res) => {
  try {
    const { conversationId } = req.params;
    const { page = 1, limit = 50 } = req.query;
    
    const offset = (page - 1) * limit;
    
    const query = `
      SELECT m.*, 
             CASE 
               WHEN m.sender_type = 'customer' THEN c.username
               ELSE me.username
             END as sender_name,
             CASE 
               WHEN m.sender_type = 'customer' THEN c.image
               ELSE me.company_logo
             END as sender_image
      FROM messages m
      LEFT JOIN customers c ON m.sender_type = 'customer' AND m.sender_id = c.id
      LEFT JOIN merchant me ON m.sender_type = 'merchant' AND m.sender_id = me.id
      WHERE m.conversation_id = ?
      ORDER BY m.created_at DESC
      LIMIT ? OFFSET ?
    `;
    
    const [rows] = await pool.execute(query, [conversationId, parseInt(limit), parseInt(offset)]);
    
    res.json({ success: true, messages: rows.reverse() });
  } catch (error) {
    console.error('Error fetching messages:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Create a new conversation
app.post('/api/conversations', async (req, res) => {
  try {
    const { customerId, merchantId } = req.body;
    
    if (!customerId || !merchantId) {
      return res.status(400).json({ success: false, error: 'Customer ID and Merchant ID are required' });
    }
    
    try {
      const conversationId = await getOrCreateConversation(customerId, merchantId);
      res.json({ success: true, conversationId });
    } catch (error) {
      // Provide more specific error messages
      if (error.message.includes('does not exist')) {
        return res.status(404).json({ success: false, error: error.message });
      } else if (error.code === 'ER_NO_REFERENCED_ROW_2') {
        return res.status(404).json({ 
          success: false, 
          error: 'The customer or merchant ID does not exist in the database' 
        });
      } else {
        return res.status(500).json({ success: false, error: error.message });
      }
    }
  } catch (error) {
    console.error('Error creating conversation:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Upload file for chat
app.post('/api/upload', upload.single('file'), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, error: 'No file uploaded' });
    }
    
    const fileUrl = `${req.protocol}://${req.get('host')}/uploads/chat/${req.file.filename}`;
    
    res.json({
      success: true,
      fileUrl,
      fileName: req.file.originalname,
      fileType: req.file.mimetype
    });
  } catch (error) {
    console.error('File upload error:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get inquiries for a merchant
app.get('/api/inquiries/merchant/:merchantId', async (req, res) => {
  try {
    const { merchantId } = req.params;
    const { status = 'pending' } = req.query;
    
    const query = `
      SELECT i.*, c.username as customer_name, c.image as customer_image
      FROM inquiries i
      JOIN customers c ON i.customer_id = c.id
      WHERE i.merchant_id = ? AND i.status = ?
      ORDER BY i.created_at DESC
    `;
    
    const [rows] = await pool.execute(query, [merchantId, status]);
    
    res.json({ success: true, inquiries: rows });
  } catch (error) {
    console.error('Error fetching inquiries:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Update inquiry status
app.put('/api/inquiries/:inquiryId', async (req, res) => {
  try {
    const { inquiryId } = req.params;
    const { status } = req.body;
    
    await pool.execute(
      'UPDATE inquiries SET status = ? WHERE id = ?',
      [status, inquiryId]
    );
    
    res.json({ success: true });
  } catch (error) {
    console.error('Error updating inquiry:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get call history
app.get('/api/calls/:userType/:userId', async (req, res) => {
  try {
    const { userType, userId } = req.params;
    
    let query;
    let params;
    
    if (userType === 'customer') {
      query = `
        SELECT cl.*, 
               m.username as other_name, m.company_logo as other_image,
               CASE 
                 WHEN cl.caller_type = ? AND cl.caller_id = ? THEN 'outgoing'
                 ELSE 'incoming'
               END as call_direction
        FROM call_logs cl
        JOIN conversations c ON cl.conversation_id = c.id
        JOIN merchant m ON (cl.caller_type = 'merchant' AND cl.caller_id = m.id) OR (cl.receiver_type = 'merchant' AND cl.receiver_id = m.id)
        WHERE (cl.caller_type = ? AND cl.caller_id = ?) OR (cl.receiver_type = ? AND cl.receiver_id = ?)
        ORDER BY cl.created_at DESC
      `;
      params = [userType, userId, userType, userId, userType, userId];
    } else {
      query = `
        SELECT cl.*, 
               cu.username as other_name, cu.image as other_image,
               CASE 
                 WHEN cl.caller_type = ? AND cl.caller_id = ? THEN 'outgoing'
                 ELSE 'incoming'
               END as call_direction
        FROM call_logs cl
        JOIN conversations c ON cl.conversation_id = c.id
        JOIN customers cu ON (cl.caller_type = 'customer' AND cl.caller_id = cu.id) OR (cl.receiver_type = 'customer' AND cl.receiver_id = cu.id)
        WHERE (cl.caller_type = ? AND cl.caller_id = ?) OR (cl.receiver_type = ? AND cl.receiver_id = ?)
        ORDER BY cl.created_at DESC
      `;
      params = [userType, userId, userType, userId, userType, userId];
    }
    
    const [rows] = await pool.execute(query, params);
    
    res.json({ success: true, calls: rows });
  } catch (error) {
    console.error('Error fetching call history:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Start server
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});