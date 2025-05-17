import 'package:equatable/equatable.dart';
import '../../../../../core/data/model/merchant/merchant_model.dart';

enum EditProfileStatus {
  initial,
  loading,
  success,
  error,
}

class EditProfileState extends Equatable {
  final MerchantModel merchant;
  final EditProfileStatus status;
  final String? errorMessage;
  final bool isDirty;
  final bool isImageChanged;
  final bool isSubmitting;
  
  const EditProfileState({
    required this.merchant,
    this.status = EditProfileStatus.initial,
    this.errorMessage,
    this.isDirty = false,
    this.isImageChanged = false,
    this.isSubmitting = false,
  });

  EditProfileState copyWith({
    MerchantModel? merchant,
    EditProfileStatus? status,
    String? errorMessage,
    bool? isDirty,
    bool? isImageChanged,
    bool? isSubmitting,
  }) {
    return EditProfileState(
      merchant: merchant ?? this.merchant,
      status: status ?? this.status,
      errorMessage: errorMessage,
      isDirty: isDirty ?? this.isDirty,
      isImageChanged: isImageChanged ?? this.isImageChanged,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        merchant,
        status,
        errorMessage,
        isDirty,
        isImageChanged,
        isSubmitting,
      ];
}