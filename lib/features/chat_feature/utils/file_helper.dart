import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart'  ;
import 'dart:math';
import 'package:http/http.dart' as http;

class FileHelper {
  // Pick image from gallery
  static Future<File?> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }

    return null;
  }

  // Take photo with camera
  static Future<File?> takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }

    return null;
  }

  // Pick a file
  static Future<File?> pickFile() async {
    // Note: For a complete file picker, you would need to use a package like file_picker
    // This is a simplified version that just picks images
    return pickImageFromGallery();
  }

  // Get file size in readable format
  static String getFileSizeString({required int bytes, int decimals = 1}) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  // Get file name from path
  static String getFileName(String filePath) {
    return path.basename(filePath);
  }

  // Get file extension
  static String getFileExtension(String filePath) {
    return path.extension(filePath).toLowerCase();
  }

  // Check if file is an image
  static bool isImageFile(String filePath) {
    final extension = getFileExtension(filePath);
    return ['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(extension);
  }

  // Check if file is a video
  static bool isVideoFile(String filePath) {
    final extension = getFileExtension(filePath);
    return ['.mp4', '.mov', '.avi', '.wmv', '.flv', '.webm'].contains(extension);
  }

  // Check if file is an audio
  static bool isAudioFile(String filePath) {
    final extension = getFileExtension(filePath);
    return ['.mp3', '.wav', '.ogg', '.aac', '.m4a'].contains(extension);
  }

  // Get mime type
  static String getMimeType(String filePath) {
    final mimeType = lookupMimeType(filePath);
    return mimeType ?? 'application/octet-stream';
  }

  // Download file from URL
  static Future<File?> downloadFile(String url, {String? customFileName}) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final fileName = customFileName ?? url.split('/').last;
        final filePath = path.join(directory.path, fileName);

        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        return file;
      }
    } catch (e) {
      debugPrint('Error downloading file: $e');
    }

    return null;
  }

  // Get file icon based on mime type
  static IconData getFileIcon(String filePath) {
    final mimeType = getMimeType(filePath);

    if (mimeType.startsWith('image/')) {
      return Icons.image;
    } else if (mimeType.startsWith('video/')) {
      return Icons.video_file;
    } else if (mimeType.startsWith('audio/')) {
      return Icons.audio_file;
    } else if (mimeType.startsWith('text/')) {
      return Icons.text_snippet;
    } else if (mimeType.contains('pdf')) {
      return Icons.picture_as_pdf;
    } else if (mimeType.contains('word') || mimeType.contains('document')) {
      return Icons.description;
    } else if (mimeType.contains('excel') || mimeType.contains('sheet')) {
      return Icons.table_chart;
    } else if (mimeType.contains('presentation') || mimeType.contains('powerpoint')) {
      return Icons.slideshow;
    } else if (mimeType.contains('zip') || mimeType.contains('compressed')) {
      return Icons.folder_zip;
    } else {
      return Icons.insert_drive_file;
    }
  }

  // Get file color based on mime type
  static Color getFileColor(String filePath) {
    final mimeType = getMimeType(filePath);

    if (mimeType.startsWith('image/')) {
      return Colors.blue;
    } else if (mimeType.startsWith('video/')) {
      return Colors.red;
    } else if (mimeType.startsWith('audio/')) {
      return Colors.purple;
    } else if (mimeType.startsWith('text/')) {
      return Colors.blueGrey;
    } else if (mimeType.contains('pdf')) {
      return Colors.red;
    } else if (mimeType.contains('word') || mimeType.contains('document')) {
      return Colors.blue;
    } else if (mimeType.contains('excel') || mimeType.contains('sheet')) {
      return Colors.green;
    } else if (mimeType.contains('presentation') || mimeType.contains('powerpoint')) {
      return Colors.orange;
    } else if (mimeType.contains('zip') || mimeType.contains('compressed')) {
      return Colors.amber;
    } else {
      return Colors.grey;
    }
  }
}

// Helper function for log calculation
double log(num x) => log10(x);

// Helper function for log10 calculation
double log10(num x) => log(x) / ln10;

// Natural log of 10
const double ln10 = 2.302585092994046;


