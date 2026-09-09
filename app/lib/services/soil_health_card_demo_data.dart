import '../models/soil_health_card.dart';

/// Provides realistic demo Soil Health Card records for the hackathon demo.
/// Values are inspired by a real Government of India Soil Health Card.
/// These are DEMO values only — not actual farmer data.
class SoilHealthCardDemoData {
  SoilHealthCardDemoData._();

  /// Standard nutrient set for building demo cards with varied values.
  static List<SoilNutrientReading> _buildNutrients({
    required double ph,
    required double ec,
    required double oc,
    required double nitrogen,
    required double phosphorus,
    required double potassium,
    required double sulphur,
    required double zinc,
    required double iron,
    required double copper,
    required double manganese,
    required double boron,
  }) {
    return [
      SoilNutrientReading(
        name: 'pH',
        value: ph,
        unit: '',
        status: ph >= 6.5 && ph <= 7.5
            ? NutrientStatus.normal
            : (ph < 6.5 ? NutrientStatus.low : NutrientStatus.high),
        category: NutrientCategory.soilProperty,
      ),
      SoilNutrientReading(
        name: 'Electrical Conductivity (EC)',
        value: ec,
        unit: 'dS/m',
        status: ec <= 1.0 ? NutrientStatus.normal : NutrientStatus.high,
        category: NutrientCategory.soilProperty,
      ),
      SoilNutrientReading(
        name: 'Organic Carbon',
        value: oc,
        unit: '%',
        status: oc >= 0.75
            ? NutrientStatus.sufficient
            : (oc >= 0.5 ? NutrientStatus.medium : NutrientStatus.low),
        category: NutrientCategory.soilProperty,
      ),
      SoilNutrientReading(
        name: 'Available Nitrogen (N)',
        value: nitrogen,
        unit: 'kg/ha',
        status: nitrogen >= 280
            ? NutrientStatus.high
            : (nitrogen >= 240
                ? NutrientStatus.medium
                : NutrientStatus.low),
        category: NutrientCategory.macronutrient,
      ),
      SoilNutrientReading(
        name: 'Available Phosphorus (P)',
        value: phosphorus,
        unit: 'kg/ha',
        status: phosphorus >= 25
            ? NutrientStatus.high
            : (phosphorus >= 12.5
                ? NutrientStatus.medium
                : NutrientStatus.low),
        category: NutrientCategory.macronutrient,
      ),
      SoilNutrientReading(
        name: 'Available Potassium (K)',
        value: potassium,
        unit: 'kg/ha',
        status: potassium >= 280
            ? NutrientStatus.high
            : (potassium >= 135
                ? NutrientStatus.medium
                : NutrientStatus.low),
        category: NutrientCategory.macronutrient,
      ),
      SoilNutrientReading(
        name: 'Sulphur (S)',
        value: sulphur,
        unit: 'mg/kg',
        status: sulphur >= 10
            ? NutrientStatus.sufficient
            : NutrientStatus.deficient,
        category: NutrientCategory.secondaryNutrient,
      ),
      SoilNutrientReading(
        name: 'Zinc (Zn)',
        value: zinc,
        unit: 'mg/kg',
        status: zinc >= 0.6
            ? NutrientStatus.sufficient
            : NutrientStatus.deficient,
        category: NutrientCategory.micronutrient,
      ),
      SoilNutrientReading(
        name: 'Iron (Fe)',
        value: iron,
        unit: 'mg/kg',
        status: iron >= 4.5
            ? NutrientStatus.sufficient
            : NutrientStatus.deficient,
        category: NutrientCategory.micronutrient,
      ),
      SoilNutrientReading(
        name: 'Copper (Cu)',
        value: copper,
        unit: 'mg/kg',
        status: copper >= 0.2
            ? NutrientStatus.sufficient
            : NutrientStatus.deficient,
        category: NutrientCategory.micronutrient,
      ),
      SoilNutrientReading(
        name: 'Manganese (Mn)',
        value: manganese,
        unit: 'mg/kg',
        status: manganese >= 2.0
            ? NutrientStatus.sufficient
            : NutrientStatus.deficient,
        category: NutrientCategory.micronutrient,
      ),
      SoilNutrientReading(
        name: 'Boron (B)',
        value: boron,
        unit: 'mg/kg',
        status: boron >= 0.5
            ? NutrientStatus.sufficient
            : (boron >= 0.2 ? NutrientStatus.medium : NutrientStatus.deficient),
        category: NutrientCategory.micronutrient,
      ),
    ];
  }

