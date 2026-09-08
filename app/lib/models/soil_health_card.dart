import 'dart:convert';

/// Status classification for a soil nutrient reading.
enum NutrientStatus {
  low,
  medium,
  normal,
  high,
  sufficient,
  deficient;

  String get displayName {
    switch (this) {
      case NutrientStatus.low:
        return 'Low';
      case NutrientStatus.medium:
        return 'Medium';
      case NutrientStatus.normal:
        return 'Normal';
      case NutrientStatus.high:
        return 'High';
      case NutrientStatus.sufficient:
        return 'Sufficient';
      case NutrientStatus.deficient:
        return 'Deficient';
    }
  }

  String toJson() => name;

  static NutrientStatus fromJson(String value) {
    return NutrientStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NutrientStatus.normal,
    );
  }
}

/// Category grouping for nutrient readings.
enum NutrientCategory {
  soilProperty,
  macronutrient,
  secondaryNutrient,
  micronutrient;

  String get displayName {
    switch (this) {
      case NutrientCategory.soilProperty:
        return 'Soil Properties';
      case NutrientCategory.macronutrient:
        return 'Macronutrients';
      case NutrientCategory.secondaryNutrient:
        return 'Secondary Nutrients';
      case NutrientCategory.micronutrient:
        return 'Micronutrients';
    }
  }

  String toJson() => name;

  static NutrientCategory fromJson(String value) {
    return NutrientCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NutrientCategory.soilProperty,
    );
  }
}

/// A single soil nutrient or property reading.
class SoilNutrientReading {
  final String name;
  final double value;
  final String unit;
  final NutrientStatus status;
  final NutrientCategory category;

  const SoilNutrientReading({
    required this.name,
    required this.value,
    required this.unit,
    required this.status,
    required this.category,
  });

