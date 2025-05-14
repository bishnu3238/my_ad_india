enum AttachmentType {
  image,
  video,
  audio,
  document,
  pdf,
  other
}

class Attachment {
  final String? id;
  final String fileName;
  final String fileUrl;
  final String? thumbnailUrl;
  final String? mimeType;
  final int fileSize;
  final DateTime createdAt;
  final int? conversationId;
  final int? messageId;
  final int? inquiryId;
  final String uploadType; // 'message', 'inquiry', 'profile'
  final AttachmentType type;
  final Map<String, dynamic>? metadata;

  Attachment({
    this.id,
    required this.fileName,
    required this.fileUrl,
    this.thumbnailUrl,
    this.mimeType,
    required this.fileSize,
    required this.createdAt,
    this.conversationId,
    this.messageId,
    this.inquiryId,
    required this.uploadType,
    required this.type,
    this.metadata,
  });

  // Create a copy with updated fields
  Attachment copyWith({
    String? id,
    String? fileName,
    String? fileUrl,
    String? thumbnailUrl,
    String? mimeType,
    int? fileSize,
    DateTime? createdAt,
    int? conversationId,
    int? messageId,
    int? inquiryId,
    String? uploadType,
    AttachmentType? type,
    Map<String, dynamic>? metadata,
  }) {
    return Attachment(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      mimeType: mimeType ?? this.mimeType,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
      conversationId: conversationId ?? this.conversationId,
      messageId: messageId ?? this.messageId,
      inquiryId: inquiryId ?? this.inquiryId,
      uploadType: uploadType ?? this.uploadType,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'],
      fileName: json['fileName'],
      fileUrl: json['fileUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      mimeType: json['mimeType'] ?? json['fileType'],
      fileSize: json['fileSize'],
      createdAt: DateTime.parse(json['createdAt']),
      conversationId: json['conversationId'],
      messageId: json['messageId'],
      inquiryId: json['inquiryId'],
      uploadType: json['uploadType'],
      type: _parseAttachmentType(json['type'], json['mimeType'] ?? json['fileType']),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'thumbnailUrl': thumbnailUrl,
      'mimeType': mimeType,
      'fileSize': fileSize,
      'createdAt': createdAt.toIso8601String(),
      'conversationId': conversationId,
      'messageId': messageId,
      'inquiryId': inquiryId,
      'uploadType': uploadType,
      'type': type.toString().split('.').last,
      'metadata': metadata,
    };
  }

  // Parse attachment type from string
  static AttachmentType _parseAttachmentType(String? typeStr, String? mimeType) {
    if (typeStr != null) {
      switch (typeStr) {
        case 'image':
          return AttachmentType.image;
        case 'video':
          return AttachmentType.video;
        case 'audio':
          return AttachmentType.audio;
        case 'document':
          return AttachmentType.document;
        case 'pdf':
          return AttachmentType.pdf;
        default:
          break;
      }
    }

    if (mimeType != null) {
      if (mimeType.startsWith('image/')) return AttachmentType.image;
      if (mimeType.startsWith('video/')) return AttachmentType.video;
      if (mimeType.startsWith('audio/')) return AttachmentType.audio;
      if (mimeType.startsWith('application/pdf')) return AttachmentType.pdf;
      if (mimeType.startsWith('application/')) return AttachmentType.document;
    }

    return AttachmentType.other;
  }

  // Check if attachment is an image
  bool get isImage => type == AttachmentType.image;

  // Check if attachment is a document
  bool get isDocument => type == AttachmentType.document;

  // Check if attachment is an audio file
  bool get isAudio => type == AttachmentType.audio;

  // Check if attachment is a video file
  bool get isVideo => type == AttachmentType.video;

  // Check if attachment is a PDF file
  bool get isPdf => type == AttachmentType.pdf;

  // Get file extension from filename
  String? get fileExtension {
    if (fileName.contains('.')) {
      return fileName.split('.').last;
    }
    if (mimeType != null && mimeType!.contains('/')) {
      return mimeType!.split('/').last;
    }
    return null;
  }

  // Get formatted file size (KB, MB)
  String get formattedFileSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      final kb = (fileSize / 1024).toStringAsFixed(1);
      return '$kb KB';
    } else {
      final mb = (fileSize / (1024 * 1024)).toStringAsFixed(1);
      return '$mb MB';
    }
  }

  // Get appropriate icon based on file type
  String get iconName {
    if (isImage) return 'image';
    if (isPdf) return 'pdf';
    if (isDocument) {
      if (mimeType?.contains('doc') ?? false) return 'doc';
      return 'file';
    }
    if (isAudio) return 'audio';
    if (isVideo) return 'video';
    return 'attachment';
  }

  @override
  String toString() {
    return 'Attachment{id: $id, fileName: $fileName, type: $type}';
  }
}
