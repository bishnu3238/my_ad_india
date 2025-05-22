import 'package:flutter/material.dart';
 
import 'body/customer_reviews.dart';

class UserReviews extends StatelessWidget {
  const UserReviews({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: CustomerReviews(),
    );  }
}
