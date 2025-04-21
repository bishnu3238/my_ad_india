import 'package:pack/services/base_services/base_service.dart';

class PostMerchantLogin  extends LoginRequest{
    PostMerchantLogin({  required super.password, required super.username}) ;
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;
    data['password'] = password;
    return data;
  }
}
