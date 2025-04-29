const mysql = require('mysql2/promise');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

async function addTestMerchant() {
  // Create database connection
  const pool = mysql.createPool({
    host: process.env.MYSQL_HOST || 'localhost',
    user: process.env.MYSQL_USER || 'root',
    password: process.env.MYSQL_PASSWORD || '',
    database: process.env.MYSQL_DATABASE || 'ead',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
  });

  try {
    // Check if merchant with ID 22 exists
    const [rows] = await pool.execute('SELECT id FROM merchant WHERE id = ?', [22]);
    
    if (rows.length > 0) {
      console.log('Merchant with ID 22 already exists');
    } else {
      // Insert test merchant
      await pool.execute(`
        INSERT INTO merchant (
          id, username, gstin, pan, company_name, email, mobile, 
          state, city, pincode, password, address, gender, 
          business_start_year, mobile_status, receive_options, 
          business_location, company_logo, kyc, latitude, longitude, 
          otp_verify, otp, status, dated, added_by
        ) VALUES (
          22, 'T k shop', 'GST123456', 'PAN123456', 'T K Enterprise', 
          'test@example.com', '1234567890', 'Test State', 'Test City', 
          '123456', 'password', 'Test Address', 'male', 
          '2020', 1, 'email', 'Test Location', 
          'http://localhost:3000/uploads/default-merchant.png', 1, 
          '0.0', '0.0', 1, '1234', 'active', NOW(), 'system'
        )
      `);
      
      console.log('Test merchant with ID 22 added successfully');
    }
    
    // Check if required tables exist
    const [tableRows] = await pool.execute(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = ? 
      AND table_name IN ('conversations', 'messages', 'call_logs', 'user_status', 'inquiries')
    `, [process.env.MYSQL_DATABASE || 'ead']);
    
    const existingTables = tableRows.map(row => row.table_name);
    const requiredTables = ['conversations', 'messages', 'call_logs', 'user_status', 'inquiries'];
    const missingTables = requiredTables.filter(table => !existingTables.includes(table));
    
    if (missingTables.length > 0) {
      console.log('Missing required tables:', missingTables);
      console.log('Creating missing tables...');
      
      // Create conversations table if it doesn't exist
      if (missingTables.includes('conversations')) {
        await pool.execute(`
          CREATE TABLE IF NOT EXISTS conversations (
            id INT AUTO_INCREMENT PRIMARY KEY,
            customer_id INT NOT NULL,
            merchant_id INT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            last_message TEXT,
            last_message_time TIMESTAMP NULL,
            FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
            FOREIGN KEY (merchant_id) REFERENCES merchant(id) ON DELETE CASCADE,
            UNIQUE KEY unique_conversation (customer_id, merchant_id)
          )
        `);
        console.log('Created conversations table');
      }
      
      // Create messages table if it doesn't exist
      if (missingTables.includes('messages')) {
        await pool.execute(`
          CREATE TABLE IF NOT EXISTS messages (
            id INT AUTO_INCREMENT PRIMARY KEY,
            conversation_id INT NOT NULL,
            sender_type ENUM('customer', 'merchant') NOT NULL,
            sender_id INT NOT NULL,
            message TEXT NOT NULL,
            message_type ENUM('text', 'image', 'file', 'location', 'inquiry') NOT NULL DEFAULT 'text',
            file_url VARCHAR(255) NULL,
            is_read BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE
          )
        `);
        console.log('Created messages table');
      }
      
      // Create call_logs table if it doesn't exist
      if (missingTables.includes('call_logs')) {
        await pool.execute(`
          CREATE TABLE IF NOT EXISTS call_logs (
            id INT AUTO_INCREMENT PRIMARY KEY,
            conversation_id INT NOT NULL,
            caller_type ENUM('customer', 'merchant') NOT NULL,
            caller_id INT NOT NULL,
            receiver_type ENUM('customer', 'merchant') NOT NULL,
            receiver_id INT NOT NULL,
            call_type ENUM('audio', 'video') NOT NULL,
            start_time TIMESTAMP NULL,
            end_time TIMESTAMP NULL,
            status ENUM('missed', 'answered', 'rejected', 'ongoing') NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE
          )
        `);
        console.log('Created call_logs table');
      }
      
      // Create user_status table if it doesn't exist
      if (missingTables.includes('user_status')) {
        await pool.execute(`
          CREATE TABLE IF NOT EXISTS user_status (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_type ENUM('customer', 'merchant') NOT NULL,
            user_id INT NOT NULL,
            is_online BOOLEAN DEFAULT FALSE,
            last_active TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            socket_id VARCHAR(255) NULL,
            UNIQUE KEY unique_user (user_type, user_id)
          )
        `);
        console.log('Created user_status table');
      }
      
      // Create inquiries table if it doesn't exist
      if (missingTables.includes('inquiries')) {
        await pool.execute(`
          CREATE TABLE IF NOT EXISTS inquiries (
            id INT AUTO_INCREMENT PRIMARY KEY,
            conversation_id INT NOT NULL,
            customer_id INT NOT NULL,
            merchant_id INT NOT NULL,
            inquiry_text TEXT NOT NULL,
            status ENUM('pending', 'responded', 'closed') DEFAULT 'pending',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
            FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
            FOREIGN KEY (merchant_id) REFERENCES merchant(id) ON DELETE CASCADE
          )
        `);
        console.log('Created inquiries table');
      }
    } else {
      console.log('All required tables exist');
    }
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    // Close the connection pool
    await pool.end();
  }
}

// Run the function
addTestMerchant()
  .then(() => console.log('Script completed'))
  .catch(err => console.error('Script failed:', err));