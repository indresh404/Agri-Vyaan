import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/farm_field.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../services/field_storage_service.dart';
import '../utils/app_theme.dart';

/// Available crop types for the crop selector.
const List<String> _cropOptions = [
  'Cotton',
  'Wheat',
  'Paddy',
  'Soybean',
  'Tomato',
  'Potato',
  'Maize',
  'Rice',
  'Sugarcane',
  'Other',
];

/// Form screen for adding a new field or editing an existing one,
/// fully integrated with Supabase `public.fields` table:
/// - fieldid (uuid)
/// - fid (uuid foreign key)
/// - user_name (text)
/// - field_name (text)
/// - field_number (integer)
/// - crop_name (text)
/// - area (numeric)
/// - latitude (double precision)
/// - longitude (double precision)
class AddFieldScreen extends StatefulWidget {
  final List<FarmField> fields;
  final FieldStorageService storageService;
  final FarmField? existingField; // non-null = edit mode
  final String? defaultFid;
  final String? defaultUserName;

  const AddFieldScreen({
    super.key,
    required this.fields,
    required this.storageService,
    this.existingField,
    this.defaultFid,
    this.defaultUserName,
  });

  @override
  State<AddFieldScreen> createState() => _AddFieldScreenState();
}

class _AddFieldScreenState extends State<AddFieldScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _fieldNumberCtrl;
  late final TextEditingController _userNameCtrl;
  late final TextEditingController _cropCtrl;
  late final TextEditingController _areaCtrl;
  late final TextEditingController _latitudeCtrl;
  late final TextEditingController _longitudeCtrl;
  late final TextEditingController _notesCtrl;

  String _selectedCrop = 'Cotton';
  bool _isCustomCrop = false;
  DateTime _sowingDate = DateTime.now();
  bool _isSaving = false;

  bool get _isEditMode => widget.existingField != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingField;

    _nameCtrl = TextEditingController(text: existing?.name ?? '');
    
    // Auto-calculate next field number if adding a new field
    final defaultFieldNum = existing?.fieldNumber ?? (widget.fields.length + 1);
    _fieldNumberCtrl = TextEditingController(text: defaultFieldNum.toString());

    _userNameCtrl = TextEditingController(
      text: existing?.userName ?? widget.defaultUserName ?? 'Farmer',
    );

    _selectedCrop = existing != null
        ? (_cropOptions.contains(existing.crop) ? existing.crop : 'Other')
        : 'Cotton';
    _isCustomCrop = existing != null && !_cropOptions.contains(existing.crop);
    _cropCtrl = TextEditingController(text: existing?.crop ?? 'Cotton');

    _areaCtrl = TextEditingController(
      text: existing != null ? existing.area.toString() : '2.5',
    );

    _latitudeCtrl = TextEditingController(
      text: existing != null ? existing.latitude.toString() : '20.7453',
    );
    _longitudeCtrl = TextEditingController(
      text: existing != null ? existing.longitude.toString() : '78.6022',
    );

    _notesCtrl = TextEditingController(text: existing?.notes ?? '');

    if (existing != null) {
      _sowingDate = existing.sowingDate;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Try to prefill user name from AppState if available and still at default
    if (!_isEditMode && _userNameCtrl.text == 'Farmer') {
      try {
        final appState = AppStateProvider.of(context);
        final profileName = appState.currentProfile?.name;
        if (profileName != null && profileName.isNotEmpty) {
          _userNameCtrl.text = profileName;
        }
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _fieldNumberCtrl.dispose();
    _userNameCtrl.dispose();
    _cropCtrl.dispose();
    _areaCtrl.dispose();
    _latitudeCtrl.dispose();
    _longitudeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _usePresetCoordinates(double lat, double lng, String label) {
    setState(() {
      _latitudeCtrl.text = lat.toStringAsFixed(4);
      _longitudeCtrl.text = lng.toStringAsFixed(4);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Coordinates set for $label ($lat, $lng)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Field' : 'Register New Field',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0.5,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryGreenSurface,
                      Colors.green.shade100.withValues(alpha: 0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _isEditMode ? Icons.edit_note : Icons.add_location_alt,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEditMode ? 'Update Field Records' : 'Register Field with Supabase',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isEditMode
                                ? 'Save modified parameters to cloud database.'
                                : 'All details are stored directly into your Supabase fields table.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 1: Basic Field Details
              _buildSectionHeader('Field Identification', Icons.badge_outlined),
              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Field Name (field_name)
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Field Name *'),
                        TextFormField(
                          controller: _nameCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            hintText: 'e.g. North Plot',
                            prefixIcon: Icon(Icons.landscape_outlined, color: AppTheme.textLight),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter field name';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Field Number (field_number)
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Field No. *'),
                        TextFormField(
                          controller: _fieldNumberCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'e.g. 1',
                            prefixIcon: Icon(Icons.tag, color: AppTheme.textLight),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter number';
                            }
                            final num = int.tryParse(v.trim());
                            if (num == null || num <= 0) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Farmer / User Name (user_name)
              _buildLabel('Farmer / Owner Name *'),
              TextFormField(
                controller: _userNameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'e.g. Ramesh Patel',
                  prefixIcon: Icon(Icons.person_outline, color: AppTheme.textLight),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter the farmer/user name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Section 2: Crop & Area
              _buildSectionHeader('Crop & Farm Dimensions', Icons.agriculture_outlined),
              const SizedBox(height: 12),

              // Crop Name (crop_name)
              _buildLabel('Crop Name *'),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _selectedCrop,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.grass_outlined, color: AppTheme.textLight),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                items: _cropOptions
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _selectedCrop = v;
                      _isCustomCrop = v == 'Other';
                      if (!_isCustomCrop) {
                        _cropCtrl.text = v;
                      } else {
                        _cropCtrl.clear();
                      }
                    });
                  }
                },
              ),
              if (_isCustomCrop) ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: _cropCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Specify custom crop name',
                    prefixIcon: Icon(Icons.edit, color: AppTheme.textLight),
                  ),
                  validator: (v) {
                    if (_isCustomCrop && (v == null || v.trim().isEmpty)) {
                      return 'Please specify crop name';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),

              // Area (area)
              _buildLabel('Field Area (in acres) *'),
              TextFormField(
                controller: _areaCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: 'e.g. 3.5',
                  prefixIcon: Icon(Icons.square_foot, color: AppTheme.textLight),
                  suffixText: 'Acres',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter field area';
                  }
                  final num = double.tryParse(v.trim());
                  if (num == null || num <= 0) {
                    return 'Please enter a valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Section 3: Geographic Coordinates
              _buildSectionHeader('Geographic Coordinates (GPS)', Icons.pin_drop_outlined),
              const SizedBox(height: 8),

              // Quick location presets
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.my_location, size: 16, color: AppTheme.primaryGreen),
                      label: const Text('Wardha Hub (20.7453, 78.6022)'),
                      onPressed: () => _usePresetCoordinates(20.7453, 78.6022, 'Wardha Farm'),
                      backgroundColor: AppTheme.primaryGreenSurface,
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      avatar: const Icon(Icons.location_city, size: 16, color: Colors.blue),
                      label: const Text('Nagpur Region (21.1458, 79.0882)'),
                      onPressed: () => _usePresetCoordinates(21.1458, 79.0882, 'Nagpur Region'),
                      backgroundColor: Colors.blue.shade50,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Latitude (latitude)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Latitude *'),
                        TextFormField(
                          controller: _latitudeCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          decoration: const InputDecoration(
                            hintText: '20.7453',
                            prefixIcon: Icon(Icons.north, size: 18, color: AppTheme.textLight),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter latitude';
                            }
                            final num = double.tryParse(v.trim());
                            if (num == null || num < -90 || num > 90) {
                              return 'Valid: -90 to 90';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Longitude (longitude)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Longitude *'),
                        TextFormField(
                          controller: _longitudeCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          decoration: const InputDecoration(
                            hintText: '78.6022',
                            prefixIcon: Icon(Icons.east, size: 18, color: AppTheme.textLight),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter longitude';
                            }
                            final num = double.tryParse(v.trim());
                            if (num == null || num < -180 || num > 180) {
                              return 'Valid: -180 to 180';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Section 4: Sowing Date & Notes
              _buildSectionHeader('Lifecycle & Notes', Icons.event_note_outlined),
              const SizedBox(height: 12),

              // Sowing Date
              _buildLabel('Sowing Date'),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppTheme.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined, color: AppTheme.primaryGreen, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('MMMM d, y').format(_sowingDate),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down, color: AppTheme.textLight),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes (optional)
              _buildLabel('Notes / Soil Details (optional)'),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'E.g., Black cotton soil, drip irrigation installed...',
                  alignLabelWithHint: true,
                  prefixIcon: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: 1.0,
                    child: Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Icon(Icons.notes_outlined, color: AppTheme.textLight),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isSaving ? null : _saveField,
                      child: _isSaving
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                ),
                                SizedBox(width: 10),
                                Text('Saving to Supabase...', style: TextStyle(color: Colors.white)),
                              ],
                            )
                          : Text(
                              _isEditMode ? 'Save Changes' : 'Save Field',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryGreen),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _sowingDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppTheme.primaryGreen,
              primary: AppTheme.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _sowingDate = picked);
    }
  }

  Future<void> _saveField() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final fieldName = _nameCtrl.text.trim();
      final fieldNumber = int.parse(_fieldNumberCtrl.text.trim());
      final userName = _userNameCtrl.text.trim();
      final cropName = _isCustomCrop ? _cropCtrl.text.trim() : _selectedCrop;
      final areaVal = double.parse(_areaCtrl.text.trim());
      final latVal = double.parse(_latitudeCtrl.text.trim());
      final lngVal = double.parse(_longitudeCtrl.text.trim());
      final notesVal = _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();
      final locationStr = 'Lat: $latVal, Long: $lngVal';

      AppState? appState;
      try {
        appState = AppStateProvider.of(context);
      } catch (_) {}

      final fidToUse = widget.defaultFid ?? appState?.currentFid;

      if (_isEditMode) {
        // Update existing field
        final updated = widget.existingField!.copyWith(
          name: fieldName,
          fieldNumber: fieldNumber,
          userName: userName,
          crop: cropName,
          area: areaVal,
          latitude: latVal,
          longitude: lngVal,
          location: locationStr,
          sowingDate: _sowingDate,
          notes: notesVal,
        );

        await widget.storageService.updateField(
          widget.fields,
          updated,
          fid: fidToUse,
          userName: userName,
        );

        if (appState != null) {
          appState.editField(CropField.fromFarmField(updated));
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Field "$fieldName" updated successfully in Supabase!'),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
          Navigator.pop(context, updated);
        }
      } else {
        // Create new field
        final fieldId = const Uuid().v4();
        final newField = FarmField(
          id: fieldId,
          fid: fidToUse,
          userName: userName,
          name: fieldName,
          fieldNumber: fieldNumber,
          crop: cropName,
          area: areaVal,
          latitude: latVal,
          longitude: lngVal,
          location: locationStr,
          sowingDate: _sowingDate,
          notes: notesVal,
          healthScore: 82.0,
          soilMoisture: 48.0,
          temperature: 29.0,
          humidity: 58.0,
          lastScan: DateTime.now(),
          isDemoData: false,
          zones: const [
            FieldZone(
              name: 'Zone 1',
              healthScore: 85.0,
              soilMoisture: 50.0,
              temperature: 28.0,
              humidity: 60.0,
            ),
            FieldZone(
              name: 'Zone 2',
              healthScore: 78.0,
              soilMoisture: 45.0,
              temperature: 30.0,
              humidity: 55.0,
            ),
          ],
          problems: const [],
          improvements: const [
            FieldImprovement(
              title: 'Growth Monitoring',
              steps: [
                'Monitor soil moisture regularly',
                'Schedule periodic drone health scan',
              ],
            ),
          ],
        );

        final saved = await widget.storageService.addField(
          widget.fields,
          newField,
          fid: fidToUse,
          userName: userName,
        );

        if (appState != null) {
          // Add to AppState list if not already updated
          final exists = appState.fields.any((f) => f.id == saved.id);
          if (!exists) {
            appState.fields.add(CropField.fromFarmField(saved));
            appState.notifyListeners();
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Field "${saved.name}" (#${saved.fieldNumber}) saved to Supabase!'),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
          Navigator.pop(context, saved);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save field: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
