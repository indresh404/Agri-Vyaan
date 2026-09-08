import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/models/soil_health_card.dart';
import 'package:app/services/app_state.dart';
import 'package:app/services/soil_health_card_demo_data.dart';
import 'package:app/services/soil_health_card_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SoilNutrientReading & Enums', () {
    test('NutrientStatus display names and serialization', () {
      expect(NutrientStatus.low.displayName, 'Low');
      expect(NutrientStatus.sufficient.displayName, 'Sufficient');
      expect(NutrientStatus.deficient.displayName, 'Deficient');
      expect(NutrientStatus.normal.displayName, 'Normal');

      expect(NutrientStatus.fromJson('low'), NutrientStatus.low);
      expect(NutrientStatus.fromJson('high'), NutrientStatus.high);
      expect(NutrientStatus.fromJson('unknown'), NutrientStatus.normal);
    });

    test('NutrientCategory display names and serialization', () {
      expect(NutrientCategory.soilProperty.displayName, 'Soil Properties');
      expect(NutrientCategory.macronutrient.displayName, 'Macronutrients');
      expect(NutrientCategory.secondaryNutrient.displayName, 'Secondary Nutrients');
      expect(NutrientCategory.micronutrient.displayName, 'Micronutrients');

      expect(NutrientCategory.fromJson('micronutrient'), NutrientCategory.micronutrient);
      expect(NutrientCategory.fromJson('unknown'), NutrientCategory.soilProperty);
    });

    test('SoilNutrientReading toJson and fromJson roundtrip', () {
      final reading = SoilNutrientReading(
        name: 'pH',
        value: 7.4,
        unit: 'pH',
        status: NutrientStatus.normal,
        category: NutrientCategory.soilProperty,
      );

      final json = reading.toJson();
      final restored = SoilNutrientReading.fromJson(json);

      expect(restored.name, 'pH');
      expect(restored.value, 7.4);
      expect(restored.unit, 'pH');
      expect(restored.status, NutrientStatus.normal);
      expect(restored.category, NutrientCategory.soilProperty);
    });
  });

  group('SoilHealthCard Model', () {
    test('toJson, fromJson, and JSON string roundtrip', () {
      final card = SoilHealthCard(
        id: 'test-card-1',
        fieldId: 'field_a',
        cardNumber: 'SHC-2026-TEST',
        sampleId: 'SMPL-001',
        farmerName: 'Ramesh Patel',
        village: 'Wardha',
        state: 'Maharashtra',
        uploadDate: DateTime(2026, 3, 1),
        sampleDate: DateTime(2026, 2, 15),
        registrationDate: DateTime(2026, 2, 10),
        soilType: 'Medium Black',
        isVerified: true,
        isCurrent: true,
        nutrients: [
          SoilNutrientReading(
            name: 'Available Nitrogen (N)',
            value: 248.0,
            unit: 'kg/ha',
            status: NutrientStatus.low,
            category: NutrientCategory.macronutrient,
          ),
          SoilNutrientReading(
            name: 'pH',
            value: 7.4,
            unit: '',
            status: NutrientStatus.normal,
            category: NutrientCategory.soilProperty,
          ),
        ],
        fertilizerRecommendations: ['Apply 50 kg Urea/ha'],
        cropRecommendations: ['Wheat', 'Gram'],
      );

      final json = card.toJson();
      final restored = SoilHealthCard.fromJson(json);

      expect(restored.id, 'test-card-1');
      expect(restored.fieldId, 'field_a');
      expect(restored.cardNumber, 'SHC-2026-TEST');
      expect(restored.farmerName, 'Ramesh Patel');
      expect(restored.isVerified, isTrue);
      expect(restored.isCurrent, isTrue);
      expect(restored.nutrients.length, 2);
      expect(restored.fertilizerRecommendations, ['Apply 50 kg Urea/ha']);
      expect(restored.cropRecommendations, ['Wheat', 'Gram']);

      // Check helper methods
      expect(restored.getNutrient('pH')?.value, 7.4);
      expect(restored.getNutrient('Available Nitrogen (N)')?.status, NutrientStatus.low);
      expect(restored.getNutrient('NonExistent'), isNull);

      final macros = restored.getNutrientsByCategory(NutrientCategory.macronutrient);
      expect(macros.length, 1);
      expect(macros.first.name, 'Available Nitrogen (N)');

      // String roundtrip
      final str = card.toJsonString();
      final fromStr = SoilHealthCard.fromJsonString(str);
      expect(fromStr.id, card.id);
    });

    test('copyWith properly modifies specified fields', () {
      final original = SoilHealthCard(
        id: 'orig-id',
        fieldId: 'field-1',
        uploadDate: DateTime(2026, 1, 1),
        isCurrent: false,
      );

      final copied = original.copyWith(isCurrent: true, farmerName: 'New Farmer');
      expect(copied.id, 'orig-id');
      expect(copied.fieldId, 'field-1');
      expect(copied.isCurrent, isTrue);
      expect(copied.farmerName, 'New Farmer');
    });
  });

  group('SoilHealthCardDemoData', () {
    test('provides demo records for demo_field_a', () {
      final cards = SoilHealthCardDemoData.demoCards['demo_field_a'];
      expect(cards, isNotNull);
      expect(cards!.length, 3);

      final current = cards.firstWhere((c) => c.isCurrent);
      expect(current.cardNumber, 'SHC-MH-2026-048721');
      expect(current.isVerified, isTrue);

      final ph = current.getNutrient('pH');
      expect(ph, isNotNull);
      expect(ph!.value, 7.4);

      final n = current.getNutrient('Available Nitrogen (N)');
      expect(n, isNotNull);
      expect(n!.value, 248.0);
    });
  });

  group('SoilHealthCardStorageService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('saves and loads cards correctly', () async {
      final service = SoilHealthCardStorageService();

      final card = SoilHealthCard(
        id: 'storage-1',
        fieldId: 'field_b',
        uploadDate: DateTime.now(),
        isCurrent: true,
      );

      await service.addCard({}, 'field_b', card);
      final loaded = await service.loadCards();

      expect(loaded.containsKey('field_b'), isTrue);
      expect(loaded['field_b']!.length, 1);
      expect(loaded['field_b']!.first.id, 'storage-1');
      expect(loaded['field_b']!.first.isCurrent, isTrue);
    });
  });

  group('AppState Soil Health Card integration', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initializes with demo cards and handles adding new card', () async {
      final appState = AppState();

      // Field A should have demo cards
      final fieldACards = appState.getCardsForField('demo_field_a');
      expect(fieldACards.length, 3);

      final currentFieldA = appState.getCurrentCardForField('demo_field_a');
      expect(currentFieldA, isNotNull);
      expect(currentFieldA!.cardNumber, 'SHC-MH-2026-048721');

      // Field B should have no cards initially
      final fieldBCards = appState.getCardsForField('field_b');
      expect(fieldBCards.isEmpty, isTrue);
      expect(appState.getCurrentCardForField('field_b'), isNull);

      // Add a card to Field B
      final newCard = SoilHealthCard(
        id: 'new-b-1',
        fieldId: 'field_b',
        cardNumber: 'SHC-NEW-B',
        uploadDate: DateTime.now(),
        isVerified: true,
      );

      await appState.addSoilHealthCard('field_b', newCard);

      final updatedBCards = appState.getCardsForField('field_b');
      expect(updatedBCards.length, 1);
      expect(updatedBCards.first.cardNumber, 'SHC-NEW-B');
      expect(updatedBCards.first.isCurrent, isTrue);

      final currentB = appState.getCurrentCardForField('field_b');
      expect(currentB, isNotNull);
      expect(currentB!.id, 'new-b-1');
    });

    test('adding a second card sets previous current to false', () async {
      final appState = AppState();

      final card1 = SoilHealthCard(
        id: 'c1',
        fieldId: 'field_c',
        uploadDate: DateTime(2025, 1, 1),
      );
      await appState.addSoilHealthCard('field_c', card1);

      final card2 = SoilHealthCard(
        id: 'c2',
        fieldId: 'field_c',
        uploadDate: DateTime(2026, 1, 1),
      );
      await appState.addSoilHealthCard('field_c', card2);

      final cards = appState.getCardsForField('field_c');
      expect(cards.length, 2);
      expect(cards[0].id, 'c2');
      expect(cards[0].isCurrent, isTrue);
      expect(cards[1].id, 'c1');
      expect(cards[1].isCurrent, isFalse);

      final current = appState.getCurrentCardForField('field_c');
      expect(current!.id, 'c2');
    });
  });
}
