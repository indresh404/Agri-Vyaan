import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/farm_field.dart';

/// Service for persisting field data with Supabase PostgreSQL database
/// and local storage fallback.
class FieldStorageService {
  static const String _storageKey = 'agrivyaan_fields';

  SupabaseClient get _supabase => Supabase.instance.client;

  /// Loads fields belonging to farmer [fid] from Supabase, falling back to local cache.
  Future<List<FarmField>> loadFields({String? fid}) async {
    final currentFid = fid ?? _supabase.auth.currentUser?.id;

    if (currentFid != null && currentFid.isNotEmpty) {
      try {
        final response = await _supabase
            .from('fields')
            .select()
            .eq('fid', currentFid);

        final List<dynamic> data = response as List<dynamic>;
        final fields = data
            .map((item) => farmFieldFromMap(item as Map<String, dynamic>))
            .toList();

        // Cache locally for offline availability
        await _cacheLocalFields(fields);
        return fields;
      } catch (e) {
        debugPrint('Error fetching fields from Supabase: $e');
      }
    }

    // Fallback to local storage
    return await _loadLocalFields();
  }

  /// Saves / inserts a single field into Supabase and local cache.
  Future<void> addField(List<FarmField> fields, FarmField field, {String? fid}) async {
    final currentFid = fid ?? _supabase.auth.currentUser?.id;
    if (currentFid == null || currentFid.isEmpty) {
      throw StateError('A saved farmer profile is required before adding a field.');
    }
    final mapData = farmFieldToMap(field, currentFid);

    try {
      await _supabase.from('fields').insert(mapData);
      debugPrint('Field "${field.name}" saved to Supabase fields table.');
    } catch (e) {
      debugPrint('Error inserting field to Supabase: $e');
    }

    // Update local list & cache
    fields.add(field);
    await _cacheLocalFields(fields);
  }

  /// Updates a field in Supabase and local cache.
  Future<void> updateField(List<FarmField> fields, FarmField updated, {String? fid}) async {
    final currentFid = fid ?? _supabase.auth.currentUser?.id;
    if (currentFid == null || currentFid.isEmpty) {
      throw StateError('A saved farmer profile is required before updating a field.');
    }
    final index = fields.indexWhere((f) => f.id == updated.id);
    if (index != -1) {
      fields[index] = updated;
    }

    try {
      final mapData = farmFieldToMap(updated, currentFid);
      await _supabase.from('fields').update(mapData).eq('fieldid', updated.id);
      debugPrint('Field "${updated.name}" updated in Supabase.');
    } catch (e) {
      debugPrint('Error updating field in Supabase: $e');
    }

    await _cacheLocalFields(fields);
  }

  /// Deletes a field by ID from Supabase and local cache.
  Future<void> deleteField(List<FarmField> fields, String id) async {
    fields.removeWhere((f) => f.id == id);

    try {
      await _supabase.from('fields').delete().eq('fieldid', id);
      debugPrint('Field ID $id deleted from Supabase.');
    } catch (e) {
      debugPrint('Error deleting field from Supabase: $e');
    }

    await _cacheLocalFields(fields);
  }

  /// Saves full list to local SharedPreferences cache.
  Future<void> saveFields(List<FarmField> fields) async {
    await _cacheLocalFields(fields);
  }

  /// Clears local storage.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  // --- Helpers for Map Conversion ---

  static FarmField farmFieldFromMap(Map<String, dynamic> json) {
    final idStr = (json['fieldid'] ?? json['FIELDID'] ?? json['id'] ?? '').toString();
    final cropStr = (json['crop'] ?? json['Crop'] ?? 'Cotton').toString();
    final nameStr = '$cropStr Field';
    final areaVal = (json['area'] ?? json['Area'] as num?)?.toDouble() ?? 1.0;
    final locationStr = 'Lat: ${json['latitude'] ?? ''}, Long: ${json['longitude'] ?? ''}';

    DateTime sowing;
    try {
      sowing = DateTime.parse(json['sowing_date'] ?? json['sowingDate'] ?? DateTime.now().toIso8601String());
    } catch (_) {
      sowing = DateTime.now();
    }

    DateTime lastScanDate;
    try {
      lastScanDate = DateTime.parse(json['last_scan'] ?? json['lastScan'] ?? DateTime.now().toIso8601String());
    } catch (_) {
      lastScanDate = DateTime.now();
    }

    List<FieldZone> zones = [];
    final rawZones = json['zones_json'] ?? json['zones'];
    if (rawZones is List) {
      zones = rawZones.map((z) => FieldZone.fromJson(z as Map<String, dynamic>)).toList();
    }

    List<FieldProblem> problems = [];
    final rawProblems = json['problems_json'] ?? json['problems'];
    if (rawProblems is List) {
      problems = rawProblems.map((p) => FieldProblem.fromJson(p as Map<String, dynamic>)).toList();
    }

    List<FieldImprovement> improvements = [];
    final rawImprovements = json['improvements_json'] ?? json['improvements'];
    if (rawImprovements is List) {
      improvements = rawImprovements.map((i) => FieldImprovement.fromJson(i as Map<String, dynamic>)).toList();
    }

    return FarmField(
      id: idStr.isNotEmpty ? idStr : 'field_${DateTime.now().millisecondsSinceEpoch}',
      name: nameStr,
      crop: cropStr,
      area: areaVal,
      location: locationStr,
      sowingDate: sowing,
      notes: json['notes'] as String?,
      healthScore: (json['health_score'] ?? json['healthScore'] as num?)?.toDouble() ?? 80.0,
      soilMoisture: (json['soil_moisture'] ?? json['soilMoisture'] as num?)?.toDouble() ?? 50.0,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 28.0,
      humidity: (json['humidity'] as num?)?.toDouble() ?? 60.0,
      lastScan: lastScanDate,
      zones: zones,
      problems: problems,
      improvements: improvements,
      isDemoData: json['isDemoData'] as bool? ?? false,
    );
  }

  static Map<String, dynamic> farmFieldToMap(FarmField field, String fid) {
    final map = <String, dynamic>{
      'fid': fid,
      'name': field.name.isNotEmpty ? field.name : '${field.crop} Field',
      'crop': field.crop,
      'area': field.area,
      'latitude': _coordinate(field.location, 'lat') ?? 20.7453,
      'longitude': _coordinate(field.location, 'long') ?? 78.6022,
    };
    if (RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$', caseSensitive: false)
        .hasMatch(field.id)) {
      map['fieldid'] = field.id;
    }
    return map;
  }

  static double? _coordinate(String text, String label) {
    final match = RegExp('$label(?:itude)?\\s*[:=]\\s*(-?\\d+(?:\\.\\d+)?)', caseSensitive: false)
        .firstMatch(text);
    return match == null ? null : double.tryParse(match.group(1)!);
  }

  Future<void> _cacheLocalFields(List<FarmField> fields) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = fields.map((f) => f.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  Future<List<FarmField>> _loadLocalFields() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString == null || jsonString.isEmpty) return [];
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((item) => FarmField.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}
