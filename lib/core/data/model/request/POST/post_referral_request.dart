class PostReferralRequest {
  final String name, email, phone;

  PostReferralRequest({
    required this.name,
    required this.email,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
  };
}
