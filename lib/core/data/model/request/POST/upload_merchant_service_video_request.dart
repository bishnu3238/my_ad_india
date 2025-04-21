import 'dart:io';

class UploadMerchantServiceVideoRequest {
  final int merchantId;
  final File videoFile;

  const UploadMerchantServiceVideoRequest({
    required this.merchantId,
    required this.videoFile,
  });

  @override
  String toString() {
    return 'UploadMerchantServiceVideoRequest{merchantId: $merchantId, videoFile: $videoFile}';
  }

  Map<String, dynamic> toMap() {
    return {'merchantId': merchantId, 'videoFile': videoFile};
  }
}
