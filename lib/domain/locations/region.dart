import 'package:equatable/equatable.dart';

class Region extends Equatable {
  const Region({
    required this.id,
    required this.nameAr,
    this.nameEn,
    this.nameHe,
  });

  final int id;
  final String nameAr;
  final String? nameEn;
  final String? nameHe;

  /// Returns the best-fit name for the active locale, falling back
  /// to Arabic.
  String localizedName(String languageCode) => switch (languageCode) {
    'en' => nameEn ?? nameAr,
    'he' => nameHe ?? nameAr,
    _ => nameAr,
  };

  @override
  List<Object?> get props => [id, nameAr, nameEn, nameHe];
}
