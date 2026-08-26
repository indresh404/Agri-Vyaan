import 'package:flutter/material.dart';

class ToolsScreen extends StatefulWidget {
  final String? initialCalculator;
  const ToolsScreen({super.key, this.initialCalculator});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  String? _selectedCalculator;

  @override
  void initState() {
    super.initState();
    _selectedCalculator = widget.initialCalculator;
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedCalculator != null) {
      return _buildCalculatorView();
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Farm Calculators'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
        children: [
          _buildToolCard('Fertilizer Calculator', Icons.opacity_outlined, Colors.green, 'fertilizer'),
          _buildToolCard('Pesticide Calculator', Icons.pest_control_outlined, Colors.orange, 'pesticide'),
          _buildToolCard('Irrigation Calculator', Icons.water_drop_outlined, Colors.blue, 'irrigation'),
          _buildToolCard('Seed Calculator', Icons.grain, Colors.teal, 'seed'),
          _buildToolCard('Farming Cost Calculator', Icons.payments_outlined, Colors.red, 'cost'),
          _buildToolCard('Farm Area Calculator', Icons.square_foot, Colors.indigo, 'area'),
        ],
      ),
    );
  }

  Widget _buildToolCard(String title, IconData icon, Color color, String key) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            _selectedCalculator = key;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalculatorView() {
    String title = '';
    Widget calcForm = const SizedBox();

    switch (_selectedCalculator) {
      case 'fertilizer':
        title = 'Fertilizer Calculator';
        calcForm = const FertilizerCalculatorForm();
        break;
      case 'pesticide':
        title = 'Pesticide Calculator';
        calcForm = const PesticideCalculatorForm();
        break;
      case 'irrigation':
        title = 'Irrigation Calculator';
        calcForm = const IrrigationCalculatorForm();
        break;
      case 'seed':
        title = 'Seed Calculator';
        calcForm = const SeedCalculatorForm();
        break;
      case 'cost':
        title = 'Farming Cost Calculator';
        calcForm = const CostCalculatorForm();
        break;
      case 'area':
        title = 'Farm Area Calculator';
        calcForm = const AreaCalculatorForm();
        break;
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _selectedCalculator = null;
            });
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            calcForm,
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// --- FERTILIZER CALCULATOR FORM ---
class FertilizerCalculatorForm extends StatefulWidget {
  const FertilizerCalculatorForm({super.key});

  @override
  State<FertilizerCalculatorForm> createState() => _FertilizerCalculatorFormState();
}

class _FertilizerCalculatorFormState extends State<FertilizerCalculatorForm> {
  double _area = 2.0;
  String _crop = 'Cotton';
  String _product = 'Urea';
  double _rate = 50.0; // kg per acre

