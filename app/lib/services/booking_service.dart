import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

/// Service for managing drone scan bookings with Supabase database.
class BookingService {
  static const String _storageKey = 'agrivyaan_bookings';

  SupabaseClient get _supabase => Supabase.instance.client;

  /// Fetch all drone scan bookings for the current farmer FID.
  Future<List<DroneScan>> loadBookings(String fid) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select()
          .eq('fid', fid);

      final List<dynamic> data = response as List<dynamic>;
      final bookings = data.map((json) => _droneScanFromMap(json as Map<String, dynamic>)).toList();

      // Cache locally
      await _cacheBookingsLocally(bookings);
      return bookings;
    } catch (e) {
      debugPrint('Error loading bookings from Supabase: $e');
      // Fallback to local storage
      return await _loadLocalBookings();
    }
  }

  /// Create a new booking in Supabase.
  Future<DroneScan?> createBooking({
    required String fid,
    required String fieldId,
    required String scanType,
    required String date,
    required String time,
  }) async {
    final id = '';
    var scan = DroneScan(
      id: id,
      fieldId: fieldId,
      scanType: scanType,
      date: date,
      time: time,
      operatorName: 'Pending Assignment',
      status: DroneScanStatus.requested,
      verificationStatus: 'PENDING',
    );

    final mapData = {
      'fid': fid,
      'fieldid': fieldId,
      'date': date,
      'status': 'Pending',
    };

    try {
      final saved = await _supabase.from('bookings').insert(mapData).select().single();
      scan = scan.copyWith(id: saved['booking_id'].toString());
      debugPrint('Booking created in Supabase successfully.');
    } catch (e) {
      debugPrint('Supabase booking creation fallback to local: $e');
    }

    // Always update local cache
    final local = await _loadLocalBookings();
    local.insert(0, scan);
    await _cacheBookingsLocally(local);

    return scan;
  }

  /// Update booking status.
  Future<void> updateBookingStatus(String bookingId, DroneScanStatus newStatus, {String? operatorName, String? verificationStatus, int? healthScore}) async {
    try {
      final updateData = <String, dynamic>{
        'status': newStatus.name,
      };
      await _supabase.from('bookings').update(updateData).eq('booking_id', bookingId);
    } catch (e) {
      debugPrint('Error updating booking status in Supabase: $e');
    }
  }

  // --- Local Cache Helpers ---
  Future<void> _cacheBookingsLocally(List<DroneScan> bookings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = bookings.map((s) => _droneScanToMap(s)).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  Future<List<DroneScan>> _loadLocalBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString == null || jsonString.isEmpty) return [];
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((item) => _droneScanFromMap(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static DroneScan _droneScanFromMap(Map<String, dynamic> json) {
    DroneScanStatus status = DroneScanStatus.requested;
    final statusStr = (json['status'] ?? json['Status'] ?? '').toString();
    try {
      status = DroneScanStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == statusStr.toLowerCase() || e.displayName.toLowerCase() == statusStr.toLowerCase(),
        orElse: () => DroneScanStatus.requested,
      );
    } catch (_) {}

    return DroneScan(
      id: (json['booking_id'] ?? json['id'] ?? json['ID'] ?? '').toString(),
      fieldId: (json['fieldid'] ?? json['field_id'] ?? json['FIELDID'] ?? json['fieldId'] ?? '').toString(),
      scanType: (json['scan_type'] ?? json['scanType'] ?? json['ScanType'] ?? 'Crop Health Scan').toString(),
      date: (json['date'] ?? json['Date'] ?? '2026-08-27').toString(),
      time: (json['time'] ?? json['Time'] ?? '10:00 AM').toString(),
      operatorName: (json['operator_name'] ?? json['operatorName'] ?? 'Pending Assignment').toString(),
      status: status,
      verificationStatus: (json['verification_status'] ?? json['verificationStatus'] ?? 'PENDING').toString(),
      healthScore: (json['health_score'] as num?)?.toInt() ?? 80,
      aiReportData: json['ai_report_data'] as Map<String, dynamic>?,
    );
  }

  static Map<String, dynamic> _droneScanToMap(DroneScan scan) => {
        'id': scan.id,
        'fieldid': scan.fieldId,
        'scan_type': scan.scanType,
        'date': scan.date,
        'time': scan.time,
        'operator_name': scan.operatorName,
        'status': scan.status.name,
        'verification_status': scan.verificationStatus,
        'health_score': scan.healthScore,
        'ai_report_data': scan.aiReportData,
      };
}
