/**
 * Mission Planner / QGroundControl Waypoint File Exporter (.waypoints / WPL 110 format)
 */

export interface WaypointsExportOptions {
  fieldName: string;
  farmerName?: string;
  altitudeMeters?: number;
  coordinates: [number, number][]; // [lat, lng] array
}

export function generateWaypointsContent(options: WaypointsExportOptions): string {
  const { altitudeMeters = 45, coordinates } = options;

  if (!coordinates || coordinates.length === 0) {
    throw new Error('At least 1 coordinate is required to generate waypoints.');
  }

  const lines: string[] = ['QGC WPL 110'];

  // Waypoint 0: Home position (first coordinate, 0m altitude)
  const homeLat = coordinates[0][0].toFixed(6);
  const homeLng = coordinates[0][1].toFixed(6);
  lines.push(`0\t1\t0\t16\t0.000000\t0.000000\t0.000000\t0.000000\t${homeLat}\t${homeLng}\t0.000000\t1`);

  // Waypoints 1...N: Mission survey waypoints at specified altitude
  coordinates.forEach(([lat, lng], idx) => {
    const latStr = lat.toFixed(6);
    const lngStr = lng.toFixed(6);
    const altStr = altitudeMeters.toFixed(6);
    // Command 16 = MAV_CMD_NAV_WAYPOINT, Frame 3 = MAV_FRAME_GLOBAL_RELATIVE_ALT
    lines.push(`${idx + 1}\t0\t3\t16\t0.000000\t0.000000\t0.000000\t0.000000\t${latStr}\t${lngStr}\t${altStr}\t1`);
  });

  return lines.join('\n');
}

export function downloadWaypointsFile(options: WaypointsExportOptions): void {
  const content = generateWaypointsContent(options);
  const blob = new Blob([content], { type: 'text/plain;charset=utf-8' });
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  const sanitizedName = options.fieldName.toLowerCase().replace(/[^a-z0-9]/g, '_');
  link.download = `${sanitizedName}_mission.waypoints`;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  URL.revokeObjectURL(url);
}
