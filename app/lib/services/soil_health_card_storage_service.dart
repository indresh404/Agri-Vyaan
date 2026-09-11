import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/soil_health_card.dart';

/// Service for managing Soil Health Card records with Supabase database & storage
/// and local storage fallback.
class SoilHealthCardStorageService {
  static const String _storageKey = 'agrivyaan_soil_health_cards';

  SupabaseClient get _supabase => Supabase.instance.client;

  /// Loads all saved Soil Health Cards from Supabase (or local storage fallback).
  /// Returns a map of fieldId -> list of SoilHealthCard records.
  Future<Map<String, List<SoilHealthCard>>> loadCards({String? fid}) async {
    final currentFid = fid ?? _supabase.auth.currentUser?.id;

    if (currentFid != null && currentFid.isNotEmpty) {
      try {
        final ownFields = await _supabase
            .from('fields')
            .select('fieldid')
            .eq('fid', currentFid);
        final fieldIds = (ownFields as List<dynamic>)
            .map((field) => field['fieldid'].toString())
            .toList();
        if (fieldIds.isEmpty) return {};
        final response = await _supabase
            .from('soil_health')
            .select()
            .inFilter('fieldid', fieldIds);

        final List<dynamic> data = response as List<dynamic>;
        final Map<String, List<SoilHealthCard>> result = {};

        for (final item in data) {
          final card = _soilHealthCardFromMap(item as Map<String, dynamic>);
          final fieldId = card.fieldId;
          if (!result.containsKey(fieldId)) {
            result[fieldId] = [];
          }
          result[fieldId]!.add(card);
        }

        // Cache locally
        await saveCards(result);
        return result;
      } catch (e) {
        debugPrint('Error fetching soil health cards from Supabase: $e');
      }
    }

    // Fallback to local storage
    return await _loadLocalCards();
  }

  /// Uploads a report file to Supabase Storage bucket `soil-reports`
  Future<String?> uploadReportFile(String filePath, String fieldId) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${filePath.split(Platform.pathSeparator).last}';
      final storagePath = '$fieldId/$fileName';

