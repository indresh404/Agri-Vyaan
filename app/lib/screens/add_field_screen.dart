import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/farm_field.dart';
import '../services/field_storage_service.dart';
import '../utils/app_theme.dart';

/// Available crop types for the crop selector.
const List<String> _cropOptions = [
  'Wheat',
  'Cotton',
  'Paddy',
  'Maize',
  'Tomato',
  'Potato',
  'Rice',
  'Soybean',
  'Sugarcane',
  'Other',
];

/// Form screen for adding a new field or editing an existing one.
class AddFieldScreen extends StatefulWidget {
  final List<FarmField> fields;
  final FieldStorageService storageService;
  final FarmField? existingField; // non-null = edit mode

  const AddFieldScreen({
    super.key,
    required this.fields,
    required this.storageService,
    this.existingField,
  });

  @override
  State<AddFieldScreen> createState() => _AddFieldScreenState();
}

class _AddFieldScreenState extends State<AddFieldScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _areaCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _notesCtrl;
  String _selectedCrop = 'Wheat';
  DateTime _sowingDate = DateTime.now();
  bool _isSaving = false;

  bool get _isEditMode => widget.existingField != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingField;
    _nameCtrl = TextEditingController(text: existing?.name ?? '');
    _areaCtrl = TextEditingController(
        text: existing != null ? existing.area.toString() : '');
    _locationCtrl = TextEditingController(text: existing?.location ?? '');
    _notesCtrl = TextEditingController(text: existing?.notes ?? '');
    if (existing != null) {
      _selectedCrop = existing.crop;
      _sowingDate = existing.sowingDate;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _areaCtrl.dispose();
    _locationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Field' : 'Add New Field'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header icon
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreenSurface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    _isEditMode ? Icons.edit_outlined : Icons.add_circle_outline,
                    color: AppTheme.primaryGreen,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _isEditMode
                      ? 'Update your field information'
                      : 'Enter your field details to get started',
                  style: const TextStyle(
                      fontSize: 14, color: AppTheme.textSecondary),
                ),
              ),
              const SizedBox(height: 24),

              // Field Name
              _buildLabel('Field Name'),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'e.g., North Field',
                  prefixIcon:
                      Icon(Icons.landscape_outlined, color: AppTheme.textLight),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter a field name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Crop
              _buildLabel('Crop'),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _cropOptions.contains(_selectedCrop)
                    ? _selectedCrop
                    : 'Other',
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.grass_outlined, color: AppTheme.textLight),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                items: _cropOptions
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedCrop = v);
                },
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please select a crop';
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Area
              _buildLabel('Area (acres)'),
              TextFormField(
                controller: _areaCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: 'e.g., 3.2',
                  prefixIcon: Icon(Icons.square_foot, color: AppTheme.textLight),
                  suffixText: 'acres',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter the area';
                  }
                  final num = double.tryParse(v.trim());
                  if (num == null || num <= 0) {
                    return 'Please enter a valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Location
              _buildLabel('Location'),
              TextFormField(
                controller: _locationCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'e.g., North Block, Village Rampur',
                  prefixIcon:
                      Icon(Icons.location_on_outlined, color: AppTheme.textLight),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter the location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Sowing Date
              _buildLabel('Sowing Date'),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.calendar_today_outlined,
                        color: AppTheme.textLight),
                  ),
                  child: Text(
                    DateFormat('MMMM d, y').format(_sowingDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Notes (optional)
              _buildLabel('Notes (optional)'),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Any additional notes about this field...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child:
                        Icon(Icons.notes_outlined, color: AppTheme.textLight),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isSaving ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveField,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(_isEditMode ? 'Save Changes' : 'Add Field'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
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
      if (_isEditMode) {
        // Update existing field
        final updated = widget.existingField!.copyWith(
          name: _nameCtrl.text.trim(),
          crop: _selectedCrop,
          area: double.parse(_areaCtrl.text.trim()),
          location: _locationCtrl.text.trim(),
          sowingDate: _sowingDate,
          notes: _notesCtrl.text.trim().isEmpty
              ? null
              : _notesCtrl.text.trim(),
        );
        await widget.storageService.updateField(widget.fields, updated);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Field updated successfully!'),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
          Navigator.pop(context, updated);
        }
      } else {
        // Create new field with demo sensor values
        final newField = FarmField(
          id: 'field_${DateTime.now().millisecondsSinceEpoch}',
          name: _nameCtrl.text.trim(),
          crop: _selectedCrop,
          area: double.parse(_areaCtrl.text.trim()),
          location: _locationCtrl.text.trim(),
          sowingDate: _sowingDate,
          notes: _notesCtrl.text.trim().isEmpty
              ? null
              : _notesCtrl.text.trim(),
          healthScore: 72,
          soilMoisture: 45,
          temperature: 30,
          humidity: 60,
          lastScan: DateTime.now(),
          isDemoData: true,
          zones: const [
            FieldZone(
              name: 'Zone 1',
              healthScore: 80,
              soilMoisture: 48,
              temperature: 30,
              humidity: 62,
            ),
            FieldZone(
              name: 'Zone 2',
              healthScore: 65,
              soilMoisture: 42,
              temperature: 31,
              humidity: 58,
            ),
          ],
          problems: const [],
          improvements: const [
            FieldImprovement(
              title: 'Initial Setup',
              steps: [
                'Connect sensors when available',
                'Schedule first drone scan',
                'Monitor initial growth conditions',
              ],
            ),
          ],
        );

        await widget.storageService.addField(widget.fields, newField);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${newField.name} added successfully!'),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
          Navigator.pop(context, newField);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
