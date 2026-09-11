import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/farm_field.dart';

/// Service for persisting field data with Supabase PostgreSQL database
/// according to schema:
/// - fieldid (uuid, primary key)
/// - fid (uuid, foreign key to users.fid)
/// - user_name (text)
/// - field_name (text)
/// - field_number (integer)
/// - crop_name (text)
/// - area (numeric)
/// - latitude (double precision)
/// - longitude (double precision)
class FieldStorageService {
  static const String _storageKey = 'agrivyaan_fields';
  static const _uuidPattern = r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$';

  SupabaseClient get _supabase => Supabase.instance.client;

  static bool isUuid(String? id) {
    if (id == null || id.isEmpty) return false;
    return RegExp(_uuidPattern, caseSensitive: false).hasMatch(id);
  }

  String _getStorageKey(String? fid) =>
      (fid != null && fid.isNotEmpty) ? 'agrivyaan_fields_$fid' : 'agrivyaan_fields_guest';

  /// Ensures a valid user UUID exists in the users table to satisfy foreign key constraint.
  Future<String> _ensureValidUserFid(String? requestedFid, {String? userName, String? phone}) async {
    final authUser = _supabase.auth.currentUser;
    final candidateFid = requestedFid ?? authUser?.id;

    // 1. If candidateFid is a valid UUID, verify if it exists in users table
    if (isUuid(candidateFid)) {
      try {
        final existing = await _supabase
            .from('users')
            .select('fid')
            .eq('fid', candidateFid!)
            .maybeSingle();

        if (existing != null && existing['fid'] != null) {
          return candidateFid;
        }

        // Check if user exists by auth_id
        if (authUser != null) {
          final byAuth = await _supabase
              .from('users')
              .select('fid')
              .eq('auth_id', authUser.id)
              .maybeSingle();
          if (byAuth != null && byAuth['fid'] != null) {
            return byAuth['fid'].toString();
          }
        }
      } catch (e) {
        debugPrint('Error checking user fid in Supabase: $e');
      }
    }

    // 2. Create a unique user profile for this specific user
    try {
      final newFid = isUuid(candidateFid) ? candidateFid! : const Uuid().v4();
      final insertData = <String, dynamic>{
        'fid': newFid,
        'name': (userName != null && userName.isNotEmpty) ? userName : 'Farmer',
        'location': 'Wardha, Maharashtra',
      };
      if (phone != null && phone.isNotEmpty) {
        insertData['phone_no'] = phone;
      } else if (authUser?.phone != null && authUser!.phone!.isNotEmpty) {
        insertData['phone_no'] = authUser.phone;
      }
      if (authUser != null) {
        insertData['auth_id'] = authUser.id;
      }
      await _supabase.from('users').insert(insertData);
      debugPrint('Created new user profile in Supabase with fid: $newFid');
      return newFid;
    } catch (e) {
      debugPrint('Error creating user in Supabase: $e');
      return isUuid(candidateFid) ? candidateFid! : const Uuid().v4();
    }
  }

  /// Loads fields belonging strictly to farmer [fid] from Supabase, falling back to local cache.
  Future<List<FarmField>> loadFields({String? fid}) async {
    final currentFid = fid ?? _supabase.auth.currentUser?.id;

    // Strict user isolation: If no fid is provided, do NOT load all fields from other users!
    if (currentFid == null || currentFid.isEmpty || !isUuid(currentFid)) {
      return await _loadLocalFields(fid: currentFid);
    }

    try {
      final response = await _supabase
          .from('fields')
          .select()
          .eq('fid', currentFid)
          .order('field_number', ascending: true);

      if (response is List) {
        final fields = response
            .map((item) => farmFieldFromMap(item as Map<String, dynamic>))
            .toList();

        // Cache locally for this specific user
        await _cacheLocalFields(fields, fid: currentFid);
        return fields;
      }
    } catch (e) {
      debugPrint('Error fetching fields from Supabase: $e');
    }

    // Fallback to local storage for this specific user
    return await _loadLocalFields(fid: currentFid);
  }

  /// Saves / inserts a single field into Supabase and local cache.
  Future<FarmField> addField(
    List<FarmField> fields,
    FarmField field, {
    String? fid,
    String? userName,
  }) async {
    final validFid = await _ensureValidUserFid(fid, userName: userName ?? field.userName);
    
    // Ensure field has a valid UUID for fieldid
    String fieldIdToUse = field.id;
    if (!isUuid(fieldIdToUse)) {
      fieldIdToUse = const Uuid().v4();
    }
    
    final updatedField = field.copyWith(id: fieldIdToUse, fid: validFid);
    final mapData = farmFieldToMap(updatedField, validFid, userName: userName);

    try {
      final res = await _supabase
          .from('fields')
          .insert(mapData)
          .select()
          .maybeSingle();

      if (res != null) {
        final inserted = farmFieldFromMap(res);
        debugPrint('Field "${inserted.name}" (ID: ${inserted.id}, #${inserted.fieldNumber}) saved to Supabase fields table.');
        fields.add(inserted);
        await _cacheLocalFields(fields, fid: validFid);
        return inserted;
      }
    } catch (e) {
      debugPrint('Error inserting field to Supabase: $e');
      rethrow;
    }

    fields.add(updatedField);
    await _cacheLocalFields(fields, fid: validFid);
    return updatedField;
  }