  /// Demo SHC records for field_a (the demo wheat field).
  /// Three historical records: 2024, 2025, and 2026 (current).
  static Map<String, List<SoilHealthCard>> get demoCards => {
    'demo_field_a': [
      // 2026 — Current verified record
      SoilHealthCard(
        id: 'shc_demo_a_2026',
        fieldId: 'demo_field_a',
        cardNumber: 'SHC-MH-2026-048721',
        sampleId: 'SS-2026-A-001',
        farmerName: 'Demo Farmer',
        fatherHusbandName: 'Shri Ramesh Kumar',
        village: 'Rampur',
        tehsil: 'Wardha',
        district: 'Wardha',
        state: 'Maharashtra',
        totalLandHolding: '9.7 acres',
        registrationDate: DateTime(2026, 5, 15),
        sampleDate: DateTime(2026, 6, 10),
        uploadDate: DateTime(2026, 6, 20),
        soilType: 'Black Cotton Soil',
        soilColour: 'Dark Brown',
        soilTexture: 'Clay Loam',
        location: 'North Block, Village Rampur',
        nutrients: _buildNutrients(
          ph: 7.4,
          ec: 0.42,
          oc: 0.68,
          nitrogen: 248,
          phosphorus: 16.2,
          potassium: 298,
          sulphur: 12.4,
          zinc: 0.82,
          iron: 6.3,
          copper: 0.46,
          manganese: 7.8,
          boron: 0.32,
        ),
        fertilizerRecommendations: [
          'Apply 120 kg Urea per hectare in two splits',
          'Apply 250 kg SSP (Single Super Phosphate) per hectare at sowing',
          'Apply 50 kg MOP (Muriate of Potash) per hectare',
        ],
        nutrientRecommendations: [
          'Organic Carbon is below optimal — add FYM (Farm Yard Manure) at 5 tonnes/hectare',
          'Boron is marginally low — apply Borax at 5 kg/hectare',
          'Maintain current Sulphur levels through organic matter',
        ],
        cropRecommendations: [
          'Wheat (Rabi) — well suited to current soil conditions',
          'Chickpea (Gram) — good for nitrogen fixation rotation',
          'Soybean (Kharif) — compatible with black cotton soil',
        ],
        sourceFileName: 'SoilHealthCard_2026_FieldA.pdf',
        isVerified: true,
        isCurrent: true,
      ),

      // 2025 — Previous verified record
      SoilHealthCard(
        id: 'shc_demo_a_2025',
        fieldId: 'demo_field_a',
        cardNumber: 'SHC-MH-2025-032415',
        sampleId: 'SS-2025-A-001',
        farmerName: 'Demo Farmer',
        fatherHusbandName: 'Shri Ramesh Kumar',
        village: 'Rampur',
        tehsil: 'Wardha',
        district: 'Wardha',
        state: 'Maharashtra',
        totalLandHolding: '9.7 acres',
        registrationDate: DateTime(2025, 4, 20),
        sampleDate: DateTime(2025, 5, 8),
        uploadDate: DateTime(2025, 5, 18),
        soilType: 'Black Cotton Soil',
        soilColour: 'Dark Brown',
        soilTexture: 'Clay Loam',
        location: 'North Block, Village Rampur',
        nutrients: _buildNutrients(
          ph: 7.2,
          ec: 0.38,
          oc: 0.62,
          nitrogen: 232,
          phosphorus: 14.8,
          potassium: 285,
          sulphur: 11.2,
          zinc: 0.74,
          iron: 5.8,
          copper: 0.42,
          manganese: 7.2,
          boron: 0.28,
        ),
        fertilizerRecommendations: [
          'Apply 130 kg Urea per hectare in two splits',
          'Apply 280 kg SSP per hectare at sowing',
          'Apply 60 kg MOP per hectare',
        ],
        nutrientRecommendations: [
          'Organic Carbon below threshold — increase FYM application',
          'Boron deficient — apply Borax at 6 kg/hectare',
          'Zinc marginally sufficient — monitor in next cycle',
        ],
        cropRecommendations: [
          'Wheat (Rabi)',
          'Cotton (Kharif)',
          'Soybean (Kharif)',
        ],
        sourceFileName: 'SoilHealthCard_2025_FieldA.pdf',
        isVerified: true,
        isCurrent: false,
      ),

      // 2024 — Oldest record
      SoilHealthCard(
        id: 'shc_demo_a_2024',
        fieldId: 'demo_field_a',
        cardNumber: 'SHC-MH-2024-019287',
        sampleId: 'SS-2024-A-001',
        farmerName: 'Demo Farmer',
        fatherHusbandName: 'Shri Ramesh Kumar',
        village: 'Rampur',
        tehsil: 'Wardha',
        district: 'Wardha',
        state: 'Maharashtra',
        totalLandHolding: '9.7 acres',
        registrationDate: DateTime(2024, 6, 1),
        sampleDate: DateTime(2024, 6, 15),
        uploadDate: DateTime(2024, 7, 1),
        soilType: 'Black Cotton Soil',
        soilColour: 'Dark Brown',
        soilTexture: 'Clay Loam',
        location: 'North Block, Village Rampur',
        nutrients: _buildNutrients(
          ph: 7.1,
          ec: 0.35,
          oc: 0.55,
          nitrogen: 218,
          phosphorus: 12.6,
          potassium: 268,
          sulphur: 9.8,
          zinc: 0.65,
          iron: 5.2,
          copper: 0.38,
          manganese: 6.5,
          boron: 0.24,
        ),
        fertilizerRecommendations: [
          'Apply 140 kg Urea per hectare',
          'Apply 300 kg SSP per hectare',
          'Apply 70 kg MOP per hectare',
        ],
        nutrientRecommendations: [
          'Organic Carbon low — urgent FYM application needed',
          'Sulphur near deficiency — apply gypsum at 200 kg/hectare',
          'Boron deficient — apply Borax at 8 kg/hectare',
        ],
        cropRecommendations: [
          'Wheat (Rabi)',
          'Gram / Chickpea (Rabi)',
        ],
        sourceFileName: 'SoilHealthCard_2024_FieldA.pdf',
        isVerified: true,
        isCurrent: false,
      ),
    ],
  };