      await _supabase.storage.from('soil-reports').upload(storagePath, file);
      final publicUrl = _supabase.storage.from('soil-reports').getPublicUrl(storagePath);
      debugPrint('Soil report uploaded successfully to Supabase Storage: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading soil report file to Supabase Storage: $e');
      return null;
    }
  }

  /// Adds a single card for a field and persists to Supabase & local cache.
  Future<void> addCard(
    Map<String, List<SoilHealthCard>> allCards,
    String fieldId,
    SoilHealthCard card, {
    String? fid,
    String? localFilePath,
  }) async {
    final currentFid = fid ?? _supabase.auth.currentUser?.id ?? 'demo_farmer_id';
    String? fileUrl;

    if (localFilePath != null && localFilePath.isNotEmpty) {
      fileUrl = await uploadReportFile(localFilePath, fieldId);
    }

    final cardWithUrl = fileUrl != null ? card.copyWith(sourceFileName: fileUrl) : card;

    // Update local map
    final fieldCards = allCards[fieldId] ?? [];
    final updatedCards = fieldCards.map((c) {
      if (c.isCurrent) {
        return c.copyWith(isCurrent: false);
      }
      return c;
    }).toList();

    updatedCards.insert(0, cardWithUrl.copyWith(isCurrent: true));
    allCards[fieldId] = updatedCards;

    // Insert into Supabase
    try {
      final mapData = _soilHealthCardToMap(cardWithUrl);
      await _supabase.from('soil_health').insert(mapData);
      debugPrint('Soil Health Card record inserted into Supabase table.');
    } catch (e) {
      debugPrint('Error inserting Soil Health Card into Supabase: $e');
    }

    await saveCards(allCards);
  }

  /// Saves the full map of Soil Health Cards to SharedPreferences local storage.
  Future<void> saveCards(Map<String, List<SoilHealthCard>> cards) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> jsonMap = {};
      for (final entry in cards.entries) {
        jsonMap[entry.key] = entry.value.map((c) => c.toJson()).toList();
      }
      await prefs.setString(_storageKey, jsonEncode(jsonMap));
    } catch (_) {}
  }

  /// Gets cards for a specific field.
  List<SoilHealthCard> getCardsForField(
    Map<String, List<SoilHealthCard>> allCards,
    String fieldId,
  ) {
    return allCards[fieldId] ?? [];
  }

  /// Gets the current card for a specific field.
  SoilHealthCard? getCurrentCardForField(
    Map<String, List<SoilHealthCard>> allCards,
    String fieldId,
  ) {
    final fieldCards = allCards[fieldId] ?? [];
    try {
      return fieldCards.firstWhere((c) => c.isCurrent);
    } catch (_) {
      return fieldCards.isNotEmpty ? fieldCards.first : null;
    }
  }

  /// Updates a specific card and persists.
  Future<void> updateCard(
    Map<String, List<SoilHealthCard>> allCards,
    String fieldId,
    SoilHealthCard updatedCard, {
    String? fid,
  }) async {
    final currentFid = fid ?? _supabase.auth.currentUser?.id ?? 'demo_farmer_id';
    final fieldCards = allCards[fieldId] ?? [];
    final index = fieldCards.indexWhere((c) => c.id == updatedCard.id);
    if (index != -1) {
      fieldCards[index] = updatedCard;
      allCards[fieldId] = fieldCards;

      try {
        final mapData = _soilHealthCardToMap(updatedCard);
        await _supabase.from('soil_health').update(mapData).eq('shid', updatedCard.id);
      } catch (e) {
        debugPrint('Error updating Soil Health Card in Supabase: $e');
      }

      await saveCards(allCards);
    }
  }

  /// Clears all saved Soil Health Card data.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  // --- Map Conversions ---
  static SoilHealthCard _soilHealthCardFromMap(Map<String, dynamic> json) {
    final idStr = (json['shid'] ?? json['SHID'] ?? json['id'] ?? '').toString();
    final fieldIdStr = (json['fieldid'] ?? json['FIELDID'] ?? json['field_id'] ?? json['fieldId'] ?? '').toString();

    // Extract key soil properties if columns exist
    double phVal = (json['ph'] ?? json['pH'] as num?)?.toDouble() ?? 7.0;
    double ecVal = (json['ec'] ?? json['EC'] as num?)?.toDouble() ?? 0.8;
    double ocVal = (json['organic_carbon'] ?? json['Organic carbon'] as num?)?.toDouble() ?? 0.65;
    double nVal = (json['nitrogen'] ?? json['Nitrogen'] as num?)?.toDouble() ?? 240.0;
    double pVal = (json['phosphorus'] ?? json['Phosphorus'] as num?)?.toDouble() ?? 18.5;
    double kVal = (json['potassium'] ?? json['Potassium'] as num?)?.toDouble() ?? 210.0;

    List<SoilNutrientReading> nutrients = [];
    final rawNutrients = json['nutrients_json'] ?? json['nutrients'];
    if (rawNutrients is List) {
      nutrients = rawNutrients.map((n) => SoilNutrientReading.fromJson(n as Map<String, dynamic>)).toList();
    } else {
      // Build nutrients from standard columns
      nutrients = [
        SoilNutrientReading(name: 'pH', value: phVal, unit: '', status: NutrientStatus.normal, category: NutrientCategory.soilProperty),
        SoilNutrientReading(name: 'EC', value: ecVal, unit: 'dS/m', status: NutrientStatus.normal, category: NutrientCategory.soilProperty),
        SoilNutrientReading(name: 'Organic Carbon', value: ocVal, unit: '%', status: NutrientStatus.medium, category: NutrientCategory.soilProperty),
        SoilNutrientReading(name: 'Nitrogen (N)', value: nVal, unit: 'kg/ha', status: NutrientStatus.medium, category: NutrientCategory.macronutrient),
        SoilNutrientReading(name: 'Phosphorus (P)', value: pVal, unit: 'kg/ha', status: NutrientStatus.low, category: NutrientCategory.macronutrient),
        SoilNutrientReading(name: 'Potassium (K)', value: kVal, unit: 'kg/ha', status: NutrientStatus.normal, category: NutrientCategory.macronutrient),
      ];
    }

    return SoilHealthCard(
      id: idStr.isNotEmpty ? idStr : 'shc_${DateTime.now().millisecondsSinceEpoch}',
      fieldId: fieldIdStr,
      cardNumber: json['card_number'] as String?,
      sampleId: json['sample_id'] as String?,
      farmerName: json['farmer_name'] as String?,
      fatherHusbandName: json['father_husband_name'] as String?,
      village: json['village'] as String?,
      tehsil: json['tehsil'] as String?,
      district: json['district'] as String?,
      state: json['state'] as String?,
      totalLandHolding: json['total_land_holding'] as String?,
      uploadDate: json['upload_date'] != null ? DateTime.tryParse(json['upload_date'].toString()) ?? DateTime.now() : DateTime.now(),
      soilType: json['soil_type'] as String?,
      soilColour: json['soil_colour'] as String?,
      soilTexture: json['soil_texture'] as String?,
      location: json['location'] as String?,
      nutrients: nutrients,
      fertilizerRecommendations: List<String>.from(json['fertilizer_recommendations'] as List? ?? []),
      nutrientRecommendations: List<String>.from(json['nutrient_recommendations'] as List? ?? []),
      cropRecommendations: List<String>.from(json['crop_recommendations'] as List? ?? []),
      sourceFileName: json['source_file_url'] ?? json['source_file_name'] as String?,
      isVerified: json['is_verified'] as bool? ?? true,
      isCurrent: json['is_current'] as bool? ?? true,
    );
  }

  static Map<String, dynamic> _soilHealthCardToMap(SoilHealthCard card) {
    SoilNutrientReading? getNut(String name) {
      try {
        return card.nutrients.firstWhere((n) => n.name.toLowerCase().contains(name.toLowerCase()));
      } catch (_) {
        return null;
      }
    }

    return {
      'fieldid': card.fieldId,
      'ph': getNut('pH')?.value ?? 7.0,
      'ec': getNut('EC')?.value ?? 0.8,
      'organic_carbon': getNut('Organic Carbon')?.value ?? 0.65,
      'nitrogen': getNut('Nitrogen')?.value ?? 240.0,
      'phosphorus': getNut('Phosphorus')?.value ?? 18.5,
      'potassium': getNut('Potassium')?.value ?? 210.0,
      'sulphur': getNut('Sulphur')?.value,
      'zinc': getNut('Zinc')?.value,
      'iron': getNut('Iron')?.value,
      'copper': getNut('Copper')?.value,
      'magnesium': getNut('Magnesium')?.value,
      'boron': getNut('Boron')?.value,
    };
  }

  Future<Map<String, List<SoilHealthCard>>> _loadLocalCards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString == null || jsonString.isEmpty) return {};
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final Map<String, List<SoilHealthCard>> result = {};
      for (final entry in jsonMap.entries) {
        final List<dynamic> cardList = entry.value as List<dynamic>;
        result[entry.key] = cardList.map((item) => SoilHealthCard.fromJson(item as Map<String, dynamic>)).toList();
      }
      return result;
    } catch (_) {
      return {};
    }
  }
}
