enum AuthStatus {
  initial,
  authenticated,
  authenticating,
  unauthenticated,
  getStarted,
  onboardingPersonalInfo,
  onboardingPhoneVerification,
  onboardingPhotoUpload,
  onboardingComplete,
}

enum ProgressStepStatus {
  inactive,
  active,
  completed,
}

enum OnboardingStep {
  personalInfo,
  phoneVerification,
  photoUpload,
  showCompleted,
  completed,
}

enum OnboardingTransactionStatus {
  started,
  waitingForOTP,
  verifyingOTP,
}

enum PropertyPublishOnboardingStep {
  placeDate,
  placeType,
  placeLocation,
  placeDetails,
  placeAmenities,
  placePhotos,
  placeTitle,
  placeStyle,
  preview,
  success,
}

enum TransactionStatus {
  idle,
  loading,
  success,
  error,
}

enum FiltersScenario {
  filtersEmpty,
  filtersApplied,
}

enum SelectionMode {
  single,
  range,
}

enum RequestStatus {
  pending,
  approved,
  rejected,
  withdrawn,
}

enum AppType {
  sublet, // Green
  host, // Blue
}

enum ImageType {
  profile,
  property,
  sublet,
  full,
}

enum EmptySublet {
  allUsersSwiped,
  noNearbyUsers,
}
