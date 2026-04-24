/// The four account roles the app supports at registration time.
enum UserType {
  renter,
  owner,
  office,
  carLessor;

  /// String the backend expects in the `user_type` field.
  String get apiValue => switch (this) {
    UserType.renter => 'renter',
    UserType.owner => 'owner',
    UserType.office => 'office',
    UserType.carLessor => 'car_lessor',
  };

  /// AppLocalizations key for the display label.
  String get labelKey => switch (this) {
    UserType.renter => 'user_type_renter',
    UserType.owner => 'user_type_owner',
    UserType.office => 'user_type_office',
    UserType.carLessor => 'user_type_car_lessor',
  };

  /// Landlord-kind roles need the company-name, region, and city
  /// fields on the register form.
  bool get isLandlord =>
      this == UserType.owner ||
      this == UserType.office ||
      this == UserType.carLessor;

  static UserType? fromApiValue(String? value) => switch (value) {
    'renter' => UserType.renter,
    'owner' => UserType.owner,
    'office' => UserType.office,
    'car_lessor' => UserType.carLessor,
    _ => null,
  };
}
