import 'package:equatable/equatable.dart';

class City extends Equatable {
  const City({
    required this.id,
    required this.regionId,
    required this.nameAr,
    this.nameEn,
    this.nameHe,
  });

  final int id;
  final int regionId;
  final String nameAr;
  final String? nameEn;
  final String? nameHe;

  String localizedName(String languageCode) => switch (languageCode) {
    'en' => nameEn ?? nameAr,
    'he' => nameHe ?? nameAr,
    _ => nameAr,
  };

  @override
  List<Object?> get props => [id, regionId, nameAr, nameEn, nameHe];
}
