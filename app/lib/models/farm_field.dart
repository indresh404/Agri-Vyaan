import 'dart:convert';

/// Represents a single zone within a farm field.
class FieldZone {
  final String name;
  final double healthScore;
  final double soilMoisture;
  final double temperature;
  final double humidity;
  final String? problem;
  final String? severity;
  final String? recommendation;

  const FieldZone({
    required this.name,
    required this.healthScore,
    required this.soilMoisture,
    required this.temperature,
    required this.humidity,
    this.problem,
    this.severity,
    this.recommendation,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'healthScore': healthScore,
    'soilMoisture': soilMoisture,
    'temperature': temperature,
    'humidity': humidity,
    'problem': problem,
    'severity': severity,
    'recommendation': recommendation,
  };

  factory FieldZone.fromJson(Map<String, dynamic> json) => FieldZone(
    name: json['name'] as String,
    healthScore: (json['healthScore'] as num).toDouble(),
    soilMoisture: (json['soilMoisture'] as num).toDouble(),
    temperature: (json['temperature'] as num).toDouble(),
    humidity: (json['humidity'] as num).toDouble(),
    problem: json['problem'] as String?,
    severity: json['severity'] as String?,
    recommendation: json['recommendation'] as String?,
  );
}

/// Represents an active problem detected in a field.
class FieldProblem {
  final String title;
  final String severity; // High, Medium, Low
  final String description;
  final String? affectedZone;

  const FieldProblem({
    required this.title,
    required this.severity,
    required this.description,
    this.affectedZone,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'severity': severity,
    'description': description,
    'affectedZone': affectedZone,
  };

  factory FieldProblem.fromJson(Map<String, dynamic> json) => FieldProblem(
    title: json['title'] as String,
    severity: json['severity'] as String,
    description: json['description'] as String,
    affectedZone: json['affectedZone'] as String?,
  );
}

/// Represents an improvement recommendation for a field.
class FieldImprovement {
  final String title;
  final List<String> steps;

  const FieldImprovement({
    required this.title,
    required this.steps,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'steps': steps,
  };

  factory FieldImprovement.fromJson(Map<String, dynamic> json) =>
      FieldImprovement(
        title: json['title'] as String,
        steps: List<String>.from(json['steps'] as List),
      );
}

/// Main data model representing a farm field.
class FarmField {
  final String id;
  final String name;
  final String crop;
  final double area; // in acres
  final String location;
  final DateTime sowingDate;
  final String? notes;
  final double healthScore;
  final double soilMoisture;
  final double temperature;
  final double humidity;
  final DateTime lastScan;
  final List<FieldZone> zones;
  final List<FieldProblem> problems;
  final List<FieldImprovement> improvements;
  final bool isDemoData;

  const FarmField({
    required this.id,
    required this.name,
    required this.crop,
    required this.area,
    required this.location,
    required this.sowingDate,
    this.notes,
    required this.healthScore,
    required this.soilMoisture,
    required this.temperature,
    required this.humidity,
    required this.lastScan,
    this.zones = const [],
    this.problems = const [],
    this.improvements = const [],
    this.isDemoData = true,
  });