  SoilNutrientReading copyWith({
    String? name,
    double? value,
    String? unit,
    NutrientStatus? status,
    NutrientCategory? category,
  }) {
    return SoilNutrientReading(
      name: name ?? this.name,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      status: status ?? this.status,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'value': value,
    'unit': unit,
    'status': status.toJson(),
    'category': category.toJson(),
  };

  factory SoilNutrientReading.fromJson(Map<String, dynamic> json) {
    return SoilNutrientReading(
      name: json['name'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      status: NutrientStatus.fromJson(json['status'] as String),
      category: NutrientCategory.fromJson(json['category'] as String),
    );
  }
}

/// Complete Soil Health Card record for a specific field.
class SoilHealthCard {
  final String id;
  final String fieldId;

  // Card / sample identification
  final String? cardNumber;
  final String? sampleId;

  // Farmer information
  final String? farmerName;
  final String? fatherHusbandName;
  final String? village;
  final String? tehsil;
  final String? district;
  final String? state;
  final String? totalLandHolding;

  // Dates
  final DateTime? registrationDate;
  final DateTime? sampleDate;
  final DateTime uploadDate;

  // Soil characteristics
  final String? soilType;
  final String? soilColour;
  final String? soilTexture;
  final String? location;

  // Nutrient readings
  final List<SoilNutrientReading> nutrients;

  // Recommendations
  final List<String> fertilizerRecommendations;
  final List<String> nutrientRecommendations;
  final List<String> cropRecommendations;

  // Source / status
  final String? sourceFileName;
  final bool isVerified;
  final bool isCurrent;

  const SoilHealthCard({
    required this.id,
    required this.fieldId,
    this.cardNumber,
    this.sampleId,
    this.farmerName,
    this.fatherHusbandName,
    this.village,
    this.tehsil,
    this.district,
    this.state,
    this.totalLandHolding,
    this.registrationDate,
    this.sampleDate,
    required this.uploadDate,
    this.soilType,
    this.soilColour,
    this.soilTexture,
    this.location,
    this.nutrients = const [],
    this.fertilizerRecommendations = const [],
    this.nutrientRecommendations = const [],
    this.cropRecommendations = const [],
    this.sourceFileName,
    this.isVerified = false,
    this.isCurrent = false,
  });

  SoilHealthCard copyWith({
    String? id,
    String? fieldId,
    String? cardNumber,
    String? sampleId,
    String? farmerName,
    String? fatherHusbandName,
    String? village,
    String? tehsil,
    String? district,
    String? state,
    String? totalLandHolding,
    DateTime? registrationDate,
    DateTime? sampleDate,
    DateTime? uploadDate,
    String? soilType,
    String? soilColour,
    String? soilTexture,
    String? location,
    List<SoilNutrientReading>? nutrients,
    List<String>? fertilizerRecommendations,
    List<String>? nutrientRecommendations,
    List<String>? cropRecommendations,
    String? sourceFileName,
    bool? isVerified,
    bool? isCurrent,
  }) {
    return SoilHealthCard(
      id: id ?? this.id,
      fieldId: fieldId ?? this.fieldId,
      cardNumber: cardNumber ?? this.cardNumber,
      sampleId: sampleId ?? this.sampleId,
      farmerName: farmerName ?? this.farmerName,
      fatherHusbandName: fatherHusbandName ?? this.fatherHusbandName,
      village: village ?? this.village,
      tehsil: tehsil ?? this.tehsil,
      district: district ?? this.district,
      state: state ?? this.state,
      totalLandHolding: totalLandHolding ?? this.totalLandHolding,
      registrationDate: registrationDate ?? this.registrationDate,
      sampleDate: sampleDate ?? this.sampleDate,
      uploadDate: uploadDate ?? this.uploadDate,
      soilType: soilType ?? this.soilType,
      soilColour: soilColour ?? this.soilColour,
      soilTexture: soilTexture ?? this.soilTexture,
      location: location ?? this.location,
      nutrients: nutrients ?? this.nutrients,
      fertilizerRecommendations: fertilizerRecommendations ?? this.fertilizerRecommendations,
      nutrientRecommendations: nutrientRecommendations ?? this.nutrientRecommendations,
      cropRecommendations: cropRecommendations ?? this.cropRecommendations,
      sourceFileName: sourceFileName ?? this.sourceFileName,
      isVerified: isVerified ?? this.isVerified,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fieldId': fieldId,
    'cardNumber': cardNumber,
    'sampleId': sampleId,
    'farmerName': farmerName,
    'fatherHusbandName': fatherHusbandName,
    'village': village,
    'tehsil': tehsil,
    'district': district,
    'state': state,
    'totalLandHolding': totalLandHolding,
    'registrationDate': registrationDate?.toIso8601String(),
    'sampleDate': sampleDate?.toIso8601String(),
    'uploadDate': uploadDate.toIso8601String(),
    'soilType': soilType,
    'soilColour': soilColour,
    'soilTexture': soilTexture,
    'location': location,
    'nutrients': nutrients.map((n) => n.toJson()).toList(),
    'fertilizerRecommendations': fertilizerRecommendations,
    'nutrientRecommendations': nutrientRecommendations,
    'cropRecommendations': cropRecommendations,
    'sourceFileName': sourceFileName,
    'isVerified': isVerified,
    'isCurrent': isCurrent,
  };

  factory SoilHealthCard.fromJson(Map<String, dynamic> json) {
    return SoilHealthCard(
      id: json['id'] as String,
      fieldId: json['fieldId'] as String,
      cardNumber: json['cardNumber'] as String?,
      sampleId: json['sampleId'] as String?,
      farmerName: json['farmerName'] as String?,
      fatherHusbandName: json['fatherHusbandName'] as String?,
      village: json['village'] as String?,
      tehsil: json['tehsil'] as String?,
      district: json['district'] as String?,
      state: json['state'] as String?,
      totalLandHolding: json['totalLandHolding'] as String?,
      registrationDate: json['registrationDate'] != null
          ? DateTime.tryParse(json['registrationDate'] as String)
          : null,
      sampleDate: json['sampleDate'] != null
          ? DateTime.tryParse(json['sampleDate'] as String)
          : null,
      uploadDate: DateTime.parse(json['uploadDate'] as String),
      soilType: json['soilType'] as String?,
      soilColour: json['soilColour'] as String?,
      soilTexture: json['soilTexture'] as String?,
      location: json['location'] as String?,
      nutrients: (json['nutrients'] as List?)
              ?.map((n) => SoilNutrientReading.fromJson(n as Map<String, dynamic>))
              .toList() ??
          [],
      fertilizerRecommendations:
          List<String>.from(json['fertilizerRecommendations'] as List? ?? []),
      nutrientRecommendations:
          List<String>.from(json['nutrientRecommendations'] as List? ?? []),
      cropRecommendations:
          List<String>.from(json['cropRecommendations'] as List? ?? []),
      sourceFileName: json['sourceFileName'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      isCurrent: json['isCurrent'] as bool? ?? false,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory SoilHealthCard.fromJsonString(String jsonString) =>
      SoilHealthCard.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);

  /// Helper to get a nutrient reading by name.
  SoilNutrientReading? getNutrient(String name) {
    try {
      return nutrients.firstWhere(
        (n) => n.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Helper to get nutrients by category.
  List<SoilNutrientReading> getNutrientsByCategory(NutrientCategory category) {
    return nutrients.where((n) => n.category == category).toList();
  }
}