  @override
  Widget build(BuildContext context) {
    final double result = _area * _rate;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Required rate varies based on local soil conditions and growth stages.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _crop,
              items: ['Cotton', 'Tomato', 'Wheat', 'Rice']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _crop = val!;
                  if (_crop == 'Cotton') _rate = 50.0;
                  if (_crop == 'Tomato') _rate = 40.0;
                  if (_crop == 'Wheat') _rate = 60.0;
                });
              },
              decoration: const InputDecoration(labelText: 'Select Crop', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _product,
              items: ['Urea', 'DAP', 'Potash']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _product = val!;
                });
              },
              decoration: const InputDecoration(labelText: 'Select Fertilizer Product', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            Text('Farm Area: ${_area.toStringAsFixed(1)} acres'),
            Slider(
              value: _area,
              min: 0.5,
              max: 20.0,
              divisions: 39,
              activeColor: Colors.green,
              label: '${_area.toStringAsFixed(1)} acres',
              onChanged: (val) {
                setState(() {
                  _area = val;
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _rate.toString(),
              decoration: const InputDecoration(labelText: 'Application Rate (kg / acre)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                setState(() {
                  _rate = double.tryParse(val) ?? 0.0;
                });
              },
            ),
            const Divider(height: 32),
            // Result Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  const Text('ESTIMATED QUANTITY REQUIRED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                  Text(
                    '${result.toStringAsFixed(1)} kg',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Formula: ${_area.toStringAsFixed(1)} acres x ${_rate.toStringAsFixed(0)} kg/acre = ${result.toStringAsFixed(1)} kg',
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black87),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- PESTICIDE CALCULATOR FORM ---
class PesticideCalculatorForm extends StatefulWidget {
  const PesticideCalculatorForm({super.key});

  @override
  State<PesticideCalculatorForm> createState() => _PesticideCalculatorFormState();
}

class _PesticideCalculatorFormState extends State<PesticideCalculatorForm> {
  double _area = 2.0;
  String _product = 'Copper Fungicide';
  double _dosage = 2.5; // ml or grams per Liter

  @override
  Widget build(BuildContext context) {
    final double totalLitres = _area * 200; // Assume 200 Litres of water carrier per acre
    final double resultQuantity = totalLitres * _dosage / 1000; // in kg or Litres

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.orange.shade50,
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange.shade800),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Do not exceed label rates. Always wear protective gear during application.',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _product,
              items: ['Copper Fungicide', 'Neem Oil Spray', 'Spinosad Larvicide']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _product = val!;
                  if (_product == 'Copper Fungicide') _dosage = 2.5;
                  if (_product == 'Neem Oil Spray') _dosage = 5.0;
                  if (_product == 'Spinosad Larvicide') _dosage = 1.2;
                });
              },
              decoration: const InputDecoration(labelText: 'Pesticide Product', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            Text('Farm Area: ${_area.toStringAsFixed(1)} acres'),
            Slider(
              value: _area,
              min: 0.5,
              max: 20.0,
              divisions: 39,
              activeColor: Colors.orange,
              label: '${_area.toStringAsFixed(1)} acres',
              onChanged: (val) {
                setState(() {
                  _area = val;
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _dosage.toString(),
              decoration: const InputDecoration(labelText: 'Label Rate dosage (ml or g / Liter of water)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                setState(() {
                  _dosage = double.tryParse(val) ?? 0.0;
                });
              },
            ),
            const Divider(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  const Text('REQUIRED ESTIMATED AMOUNT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                  Text(
                    '${resultQuantity.toStringAsFixed(2)} Liters / kg',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Water Carrier: ${totalLitres.toStringAsFixed(0)} Litres required.\nFormula: ${totalLitres.toStringAsFixed(0)}L x $_dosage g/L = ${resultQuantity.toStringAsFixed(2)} kg/L product.',
                    style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.black87),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Important: Follow the product label and local agricultural guidance.',
              style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// --- IRRIGATION CALCULATOR FORM ---
class IrrigationCalculatorForm extends StatefulWidget {
  const IrrigationCalculatorForm({super.key});

  @override
  State<IrrigationCalculatorForm> createState() => _IrrigationCalculatorFormState();
}

class _IrrigationCalculatorFormState extends State<IrrigationCalculatorForm> {
  double _area = 2.0;
  double _moisture = 30.0;
  String _weather = 'Sunny';

  @override
  Widget build(BuildContext context) {
    // Water depth in mm required to bring soil moisture to optimal (~50%)
    final double deficit = 50.0 - _moisture;
    final double depthRequired = deficit <= 0 ? 0.0 : deficit * 0.5; // mm depth
    final double rainCredit = _weather == 'Rainy' ? 10.0 : 0.0;
    final double finalDepth = (depthRequired - rainCredit) <= 0 ? 0.0 : (depthRequired - rainCredit);

    // 1 mm water on 1 acre = 4047 Litres of water
    final double totalLitres = _area * finalDepth * 4047;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This estimation helps gauge optimal watering volumes under dry/hot spells.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Text('Farm Area: ${_area.toStringAsFixed(1)} acres'),
            Slider(
              value: _area,
              min: 0.5,
              max: 20.0,
              divisions: 39,
              activeColor: Colors.blue,
              label: '${_area.toStringAsFixed(1)} acres',
              onChanged: (val) {
                setState(() {
                  _area = val;
                });
              },
            ),
            const SizedBox(height: 12),
            Text('Current Soil Moisture: ${_moisture.toStringAsFixed(0)}%'),
            Slider(
              value: _moisture,
              min: 10.0,
              max: 60.0,
              divisions: 50,
              activeColor: Colors.blue,
              label: '${_moisture.toStringAsFixed(0)}%',
              onChanged: (val) {
                setState(() {
                  _moisture = val;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _weather,
              items: ['Sunny', 'Cloudy', 'Rainy']
                  .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _weather = val!;
                });
              },
              decoration: const InputDecoration(labelText: 'Current Weather Status', border: OutlineInputBorder()),
            ),
            const Divider(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  const Text('ESTIMATED IRRIGATION REQUIREMENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                  Text(
                    '${totalLitres.toStringAsFixed(0)} Litres',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Equivalent to ${finalDepth.toStringAsFixed(1)} mm depth of watering.\nThis is an estimation/support tool, not a guarantee.',
                    style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.black87),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- SEED CALCULATOR FORM ---
class SeedCalculatorForm extends StatefulWidget {
  const SeedCalculatorForm({super.key});

  @override
  State<SeedCalculatorForm> createState() => _SeedCalculatorFormState();
}

class _SeedCalculatorFormState extends State<SeedCalculatorForm> {
  double _area = 2.0;
  String _crop = 'Cotton';
  double _spacing = 60.0; // cm between rows

  @override
  Widget build(BuildContext context) {
    // Basic seeds count equation: Area / Spacing parameters
    // Cotton average: 15,000 seeds per acre at standard row spacing
    double baseRatePerAcre = 15000;
    if (_crop == 'Tomato') baseRatePerAcre = 12000;
    if (_crop == 'Wheat') baseRatePerAcre = 400000; // Wheat seeds are dense

    final double result = _area * baseRatePerAcre * (60.0 / _spacing);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _crop,
              items: ['Cotton', 'Tomato', 'Wheat']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _crop = val!;
                  if (_crop == 'Cotton') _spacing = 60.0;
                  if (_crop == 'Tomato') _spacing = 45.0;
                  if (_crop == 'Wheat') _spacing = 20.0;
                });
              },
              decoration: const InputDecoration(labelText: 'Crop', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            Text('Farm Area: ${_area.toStringAsFixed(1)} acres'),
            Slider(
              value: _area,
              min: 0.5,
              max: 20.0,
              divisions: 39,
              activeColor: Colors.teal,
              label: '${_area.toStringAsFixed(1)} acres',
              onChanged: (val) {
                setState(() {
                  _area = val;
                });
              },
            ),
            const SizedBox(height: 12),
            Text('Row Spacing Spacing: ${_spacing.toStringAsFixed(0)} cm'),
            Slider(
              value: _spacing,
              min: 15.0,
              max: 90.0,
              divisions: 15,
              activeColor: Colors.teal,
              label: '${_spacing.toStringAsFixed(0)} cm',
              onChanged: (val) {
                setState(() {
                  _spacing = val;
                });
              },
            ),
            const Divider(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  const Text('ESTIMATED SEEDS REQUIRED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                  Text(
                    '${result.toStringAsFixed(0)} seeds',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal.shade900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Approx. weight: ${(result / 10000).toStringAsFixed(2)} kg',
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- COST CALCULATOR FORM ---
class CostCalculatorForm extends StatefulWidget {
  const CostCalculatorForm({super.key});

  @override
  State<CostCalculatorForm> createState() => _CostCalculatorFormState();
}

class _CostCalculatorFormState extends State<CostCalculatorForm> {
  double _area = 2.0;
  double _seeds = 3000;
  double _fertilizers = 4500;
  double _pesticides = 2000;
  double _labour = 6000;
  double _irrigation = 1500;

  @override
  Widget build(BuildContext context) {
    final double totalCost = (_seeds + _fertilizers + _pesticides + _labour + _irrigation) * _area;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Farm Area: ${_area.toStringAsFixed(1)} acres'),
            Slider(
              value: _area,
              min: 0.5,
              max: 20.0,
              divisions: 39,
              activeColor: Colors.red,
              onChanged: (val) {
                setState(() {
                  _area = val;
                });
              },
            ),
            const SizedBox(height: 12),
            _buildCostInput('Seeds Cost / acre (₹)', _seeds, (val) => setState(() => _seeds = val)),
            _buildCostInput('Fertilizers / acre (₹)', _fertilizers, (val) => setState(() => _fertilizers = val)),
            _buildCostInput('Pesticides / acre (₹)', _pesticides, (val) => setState(() => _pesticides = val)),
            _buildCostInput('Labour / acre (₹)', _labour, (val) => setState(() => _labour = val)),
            _buildCostInput('Irrigation / acre (₹)', _irrigation, (val) => setState(() => _irrigation = val)),
            const Divider(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  const Text('TOTAL ESTIMATED FARMING COST', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                  Text(
                    '₹ ${totalCost.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.red.shade900),
                  ),
                  Text(
                    'Cost per acre: ₹ ${(totalCost / _area).toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostInput(String label, double val, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        initialValue: val.toStringAsFixed(0),
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        keyboardType: TextInputType.number,
        onChanged: (v) {
          onChanged(double.tryParse(v) ?? 0.0);
        },
      ),
    );
  }
}

// --- AREA CALCULATOR FORM ---
class AreaCalculatorForm extends StatefulWidget {
  const AreaCalculatorForm({super.key});

  @override
  State<AreaCalculatorForm> createState() => _AreaCalculatorFormState();
}

class _AreaCalculatorFormState extends State<AreaCalculatorForm> {
  double _inputValue = 1.0;
  String _selectedUnit = 'Acres';

  @override
  Widget build(BuildContext context) {
    // Conversions relative to Acres
    double acres = _inputValue;
    if (_selectedUnit == 'Hectares') acres = _inputValue * 2.471;
    if (_selectedUnit == 'Gunthas') acres = _inputValue / 40.0;
    if (_selectedUnit == 'Bighas') acres = _inputValue * 0.625;

    final double resultHectares = acres / 2.471;
    final double resultGunthas = acres * 40;
    final double resultBighas = acres / 0.625;
    final double resultSqm = acres * 4046.85;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: _inputValue.toString(),
                    decoration: const InputDecoration(labelText: 'Enter Area Value', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      setState(() {
                        _inputValue = double.tryParse(val) ?? 0.0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: _selectedUnit,
                    items: ['Acres', 'Hectares', 'Gunthas', 'Bighas']
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedUnit = val!;
                      });
                    },
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            const Text('UNIT CONVERSION RESULTS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 12),
            _buildResultRow('Acres', acres.toStringAsFixed(2)),
            _buildResultRow('Hectares', resultHectares.toStringAsFixed(2)),
            _buildResultRow('Gunthas', resultGunthas.toStringAsFixed(1)),
            _buildResultRow('Bighas (approx)', resultBighas.toStringAsFixed(2)),
            _buildResultRow('Square Meters', resultSqm.toStringAsFixed(0)),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String unit, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(unit, style: const TextStyle(fontSize: 14, color: Colors.black87)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)),
        ],
      ),
    );
  }
}
