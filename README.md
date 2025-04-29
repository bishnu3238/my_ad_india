# Service Connector Chat System

This is a real-time chat, messaging, calling, and video calling system for a service connector application. It allows customers to communicate with service providers through text messages, file sharing, audio calls, video calls, and service inquiries.

## Features

- Real-time text messaging
- Image and file sharing
- Audio and video calling
- Service inquiries
- Read receipts
- Typing indicators
- Online/offline status
- Call history
- Inquiry management

## System Architecture

The system consists of two main components:

1. **Node.js Backend**:
   - Express.js for REST API
   - Socket.IO for real-time communication
   - MySQL database for data storage

2. **Flutter Frontend**:
   - Provider for state management
   - Socket.IO client for real-time communication
   - HTTP client for REST API calls

## Setup Instructions

### Database Setup

1. Create the required tables in your MySQL database by running the SQL script:

```bash
mysql -u root -p ead < server/database/chat_schema.sql
```

### Backend Setup

1. Navigate to the server directory:

```bash
cd server
```

2. Install dependencies:

```bash
npm install
```

3. Create a `.env` file with your configuration:

```
PORT=3000
MYSQL_HOST=localhost
MYSQL_USER=root
MYSQL_PASSWORD=
MYSQL_DATABASE=ead
UPLOAD_DIR=./uploads
```

4. Start the server:

```bash
npm start
```

For development with auto-restart:

```bash
npm run dev
```

### Flutter Setup

1. Add the required dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  socket_io_client: ^2.0.3+1
  http: ^1.1.0
  http_parser: ^4.0.2
  intl: ^0.18.1
  timeago: ^3.5.0
  image_picker: ^1.0.4
  path_provider: ^2.1.1
  flutter_local_notifications: ^15.1.1
  cached_network_image: ^3.3.0
```

2. Run Flutter pub get:

```bash
flutter pub get
```

3. Update your app's configuration to point to your server:

```dart
// In your app initialization
final chatManager = Provider.of<ChatManager>(context, listen: false);
chatManager.initialize(
  'http://your-server-ip:3000', // Replace with your server URL
  userId,
  userType, // 'customer' or 'merchant'
);
```

## Usage

### Initializing Chat

Before using the chat features, initialize the ChatManager:

```dart
final chatManager = Provider.of<ChatManager>(context, listen: false);
chatManager.initialize(
  'http://your-server-ip:3000',
  userId,
  userType, // 'customer' or 'merchant'
);
```

### Starting a Conversation

To start a conversation with a service provider from a product details page:

```dart
void _openChat(BuildContext context, int merchantId, String merchantName, String? merchantImage) async {
  final chatManager = Provider.of<ChatManager>(context, listen: false);
  
  try {
    // Create or get conversation
    final conversationId = await chatManager.getOrCreateConversation(
      userId.toString(), 
      merchantId.toString()
    );
    
    // Navigate to chat screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          conversationId: conversationId,
          otherUserName: merchantName,
          otherUserImage: merchantImage ?? '',
          otherUserType: 'merchant',
          otherUserId: merchantId.toString(),
        ),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error opening chat: $e')),
    );
  }
}
```

### Sending Messages

To send a text message:

```dart
chatManager.sendTextMessage("Hello, I'm interested in your service");
```

To send an image:

```dart
final image = await ImagePicker().pickImage(source: ImageSource.gallery);
if (image != null) {
  await chatManager.sendFileMessage(File(image.path), 'image');
}
```

### Making Calls

To initiate an audio call:

```dart
chatManager.initiateCall('audio');
```

To initiate a video call:

```dart
chatManager.initiateCall('video');
```

### Sending Inquiries

For customers to send service inquiries:

```dart
await chatManager.sendInquiry("I'd like to know more about your pricing", merchantId);
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.