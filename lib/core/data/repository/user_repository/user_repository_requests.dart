class UpdateProfileRequest {
  final String? name;
  final String? email;
  final String? phone;
  final Map<String, dynamic>? additionalData;

  const UpdateProfileRequest({
    this.name,
    this.email,
    this.phone,
    this.additionalData,
  });

  Map<String, String> toJson() {
    final Map<String, String> data = {
      'name': name ?? '',
      'email': email ?? '',
      'phone': phone ?? '',
    };

    // Now add the additionalData, converting all values to String
    if (additionalData != null) {
      additionalData!.forEach((key, value) {
        data[key] = value?.toString() ?? '';
      });
    }

    return data;
  }
}
