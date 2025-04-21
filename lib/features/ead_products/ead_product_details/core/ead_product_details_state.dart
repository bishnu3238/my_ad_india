import 'package:flutter/material.dart';
import 'package:my_ad/core/data/model/model.dart';

/// State class for the Product Details UI
class ProductDetailsState {
  final bool isLoading;
  final bool isSubmittingInquiry;
  final String? errorMessage;
  final int currentImageIndex;
  final List<ProductModel> similarProducts;
  final TextEditingController inquiryController;
  final GlobalKey<FormState> inquiryFormKey;
  final bool showInquiryForm;
  final bool inquirySubmitted;
  final int selectedTabIndex;

  ProductDetailsState({
    this.isLoading = false,
    this.isSubmittingInquiry = false,
    this.errorMessage,
    this.currentImageIndex = 0,
    this.similarProducts = const [],
    TextEditingController? inquiryController,
    GlobalKey<FormState>? inquiryFormKey,
    this.showInquiryForm = false,
    this.inquirySubmitted = false,
    this.selectedTabIndex = 0,
  }) : 
    this.inquiryController = inquiryController ?? TextEditingController(),
    this.inquiryFormKey = inquiryFormKey ?? GlobalKey<FormState>();

  ProductDetailsState copyWith({
    bool? isLoading,
    bool? isSubmittingInquiry,
    String? errorMessage,
    int? currentImageIndex,
    List<ProductModel>? similarProducts,
    TextEditingController? inquiryController,
    GlobalKey<FormState>? inquiryFormKey,
    bool? showInquiryForm,
    bool? inquirySubmitted,
    int? selectedTabIndex,
  }) {
    return ProductDetailsState(
      isLoading: isLoading ?? this.isLoading,
      isSubmittingInquiry: isSubmittingInquiry ?? this.isSubmittingInquiry,
      errorMessage: errorMessage ?? this.errorMessage,
      currentImageIndex: currentImageIndex ?? this.currentImageIndex,
      similarProducts: similarProducts ?? this.similarProducts,
      inquiryController: inquiryController ?? this.inquiryController,
      inquiryFormKey: inquiryFormKey ?? this.inquiryFormKey,
      showInquiryForm: showInquiryForm ?? this.showInquiryForm,
      inquirySubmitted: inquirySubmitted ?? this.inquirySubmitted,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }

  /// Reset error message
  ProductDetailsState clearError() {
    return copyWith(errorMessage: null);
  }

  /// Reset inquiry form
  ProductDetailsState resetInquiry() {
    inquiryController.clear();
    return copyWith(
      showInquiryForm: false,
      inquirySubmitted: false,
      isSubmittingInquiry: false,
    );
  }

  /// Dispose resources
  void dispose() {
    inquiryController.dispose();
  }
}
