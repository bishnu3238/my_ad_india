import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_ad/core/data/model/model.dart';
import 'package:my_ad/core/services/service.dart';
import 'package:pack/services/service.dart';

import '../../../../core/domain/data_store/product_store.dart';
import '../../../../core/domain/use_cases/api_call_use_cases.dart';
import 'ead_product_details_state.dart';

class ProductDetailsViewModel extends ChangeNotifier {
  final ProductModel product;
  final ProductStore _productStore;
  final ProductService _service;
  
  ProductDetailsState _state = ProductDetailsState();
  
  ProductDetailsViewModel({
    required this.product,
    required ProductStore productStore,
    required ProductService service,
  }) : _productStore = productStore,
       _service = service {
    _fetchSimilarProducts();
  }

  ProductDetailsState get state => _state;
  
  void updateState(ProductDetailsState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> _fetchSimilarProducts() async {
    updateState(_state.copyWith(isLoading: true));

    try {
      // Fetch products with the same category
      final products = await _service.fetchProductsByCategory(
        '${product.categoryId}',
      );

      // Filter out current product and limit to 4
      final similarProducts = 
          products.where((p) => p.id != product.id).take(4).toList();

      updateState(_state.copyWith(
        isLoading: false,
        similarProducts: similarProducts,
      ));
    } catch (e) {
      updateState(_state.copyWith(
        isLoading: false,
        errorMessage: e is NetworkFailure ? e.message : e.toString(),
      ));
    }
  }

  void contactMerchant({required bool isCall}) async {
    // This would trigger analytics tracking
    // And possibly update merchant contact count
    if (isCall) {
      // await _service.logMerchantCall(product.merchant.id);
    } else {
      // await _service.logMerchantChat(product.merchant.id);
    }
  }

  void setCurrentImageIndex(int index) {
    if (index >= 0 && index < product.images.length) {
      updateState(_state.copyWith(currentImageIndex: index));
    }
  }

  void setSelectedTabIndex(int index) {
    updateState(_state.copyWith(selectedTabIndex: index));
  }

  void toggleInquiryForm() {
    updateState(_state.copyWith(showInquiryForm: !_state.showInquiryForm));
  }

  Future<void> submitInquiry() async {
    if (!_state.inquiryFormKey.currentState!.validate()) {
      return;
    }
    
    updateState(_state.copyWith(isSubmittingInquiry: true));
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Here you would call an actual API to submit the inquiry
      // await _service.submitInquiry(
      //   merchantId: product.merchant.id,
      //   productId: product.id,
      //   message: _state.inquiryController.text,
      // );
      
      updateState(_state.copyWith(
        isSubmittingInquiry: false,
        inquirySubmitted: true,
        showInquiryForm: false,
      ));
      
      // Reset form after a delay
      Future.delayed(const Duration(seconds: 3), () {
        if (_state.inquirySubmitted) {
          updateState(_state.resetInquiry());
        }
      });
    } catch (e) {
      updateState(_state.copyWith(
        isSubmittingInquiry: false,
        errorMessage: e is NetworkFailure ? e.message : e.toString(),
      ));
    }
  }

  void clearError() {
    updateState(_state.clearError());
  }

  String getDecodedDescription() {
    // If description is Base64 encoded, decode it
    try {
      // This would be your actual decoding logic
      return utf8.decode(base64.decode(product.description));
    } catch (e) {
      return product.description;
    }
  }

  String getDecodedOffers() {
    // If offers are Base64 encoded, decode them
    try {
      return utf8.decode(base64.decode(product.offers));
    } catch (e) {
      return product.offers;
    }
  }
  
  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }
}
