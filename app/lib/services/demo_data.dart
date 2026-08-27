import '../models/farm_field.dart';

/// Provides realistic demo fields for the hackathon demonstration.
/// These are used when the app has no saved fields on first launch.
class DemoData {
  DemoData._();

  static List<FarmField> get demoFields => [
    FarmField(
      id: 'demo_field_a',
      name: 'Field A',
      crop: 'Wheat',
      area: 3.2,
      location: 'North Block, Village Rampur',
      sowingDate: DateTime(2026, 6, 15),
      notes: 'Primary wheat cultivation area',
      healthScore: 78,
      soilMoisture: 45,
      temperature: 32,
      humidity: 65,
      lastScan: DateTime(2026, 8, 27, 10, 30),
      isDemoData: true,
      zones: [
        const FieldZone(
          name: 'Zone 1',
          healthScore: 85,
          soilMoisture: 52,
          temperature: 31,
          humidity: 66,
        ),
        const FieldZone(
          name: 'Zone 2',
          healthScore: 61,
          soilMoisture: 27,
          temperature: 34,
          humidity: 58,
          problem: 'Low Soil Moisture',
          severity: 'High',
          recommendation:
              'Increase irrigation in this zone and recheck moisture levels after 24 hours.',
        ),
        const FieldZone(
          name: 'Zone 3',
          healthScore: 54,
          soilMoisture: 38,
          temperature: 36,
          humidity: 55,
          problem: 'Crop Stress',
          severity: 'Medium',
          recommendation:
              'Inspect affected plants for visible stress symptoms. Monitor temperature during peak hours.',
        ),
        const FieldZone(
          name: 'Zone 4',
          healthScore: 88,
          soilMoisture: 50,
          temperature: 30,
          humidity: 68,
        ),
      ],
      problems: const [
        FieldProblem(
          title: 'Low Soil Moisture',
          severity: 'High',
          description:
              'Soil moisture in Zone 2 has dropped below the optimal threshold for wheat growth.',
          affectedZone: 'Zone 2',
        ),
        FieldProblem(
          title: 'Crop Stress',
          severity: 'Medium',
          description:
              'Elevated temperatures are causing mild stress in Zone 3 plants.',
          affectedZone: 'Zone 3',
        ),
        FieldProblem(
          title: 'Nutrient Deficiency',
          severity: 'Low',
          description:
              'Nitrogen levels are slightly below optimal range across the field.',
        ),
      ],
      improvements: const [
        FieldImprovement(
          title: 'Water Management',
          steps: [
            'Increase irrigation in Zone 2 immediately',
            'Recheck moisture levels after 24 hours',
            'Avoid overwatering healthy zones (Zone 1, Zone 4)',
          ],
        ),
        FieldImprovement(
          title: 'Crop Stress Mitigation',
          steps: [
            'Inspect affected plants in Zone 3',
            'Check for visible stress symptoms',
            'Monitor during next drone scan',
          ],
        ),
        FieldImprovement(
          title: 'Soil Health',
          steps: [
            'Maintain optimal nutrient levels',
            'Consider adding organic matter',
            'Schedule regular soil testing',
          ],
        ),
      ],
    ),
    FarmField(
      id: 'demo_field_b',
      name: 'Field B',
      crop: 'Cotton',
      area: 2.8,
      location: 'East Plot, Village Rampur',
      sowingDate: DateTime(2026, 5, 20),
      notes: 'Cotton field near the river',
      healthScore: 85,
      soilMoisture: 52,
      temperature: 30,
      humidity: 62,
      lastScan: DateTime(2026, 8, 26, 15, 0),
      isDemoData: true,
      zones: [
        const FieldZone(
          name: 'Zone 1',
          healthScore: 90,
          soilMoisture: 55,
          temperature: 29,
          humidity: 64,
        ),
        const FieldZone(
          name: 'Zone 2',
          healthScore: 82,
          soilMoisture: 48,
          temperature: 31,
          humidity: 60,
        ),
        const FieldZone(
          name: 'Zone 3',
          healthScore: 84,
          soilMoisture: 53,
          temperature: 30,
          humidity: 63,
        ),
      ],
      problems: const [
        FieldProblem(
          title: 'Pest Risk',
          severity: 'Low',
          description:
              'Minor pest activity detected. No immediate action required but monitor.',
          affectedZone: 'Zone 2',
        ),
      ],
      improvements: const [
        FieldImprovement(
          title: 'Pest Monitoring',
          steps: [
            'Continue regular monitoring',
            'Inspect Zone 2 during field visits',
            'Apply preventive measures if activity increases',
          ],
        ),
      ],
    ),
    FarmField(
      id: 'demo_field_c',
      name: 'Field C',
      crop: 'Paddy',
      area: 4.0,
      location: 'South Section, Village Lakshmipur',
      sowingDate: DateTime(2026, 7, 1),
      healthScore: 42,
      soilMoisture: 72,
      temperature: 34,
      humidity: 78,
      lastScan: DateTime(2026, 8, 27, 8, 0),
      isDemoData: true,
      zones: [
        const FieldZone(
          name: 'Zone 1',
          healthScore: 50,
          soilMoisture: 70,
          temperature: 33,
          humidity: 76,
          problem: 'Heat Stress',
          severity: 'Medium',
          recommendation:
              'Ensure adequate water levels and consider shade structures for vulnerable areas.',
        ),
        const FieldZone(
          name: 'Zone 2',
          healthScore: 35,
          soilMoisture: 75,
          temperature: 36,
          humidity: 80,
          problem: 'Waterlogging Risk',
          severity: 'High',
          recommendation:
              'Improve drainage immediately. Excess moisture can damage root systems.',
        ),
        const FieldZone(
          name: 'Zone 3',
          healthScore: 48,
          soilMoisture: 68,
          temperature: 33,
          humidity: 77,
          problem: 'Nutrient Deficiency',
          severity: 'Medium',
          recommendation:
              'Apply balanced fertilizer and monitor nutrient uptake over the next 2 weeks.',
        ),
        const FieldZone(
          name: 'Zone 4',
          healthScore: 38,
          soilMoisture: 74,
          temperature: 35,
          humidity: 79,
          problem: 'Disease Risk',
          severity: 'High',
          recommendation:
              'Apply fungicide treatment as a preventive measure. Inspect for disease symptoms.',
        ),
      ],
      problems: const [
        FieldProblem(
          title: 'Waterlogging Risk',
          severity: 'High',
          description:
              'Excessive soil moisture in Zone 2 is creating waterlogging conditions.',
          affectedZone: 'Zone 2',
        ),
        FieldProblem(
          title: 'Disease Risk',
          severity: 'High',
          description:
              'High humidity and temperature are creating conditions favorable for fungal diseases.',
          affectedZone: 'Zone 4',
        ),
        FieldProblem(
          title: 'Heat Stress',
          severity: 'Medium',
          description:
              'Temperatures above 34°C are causing stress in paddy plants.',
          affectedZone: 'Zone 1',
        ),
      ],
      improvements: const [
        FieldImprovement(
          title: 'Drainage Improvement',
          steps: [
            'Clear drainage channels in Zone 2',
            'Create additional drainage pathways',
            'Monitor water levels daily',
          ],
        ),
        FieldImprovement(
          title: 'Disease Prevention',
          steps: [
            'Apply preventive fungicide in Zone 4',
            'Ensure proper spacing between plants',
            'Remove any visibly infected plants',
          ],
        ),
      ],
    ),
    FarmField(
      id: 'demo_field_d',
      name: 'Field D',
      crop: 'Maize',
      area: 2.5,
      location: 'West Farm, Village Chandpur',
      sowingDate: DateTime(2026, 6, 25),
      healthScore: 91,
      soilMoisture: 48,
      temperature: 29,
      humidity: 60,
      lastScan: DateTime(2026, 8, 26, 12, 0),
      isDemoData: true,
      zones: [
        const FieldZone(
          name: 'Zone 1',
          healthScore: 93,
          soilMoisture: 50,
          temperature: 28,
          humidity: 61,
        ),
        const FieldZone(
          name: 'Zone 2',
          healthScore: 89,
          soilMoisture: 46,
          temperature: 30,
          humidity: 59,
        ),
      ],
      problems: const [],
      improvements: const [
        FieldImprovement(
          title: 'Maintenance',
          steps: [
            'Continue current irrigation schedule',
            'Monitor for seasonal pest activity',
            'Plan harvest timeline',
          ],
        ),
      ],
    ),
  ];
}
