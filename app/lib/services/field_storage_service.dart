import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/farm_field.dart';

/// Service for persisting field data locally using SharedPreferences.
/// Designed to be replaced with a real backend service later.
class FieldStorageService {
  static const String _storageKey = 'agrivyaan_fields';

  /// Loads all saved fields from local storage.
  Future<List<FarmField>> loadFields() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((item) => FarmField.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Saves the full list of fields to local storage.
  Future<void> saveFields(List<FarmField> fields) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = fields.map((f) => f.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  /// Adds a single field and persists.
  Future<void> addField(List<FarmField> fields, FarmField field) async {
    fields.add(field);
    await saveFields(fields);
  }

  /// Updates a field by ID and persists.
  Future<void> updateField(List<FarmField> fields, FarmField updated) async {
    final index = fields.indexWhere((f) => f.id == updated.id);
    if (index != -1) {
      fields[index] = updated;
      await saveFields(fields);
    }
  }

  /// Deletes a field by ID and persists.
  Future<void> deleteField(List<FarmField> fields, String id) async {
    fields.removeWhere((f) => f.id == id);
    await saveFields(fields);
  }

  /// Clears all saved fields (useful for reset / testing).
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
