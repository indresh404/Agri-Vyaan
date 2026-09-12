/**
 * KML Export Utility for Mission Planner / QGroundControl / Pixhawk UAVs
 */

export interface KMLExportOptions {
  fieldName: string;
  farmerName?: string;
  crop?: string;
  areaHa?: number;
  perimeterMeters?: number;
  coordinates: [number, number][]; // [lat, lng] array
}

export function generateKMLContent(options: KMLExportOptions): string {
  const { fieldName, farmerName = 'N/A', crop = 'N/A', areaHa, perimeterMeters, coordinates } = options;

  if (!coordinates || coordinates.length < 3) {
    throw new Error('At least 3 coordinates are required to export a boundary polygon.');
  }

  // Ensure polygon is closed (first coord matches last coord)
  const closedCoords = [...coordinates];
  const first = closedCoords[0];
  const last = closedCoords[closedCoords.length - 1];
  if (first[0] !== last[0] || first[1] !== last[1]) {
    closedCoords.push([first[0], first[1]]);
  }

  // KML standard coordinates format: longitude,latitude,altitude
  const kmlCoordsString = closedCoords
    .map(([lat, lng]) => `${lng.toFixed(6)},${lat.toFixed(6)},0`)
    .join('\n            ');

  return `<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <name>${escapeXml(fieldName)} Mission Boundary</name>
    <description>Exported from AgriSwarm GIS Platform for Pixhawk / Mission Planner</description>
    
    <Style id="fieldBoundaryStyle">
      <LineStyle>
        <color>ff00e5ff</color>
        <width>3</width>
      </LineStyle>
      <PolyStyle>
        <color>4000e5ff</color>
        <fill>1</fill>
        <outline>1</outline>
      </PolyStyle>
    </Style>

    <Placemark>
      <name>${escapeXml(fieldName)}</name>
      <description>
        <![CDATA[
          <b>Field Name:</b> ${escapeXml(fieldName)}<br/>
          <b>Farmer:</b> ${escapeXml(farmerName)}<br/>
          <b>Crop:</b> ${escapeXml(crop)}<br/>
          ${areaHa ? `<b>Calculated Area:</b> ${areaHa} ha<br/>` : ''}
          ${perimeterMeters ? `<b>Perimeter:</b> ${perimeterMeters} m<br/>` : ''}
          <b>Exported For:</b> Mission Planner / Pixhawk Drone Scanning
        ]]>
      </description>
      <styleUrl>#fieldBoundaryStyle</styleUrl>
      <Polygon>
        <extrude>1</extrude>
        <altitudeMode>relativeToGround</altitudeMode>
        <outerBoundaryIs>
          <LinearRing>
            <coordinates>
              ${kmlCoordsString}
            </coordinates>
          </LinearRing>
        </outerBoundaryIs>
      </Polygon>
    </Placemark>
  </Document>
</kml>`;
}

export function downloadKMLFile(options: KMLExportOptions): void {
  const xmlContent = generateKMLContent(options);
  const blob = new Blob([xmlContent], { type: 'application/vnd.google-earth.kml+xml;charset=utf-8' });
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  const sanitizedName = options.fieldName.toLowerCase().replace(/[^a-z0-9]/g, '_');
  link.download = `${sanitizedName}_mission_boundary.kml`;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  URL.revokeObjectURL(url);
}

function escapeXml(unsafe: string): string {
  return unsafe
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&apos;');
}