  /// Updates a field in Supabase and local cache.
  Future<void> updateField(
    List<FarmField> fields,
    FarmField updated, {
    String? fid,
    String? userName,
  }) async {
    final validFid = await _ensureValidUserFid(fid, userName: userName ?? updated.userName);
    final index = fields.indexWhere((f) => f.id == updated.id);
    if (index != -1) {
      fields[index] = updated;
    }

    try {
      final mapData = farmFieldToMap(updated, validFid, userName: userName);
      mapData.remove('fieldid'); // Don't include primary key in update payload
      
      await _supabase.from('fields').update(mapData).eq('fieldid', updated.id);
      debugPrint('Field "${updated.name}" updated in Supabase.');
    } catch (e) {
      debugPrint('Error updating field in Supabase: $e');
      rethrow;
    }

    await _cacheLocalFields(fields, fid: validFid);
  }

  /// Deletes a field by ID from Supabase and local cache.
  Future<void> deleteField(List<FarmField> fields, String id, {String? fid}) async {
    fields.removeWhere((f) => f.id == id);

    try {
      await _supabase.from('fields').delete().eq('fieldid', id);
      debugPrint('Field ID $id deleted from Supabase.');
    } catch (e) {
      debugPrint('Error deleting field from Supabase: $e');
      rethrow;
    }

    await _cacheLocalFields(fields, fid: fid);
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
    final fidStr = (json['fid'] ?? '').toString();
    final userNameStr = (json['user_name'] ?? json['userName'] ?? json['farmer_name'] ?? 'Farmer').toString();
    final fieldNameStr = (json['field_name'] ?? json['name'] ?? json['FieldName'] ?? 'Field').toString();
    final fieldNumVal = (json['field_number'] ?? json['fieldNumber'] ?? json['field_no'] as num?)?.toInt() ?? 1;
    final cropStr = (json['crop_name'] ?? json['crop'] ?? json['Crop'] ?? 'Cotton').toString();
    final areaVal = (json['area'] ?? json['Area'] as num?)?.toDouble() ?? 1.0;
    final latVal = (json['latitude'] ?? json['lat'] as num?)?.toDouble() ?? 20.7453;
    final lngVal = (json['longitude'] ?? json['lng'] as num?)?.toDouble() ?? 78.6022;

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
    } else {
      zones = [
        FieldZone(
          name: 'Zone 1',
          healthScore: (json['health_score'] as num?)?.toDouble() ?? 80.0,
          soilMoisture: (json['soil_moisture'] as num?)?.toDouble() ?? 50.0,
          temperature: (json['temperature'] as num?)?.toDouble() ?? 28.0,
          humidity: (json['humidity'] as num?)?.toDouble() ?? 60.0,
        ),
      ];
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
      id: idStr.isNotEmpty ? idStr : const Uuid().v4(),
      fid: fidStr.isNotEmpty ? fidStr : null,
      userName: userNameStr,
      name: fieldNameStr,
      fieldNumber: fieldNumVal,
      crop: cropStr,
      area: areaVal,
      latitude: latVal,
      longitude: lngVal,
      location: (json['location'] ?? 'Lat: $latVal, Long: $lngVal').toString(),
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

  /// Converts a FarmField to a Map matching public.fields columns:
  /// - fieldid
  /// - fid
  /// - user_name
  /// - field_name
  /// - field_number
  /// - crop_name
  /// - area
  /// - latitude
  /// - longitude
  static Map<String, dynamic> farmFieldToMap(FarmField field, String fid, {String? userName}) {
    final map = <String, dynamic>{
      'fid': fid,
      'user_name': (userName != null && userName.isNotEmpty)
          ? userName
          : (field.userName.isNotEmpty ? field.userName : 'Farmer'),
      'field_name': field.name.isNotEmpty ? field.name : '${field.crop} Field',
      'field_number': field.fieldNumber,
      'crop_name': field.crop.isNotEmpty ? field.crop : 'Cotton',
      'area': field.area,
      'latitude': field.latitude,
      'longitude': field.longitude,
    };

    if (isUuid(field.id)) {
      map['fieldid'] = field.id;
    }
    return map;
  }

  Future<void> _cacheLocalFields(List<FarmField> fields, {String? fid}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = fields.map((f) => f.toJson()).toList();
      await prefs.setString(_getStorageKey(fid), jsonEncode(jsonList));
    } catch (_) {}
  }

  Future<List<FarmField>> _loadLocalFields({String? fid}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_getStorageKey(fid));
      if (jsonString == null || jsonString.isEmpty) return [];
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((item) => FarmField.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}