  /// Returns sample extraction data for mock OCR processing.
  /// This simulates what a real OCR service would return.
  static SoilHealthCard sampleExtractionResult({
    required String fieldId,
    required String cardId,
    String? sourceFileName,
  }) {
    return SoilHealthCard(
      id: cardId,
      fieldId: fieldId,
      cardNumber: 'SHC-MH-2026-NEW',
      sampleId: 'SS-2026-NEW-001',
      farmerName: 'Demo Farmer',
      village: 'Village Name',
      tehsil: 'Tehsil Name',
      district: 'District Name',
      state: 'Maharashtra',
      registrationDate: DateTime.now(),
      sampleDate: DateTime.now().subtract(const Duration(days: 7)),
      uploadDate: DateTime.now(),
      soilType: 'Alluvial',
      soilColour: 'Brown',
      soilTexture: 'Sandy Loam',
      nutrients: _buildNutrients(
        ph: 7.4,
        ec: 0.42,
        oc: 0.68,
        nitrogen: 248,
        phosphorus: 16.2,
        potassium: 298,
        sulphur: 12.4,
        zinc: 0.82,
        iron: 6.3,
        copper: 0.46,
        manganese: 7.8,
        boron: 0.32,
      ),
      fertilizerRecommendations: [
        'Apply recommended dose of Urea as per crop requirement',
        'Apply SSP at sowing time',
      ],
      nutrientRecommendations: [
        'Maintain organic carbon through FYM application',
        'Monitor micronutrient levels annually',
      ],
      cropRecommendations: [
        'Suitable for most Rabi crops',
        'Consider legume rotation for nitrogen fixation',
      ],
      sourceFileName: sourceFileName,
      isVerified: false,
      isCurrent: false,
    );
  }
}