  FarmField copyWith({
    String? id,
    String? name,
    String? crop,
    double? area,
    String? location,
    DateTime? sowingDate,
    String? notes,
    double? healthScore,
    double? soilMoisture,
    double? temperature,
    double? humidity,
    DateTime? lastScan,
    List<FieldZone>? zones,
    List<FieldProblem>? problems,
    List<FieldImprovement>? improvements,
    bool? isDemoData,
  }) {
    return FarmField(
      id: id ?? this.id,
      name: name ?? this.name,
      crop: crop ?? this.crop,
      area: area ?? this.area,
      location: location ?? this.location,
      sowingDate: sowingDate ?? this.sowingDate,
      notes: notes ?? this.notes,
      healthScore: healthScore ?? this.healthScore,
      soilMoisture: soilMoisture ?? this.soilMoisture,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      lastScan: lastScan ?? this.lastScan,
      zones: zones ?? this.zones,
      problems: problems ?? this.problems,
      improvements: improvements ?? this.improvements,
      isDemoData: isDemoData ?? this.isDemoData,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'crop': crop,
    'area': area,
    'location': location,
    'sowingDate': sowingDate.toIso8601String(),
    'notes': notes,
    'healthScore': healthScore,
    'soilMoisture': soilMoisture,
    'temperature': temperature,
    'humidity': humidity,
    'lastScan': lastScan.toIso8601String(),
    'zones': zones.map((z) => z.toJson()).toList(),
    'problems': problems.map((p) => p.toJson()).toList(),
    'improvements': improvements.map((i) => i.toJson()).toList(),
    'isDemoData': isDemoData,
  };

  factory FarmField.fromJson(Map<String, dynamic> json) => FarmField(
    id: json['id'] as String,
    name: json['name'] as String,
    crop: json['crop'] as String,
    area: (json['area'] as num).toDouble(),
    location: json['location'] as String,
    sowingDate: DateTime.parse(json['sowingDate'] as String),
    notes: json['notes'] as String?,
    healthScore: (json['healthScore'] as num).toDouble(),
    soilMoisture: (json['soilMoisture'] as num).toDouble(),
    temperature: (json['temperature'] as num).toDouble(),
    humidity: (json['humidity'] as num).toDouble(),
    lastScan: DateTime.parse(json['lastScan'] as String),
    zones: (json['zones'] as List?)
            ?.map((z) => FieldZone.fromJson(z as Map<String, dynamic>))
            .toList() ??
        [],
    problems: (json['problems'] as List?)
            ?.map((p) => FieldProblem.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [],
    improvements: (json['improvements'] as List?)
            ?.map(
                (i) => FieldImprovement.fromJson(i as Map<String, dynamic>))
            .toList() ??
        [],
    isDemoData: json['isDemoData'] as bool? ?? true,
  );

  String toJsonString() => jsonEncode(toJson());

  factory FarmField.fromJsonString(String jsonString) =>
      FarmField.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);

  factory FarmField.fromCropField(dynamic c) {
    try {
      final zonesList = (c.zones as List?)?.map((z) => FieldZone(
        name: z.name as String,
        healthScore: z.status == 'Healthy' ? 85.0 : 60.0,
        soilMoisture: (z.moisture as num).toDouble(),
        temperature: (z.temperature as num).toDouble(),
        humidity: 60.0,
        problem: z.status != 'Healthy' ? z.status as String? : null,
        severity: z.risk != 'None' ? z.risk as String? : null,
        recommendation: (z.recommendation as String).isNotEmpty ? z.recommendation as String : null,
      )).toList() ?? [];

      final alertsList = (c.activeAlerts as List?)?.map((a) => FieldProblem(
        title: a as String,
        severity: 'Medium',
        description: a as String,
      )).toList() ?? [];

      return FarmField(
        id: c.id as String,
        name: c.name as String,
        crop: c.crop as String,
        area: (c.area as num).toDouble(),
        location: (c.location as String?)?.isNotEmpty == true ? c.location as String : '${c.areaUnit} • ${c.cropStage}',
        sowingDate: DateTime.tryParse(c.sowingDate as String) ?? DateTime.now(),
        healthScore: (c.healthScore as num).toDouble(),
        soilMoisture: zonesList.isNotEmpty ? zonesList.first.soilMoisture : 45.0,
        temperature: zonesList.isNotEmpty ? zonesList.first.temperature : 28.0,
        humidity: 60.0,
        lastScan: DateTime.now(),
        isDemoData: true,
        zones: zonesList,
        problems: alertsList,
        improvements: const [
          FieldImprovement(
            title: 'Crop Care & Management',
            steps: [
              'Monitor soil moisture and zone health regularly',
              'Follow recommended fertilization and irrigation schedules',
            ],
          ),
        ],
      );
    } catch (_) {
      return FarmField(
        id: c.id as String,
        name: c.name as String,
        crop: c.crop as String,
        area: (c.area as num).toDouble(),
        location: 'Farm Field',
        sowingDate: DateTime.now(),
        healthScore: (c.healthScore as num).toDouble(),
        soilMoisture: 45.0,
        temperature: 28.0,
        humidity: 60.0,
        lastScan: DateTime.now(),
        isDemoData: true,
      );
    }
  }
}
