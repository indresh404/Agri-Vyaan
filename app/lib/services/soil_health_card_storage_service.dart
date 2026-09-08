import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/soil_health_card.dart';

/// Service for persisting Soil Health Card data locally using SharedPreferences.
/// Follows the same pattern as FieldStorageService.
/// Designed to be replaced with a real backend service later.
class SoilHealthCardStorageService {
  static const String _storageKey = 'agrivyaan_soil_health_cards';

  /// Loads all saved Soil Health Cards from local storage.
  /// Returns a map of fieldId -> list of SoilHealthCard records.
  Future<Map<String, List<SoilHealthCard>>> loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) {
      return {};
    }
    final Map<String, dynamic> jsonMap =
        jsonDecode(jsonString) as Map<String, dynamic>;
    final Map<String, List<SoilHealthCard>> result = {};
    for (final entry in jsonMap.entries) {
      final List<dynamic> cardList = entry.value as List<dynamic>;
      result[entry.key] = cardList
          .map((item) =>
              SoilHealthCard.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return result;
  }

  /// Saves the full map of Soil Health Cards to local storage.
  Future<void> saveCards(Map<String, List<SoilHealthCard>> cards) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> jsonMap = {};
    for (final entry in cards.entries) {
      jsonMap[entry.key] = entry.value.map((c) => c.toJson()).toList();
    }
    await prefs.setString(_storageKey, jsonEncode(jsonMap));
  }

  /// Adds a single card for a field and persists.
  Future<void> addCard(
    Map<String, List<SoilHealthCard>> allCards,
    String fieldId,
    SoilHealthCard card,
  ) async {
    // Mark previous current card as non-current
    final fieldCards = allCards[fieldId] ?? [];
    final updatedCards = fieldCards.map((c) {
      if (c.isCurrent) {
        return c.copyWith(isCurrent: false);
      }
      return c;
    }).toList();

    // Add new card as current
    updatedCards.insert(0, card.copyWith(isCurrent: true));
    allCards[fieldId] = updatedCards;

    await saveCards(allCards);
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
    SoilHealthCard updatedCard,
  ) async {
    final fieldCards = allCards[fieldId] ?? [];
    final index = fieldCards.indexWhere((c) => c.id == updatedCard.id);
    if (index != -1) {
      fieldCards[index] = updatedCard;
      allCards[fieldId] = fieldCards;
      await saveCards(allCards);
    }
  }

  /// Clears all saved Soil Health Card data.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
