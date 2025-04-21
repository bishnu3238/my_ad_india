class MerchantDashboardFeature {
  final _PhotoService photoService;
  final _AddService addService;
  final _ChatService chatService;
  final _DetailsInfoService detailsInfoService;
  final _VideoService mediaService;

  const MerchantDashboardFeature({
    this.photoService = const _PhotoService(),
    this.mediaService = const _VideoService(),
    this.addService = const _AddService(),
    this.chatService = const _ChatService(),
    this.detailsInfoService = const _DetailsInfoService(),
  });
}

class _PhotoService {
  final bool isAllowed;
  final int maxLimit;
  const _PhotoService({this.isAllowed = false, this.maxLimit = 0});

  @override
  String toString() {
    return 'PhotoService{isAllowed: $isAllowed, maxLimit: $maxLimit}';
  }
}

class _AddService {
  final int remainingService, numberOfService;
  const _AddService({this.remainingService = 0, this.numberOfService = 0});
  bool get canAddMoreService => remainingService < numberOfService;
  @override
  String toString() {
    return '_AddService{remainingService: $remainingService, numberOfService: $numberOfService}';
  }
}

class _DetailsInfoService {
  final bool isWriteDescriptionAllowed;
  final bool isChangeOfferAndDiscountAllowed;
  final bool isBannerAdvtAllowed;
  final bool isLocationAllowed;

  final bool isErrorCorrectionAllowed;
  final int descriptionLengthLimit;
  final int offerAndDiscountLimit;
  final int numberOfBannerAdvt;

  const _DetailsInfoService({
    this.isWriteDescriptionAllowed = false,
    this.isChangeOfferAndDiscountAllowed = false,
    this.isBannerAdvtAllowed = false,
    this.isErrorCorrectionAllowed = false,
    this.isLocationAllowed = false,
    this.descriptionLengthLimit = 0,
    this.offerAndDiscountLimit = 0,
    this.numberOfBannerAdvt = 0,
  });

  @override
  String toString() {
    return '_DetailsInfoService{isWriteDescriptionAllowed: $isWriteDescriptionAllowed, isChangeOfferAndDiscountAllowed: $isChangeOfferAndDiscountAllowed, isBannerAdvtAllowed: $isBannerAdvtAllowed, isErrorCorrectionAllowed: $isErrorCorrectionAllowed, descriptonLengthLimit: $descriptionLengthLimit, offetAndDiscontLimit: $offerAndDiscountLimit, numberOfbannerAdvt: $numberOfBannerAdvt}';
  }
}

class _ChatService {
  final bool isShowPhoneNoAllowed;
  final bool isShowEmailIDAllowed;
  final bool isReviewByUserAllowed;
  final bool isChatAllowed;
  final bool isVideoCallAllowed;
  const _ChatService({
    this.isShowPhoneNoAllowed = false,
    this.isShowEmailIDAllowed = false,
    this.isReviewByUserAllowed = false,
    this.isChatAllowed = false,
    this.isVideoCallAllowed = false,
  });

  @override
  String toString() {
    return '_ChatService{isShowPhoneNoAllowed: $isShowPhoneNoAllowed, isShowEmailIDAllowed: $isShowEmailIDAllowed, isReviewByUserAllowed: $isReviewByUserAllowed, isChatAllowed: $isChatAllowed, isVideoCallAllowed: $isVideoCallAllowed}';
  }
}

class _VideoService {
  final bool isUploadVideoAllowed;
  final int videoLimit;

  const _VideoService({this.isUploadVideoAllowed = false, this.videoLimit = 0});

  @override
  String toString() {
    return '_MediaService{ isUploadVideoAllowed: $isUploadVideoAllowed, videoLimit: $videoLimit}';
  }
}