/// now Build the flutter side implementation (C:\00AA\flutter_projects\my_ad_test\lib\features). @feature/ || Build a full fledge a chatting application on the flutter side, So that Customer and merchant able to interact with each other, for that we will user this dependancies @pubspec.yaml `dependencies: flutter: sdk: flutter # The following adds the Cupertino Icons font to your application. # Use with the CupertinoIcons class for iOS style icons. cupertino_icons: ^1.0.8 auto_size_text: ^3.0.0 flutter_staggered_animations: ^1.1.1 provider: ^6.1.2 url_launcher: ^6.3.1 shared_preferences: ^2.5.2 google_fonts: ^6.2.1 flutter_svg: ^2.0.17 video_player_web: ^2.3.4 image_picker: ^1.1.2 geolocator: ^13.0.2 get_it: ^8.0.3 dartz: ^0.10.1 equatable: ^2.0.7 font_awesome_flutter: ^10.8.0 connectivity_plus: ^6.1.3 go_router: ^14.8.1 smooth_page_indicator: ^1.2.1 permission_handler: ^11.4.0 lottie: ^3.3.1 logger: ^2.5.0 web_socket_channel: ^3.0.2 flutter_secure_storage: ^9.2.4 geocoding: ^3.0.0 pack: path: pack/ flutter_animate: ^4.5.2 collection: ^1.19.1 animations: ^2.0.11 flutter_local_notifications: ^19.0.0 flutter_localization: ^0.3.2 intl: ^0.19.0 video_player: ^2.9.5 mime: ^2.0.0 share_plus: ^10.1.4 socket_io_client: ^3.1.1 record: ^6.0.0 flutter_rating_bar: ^4.0.1`; i already created customer and merchant auth(login, sign up pages with provider / store file and also created models in data/model/ folder; C:\00AA\flutter_projects\my_ad_test\lib\core\domain\data_store\merchant_dashboard_store.dart,C:\00AA\flutter_projects\my_ad_test\lib\core\domain\data_store\user_authentication_store.dart ) ; lib/ ├── chat/ # Main chat module directory │ ├── config/ │ │ ├── socket_config.dart # Socket.io configuration │ │ └── api_endpoints.dart # Chat API endpoint constants │ │ │ ├── models/ │ │ ├── message.dart # Message model │ │ ├── conversation.dart # Conversation model │ │ ├── call.dart # Call model │ │ ├── inquiry.dart # Inquiry model │ │ └── attachment.dart # Attachment model │ │ │ ├── providers/ │ │ ├── chat_provider.dart # Chat state management │ │ ├── call_provider.dart # Call state management │ │ ├── inquiry_provider.dart # Inquiry state management │ │ └── socket_provider.dart # Socket connection state provider │ │ │ ├── services/ │ │ ├── chat_service.dart # Chat API service │ │ ├── call_service.dart # Call API service │ │ ├── inquiry_service.dart # Inquiry API service │ │ └── socket_service.dart # Socket.io client service │ │ │ ├── utils/ │ │ ├── permission_handler.dart # Handle camera, mic permissions │ │ ├── file_helper.dart # File handling utility │ │ └── message_formatter.dart # Message formatting helpers │ │ │ ├── widgets/ │ │ ├── common/ │ │ │ ├── loading_indicator.dart # Loading state widget │ │ │ ├── status_indicator.dart # Online/offline indicator │ │ │ └── attachment_preview.dart # Preview attachment before sending │ │ │ │ │ ├── messaging/ │ │ │ ├── message_bubble.dart # Message display widget │ │ │ ├── chat_input.dart # Chat input field │ │ │ ├── attachment_picker.dart # File attachment selector │ │ │ ├── conversation_tile.dart # Conversation list item │ │ │ └── emoji_picker.dart # Emoji selection widget │ │ │ │ │ ├── calls/ │ │ │ ├── call_controls.dart # Call control buttons │ │ │ ├── video_view.dart # Video display widget │ │ │ ├── call_timer.dart # Call duration timer │ │ │ └── audio_level_indicator.dart # Audio level visualization │ │ │ │ │ └── inquiries/ │ │ ├── inquiry_form.dart # Inquiry submission form │ │ └── inquiry_list_item.dart # Inquiry list item │ │ │ ├── screens/ │ │ ├── customer/ │ │ │ ├── conversation_list_screen.dart # Customer conversations list │ │ │ ├── chat_detail_screen.dart # Customer chat screen │ │ │ ├── call_screen.dart # Customer video/audio call screen │ │ │ └── inquiry_screen.dart # Customer inquiry screen │ │ │ │ │ └── merchant/ │ │ ├── conversation_list_screen.dart # Merchant conversations list │ │ ├── chat_detail_screen.dart # Merchant chat screen │ │ ├── call_screen.dart # Merchant video/audio call screen │ │ └── inquiry_management_screen.dart # Merchant inquiry management │ │ │ ├── mixins/ │ │ ├── message_handler_mixin.dart # Message handling logic │ │ └── call_handler_mixin.dart # Call handling logic │ │ │ ├── constants/ │ │ ├── chat_strings.dart # Chat-related string constants │ │ └── socket_events.dart # Socket event name constants │ │ │ └── controllers/ │ ├── chat_controller.dart # Chat business logic │ ├── call_controller.dart # Call business logic │ └── inquiry_controller.dart # Inquiry business logic ├── main.dart # App entry point └── [other existing app folders] # Your existing app structure



