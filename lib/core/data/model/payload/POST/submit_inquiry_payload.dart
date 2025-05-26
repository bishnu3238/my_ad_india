/// Represents the payload data for creating a new inquiry.
///
/// This class mirrors the parameters expected by the Node.js `saveInquiry` method.
class SubmitInquiryPayload {
  final int conversationId;
  final String customerType; // Based on validation, expected to be 'customer'
  final int customerId;
  final String merchantType; // Based on validation, expected to be 'merchant'
  final int merchantId;
  final String subject;
  final String message;
  final String? attachmentUrl;

  final String?  serviceName; // Nullable

  /// Creates an instance of [SubmitInquiryPayload].
  ///
  /// Includes basic assertions to catch common errors during development.
  /// The backend will perform final, authoritative validation.
  SubmitInquiryPayload({
    required this.conversationId,
    required this.customerType,
    required this.customerId,
    required this.merchantType,
    required this.merchantId,
    required this.subject,
    required this.message,
      this.serviceName,
    this.attachmentUrl,
  }) : assert(conversationId > 0, 'conversationId must be positive'),
        assert(customerId > 0, 'customerId must be positive'),
        assert(merchantId > 0, 'merchantId must be positive'),
  // Basic check based on Node.js validation
        assert(customerType == 'customer', 'customerType must be "customer"'),
        assert(merchantType == 'merchant', 'merchantType must be "merchant"'),
  // Assertions for string length based on Node.js validation
        assert(subject.trim().length >= 3 && subject.trim().length <= 100, 'Subject must be 3-100 characters'),
        assert(message.trim().length >= 10, 'Message must be at least 10 characters');


  /// Converts this [SubmitInquiryPayload] instance into a JSON-compatible Map.
  ///
  /// Note: The Node.js function trims whitespace from subject and message.
  /// While you could do that here, it's generally safer to let the backend
  /// handle final data cleansing based on its own rules. However, for consistency
  /// with the Node.js logic shown, we'll trim here before converting to JSON.
  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'customerType': customerType,
      'customerId': customerId,
      'merchantType': merchantType,
      'merchantId': merchantId,
      'subject': subject.trim(), // Trim whitespace for consistency with backend logic
      'message': message.trim(), // Trim whitespace for consistency with backend logic
      'attachmentUrl': attachmentUrl, // null is valid in JSON
    };
  }

  @override
  String toString() {
    return 'InquiryPayload(conversationId: $conversationId, customerType: $customerType, customerId: $customerId, merchantType: $merchantType, merchantId: $merchantId, subject: "$subject", message: "${message.substring(0, message.length > 50 ? 50 : message.length)}...", attachmentUrl: $attachmentUrl)';
  }
}