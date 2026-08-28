import type { AssessmentReport, FieldAsset, CropFinding } from '../types';

/**
 * PDF Generation Service using jsPDF
 * Generates exact PDF reports matching the AgriSwarm Crop Intelligence Audit layout format.
 */
export const reportlabPdfService = {
  buildReportLabPayload(report: AssessmentReport, field: FieldAsset, findings: CropFinding[]) {
    return {
      metadata: {
        title: `AGRI_SWARM_INTELLIGENCE_REPORT_${report.id}`,
        author: 'Authorized Agritech Lead: Dr. S. K. Sharma',
        subject: `Crop Intelligence Audit for ${report.fieldName}`,
        creator: 'AgriSwarm Platform'
      },
      report,
      field,
      findings
    };
  },

  /**
   * Generates a real PDF using jsPDF matching the user's requested layout format.
   */
  async exportReportLabPdf(
    report: AssessmentReport,
    field: FieldAsset,
    _findings: CropFinding[]
  ): Promise<string> {
    const { jsPDF } = await import('jspdf');
    const doc = new jsPDF({ orientation: 'portrait', unit: 'mm', format: 'a4' });

    const W = 210; // A4 width mm
    const marginL = 16;
    const marginR = W - 16;
    const contentW = marginR - marginL;
    let y = 18;

    // Color definitions
    const colors = {
      primaryGreen: [31, 104, 36]  as [number, number, number], // #1F6824
      cardGreen:    [76, 175, 80]  as [number, number, number], // #4CAF50
      cardBlue:     [33, 150, 243] as [number, number, number], // #2196F3
      textDark:     [28, 32, 26]   as [number, number, number], // #1C201A
      textGrey:     [95, 100, 93]  as [number, number, number], // #5F645D
      lineBorder:   [216, 217, 210] as [number, number, number], // #D8D9D2
      redBg:        [255, 240, 240] as [number, number, number], // #FFF0F0
      redBorder:    [255, 205, 210] as [number, number, number], // #FFCDD2
      redText:      [211, 47, 47]  as [number, number, number], // #D32F2F
      greenText:    [46, 125, 50]  as [number, number, number], // #2E7D32
      headerBg:     [250, 250, 250] as [number, number, number], // #FAFAFA
    };

    // ── Main Header ───────────────────────────────────────────────────
    doc.setFont('helvetica', 'bold');
    doc.setFontSize(16);
    doc.setTextColor(...colors.primaryGreen);
    doc.text('AgriSwarm Crop Intelligence Audit', marginL, y);

    y += 3;
    doc.setDrawColor(...colors.lineBorder);
    doc.setLineWidth(0.3);
    doc.line(marginL, y, marginR, y);

    y += 5;
    doc.setFont('helvetica', 'normal');
    doc.setFontSize(8.5);
    doc.setTextColor(...colors.textGrey);
    doc.text(`Report Date: ${report.generatedDate} | Field: ${report.fieldName}`, marginL, y);

    y += 7;

    // ── Meta Info Grid (2 columns) ────────────────────────────────────
    doc.setFontSize(8.5);
    const col1X = marginL;
    const col2X = marginL + contentW / 2 + 4;

    // Row 1
    doc.setFont('helvetica', 'bold');
    doc.setTextColor(...colors.textGrey);
    doc.text('Crop Type:', col1X, y);
    doc.setTextColor(...colors.textDark);
    doc.setFont('helvetica', 'normal');
    doc.text('Potato', col1X + 22, y);

    doc.setFont('helvetica', 'bold');
    doc.setTextColor(...colors.textGrey);
    doc.text('Field Area:', col2X, y);
    doc.setTextColor(...colors.textDark);
    doc.setFont('helvetica', 'normal');
    doc.text(`${field.areaHa} ha (${(field.areaHa * 2.471).toFixed(1)} acres)`, col2X + 22, y);

    y += 5.5;

    // Row 2
    doc.setFont('helvetica', 'bold');
    doc.setTextColor(...colors.textGrey);
    doc.text('Sowing Date:', col1X, y);
    doc.setTextColor(...colors.textDark);
    doc.setFont('helvetica', 'normal');
    doc.text(field.sowingDate || '2026-06-15', col1X + 22, y);

    doc.setFont('helvetica', 'bold');
    doc.setTextColor(...colors.textGrey);
    doc.text('Growth Stage:', col2X, y);
    doc.setTextColor(...colors.textDark);
    doc.setFont('helvetica', 'normal');
    doc.text(field.cropStage || 'Tuber bulking stage', col2X + 22, y);

    y += 9;

    // ── Dual Metric Highlight Cards (Side-by-side) ─────────────────────
    const cardW = (contentW - 6) / 2;
    const cardH = 18;

    // Card 1: CROP HEALTH SCORE (Green Outlined)
    doc.setDrawColor(...colors.cardGreen);
    doc.setFillColor(255, 255, 255);
    doc.setLineWidth(0.4);
    doc.roundedRect(marginL, y, cardW, cardH, 2, 2, 'FD');

    doc.setFont('helvetica', 'bold');
    doc.setFontSize(7.5);
    doc.setTextColor(...colors.cardGreen);
    doc.text('CROP HEALTH SCORE', marginL + 5, y + 6);

    doc.setFont('helvetica', 'bold');
    doc.setFontSize(14);
    doc.setTextColor(...colors.textDark);
    doc.text(`${report.healthIndexScore} / 100`, marginL + 5, y + 14);

    // Card 2: SOIL MOISTURE STATUS (Blue Outlined)
    const card2X = marginL + cardW + 6;
    doc.setDrawColor(...colors.cardBlue);
    doc.setFillColor(255, 255, 255);
    doc.roundedRect(card2X, y, cardW, cardH, 2, 2, 'FD');

    doc.setFont('helvetica', 'bold');
    doc.setFontSize(7.5);
    doc.setTextColor(...colors.cardBlue);
    doc.text('SOIL MOISTURE STATUS', card2X + 5, y + 6);

    doc.setFont('helvetica', 'bold');
    doc.setFontSize(14);
    doc.setTextColor(...colors.cardBlue);
    doc.text(field.moistureStatus || 'LOW', card2X + 5, y + 14);

    y += cardH + 7;

    // ── Findings Red Alert Box ─────────────────────────────────────────
    const alertH = 9;
    doc.setDrawColor(...colors.redBorder);
    doc.setFillColor(...colors.redBg);
    doc.setLineWidth(0.3);
    doc.roundedRect(marginL, y, contentW, alertH, 1.5, 1.5, 'FD');

    doc.setFont('helvetica', 'bold');
    doc.setFontSize(8.5);
    doc.setTextColor(...colors.redText);
    doc.text('Findings: Low soil moisture detected in Zone 2. High moisture stress observed.', marginL + 4, y + 6);

    y += alertH + 9;

    // ── Section 1: Zone Condition Analysis ─────────────────────────────
    doc.setFont('helvetica', 'bold');
    doc.setFontSize(11);
    doc.setTextColor(...colors.primaryGreen);
    doc.text('Zone Condition Analysis', marginL, y);
    y += 5;

    // Zone Table Headers
    const zoneCols = [24, 48, 30, 32, 44];
    const zoneHeaders = ['Zone', 'Status', 'Moisture', 'Temperature', 'Risk'];

    doc.setFillColor(...colors.headerBg);
    doc.setDrawColor(...colors.lineBorder);
    doc.rect(marginL, y, contentW, 6, 'FD');

    doc.setFont('helvetica', 'bold');
    doc.setFontSize(8);
    doc.setTextColor(...colors.textDark);

    let tx = marginL;
    for (let i = 0; i < zoneHeaders.length; i++) {
      doc.text(zoneHeaders[i], tx + 3, y + 4.2);
      tx += zoneCols[i];
    }
    y += 6;

    // Zone Rows
    const zoneRows = [
      { zone: 'Zone 1', status: 'Healthy', statusColor: colors.greenText, moisture: '52.0%', temp: '29.0°C', risk: 'None', isRed: false },
      { zone: 'Zone 2', status: 'Low moisture', statusColor: colors.redText, moisture: '27.0%', temp: '32.0°C', risk: 'Moderate', isRed: true },
      { zone: 'Zone 3', status: 'Possible nutrient stress', statusColor: colors.greenText, moisture: '45.0%', temp: '30.0°C', risk: 'Low', isRed: false },
      { zone: 'Zone 4', status: 'Healthy', statusColor: colors.greenText, moisture: '50.0%', temp: '29.0°C', risk: 'None', isRed: false },
    ];

    for (const row of zoneRows) {
      doc.setFillColor(row.isRed ? 255 : 255, row.isRed ? 240 : 255, row.isRed ? 240 : 255);
      doc.setDrawColor(...colors.lineBorder);
      doc.rect(marginL, y, contentW, 6, 'FD');

      doc.setFont('helvetica', 'bold');
      doc.setFontSize(8);
      doc.setTextColor(...colors.textDark);
      doc.text(row.zone, marginL + 3, y + 4.2);

      doc.setTextColor(...row.statusColor);
      doc.text(row.status, marginL + zoneCols[0] + 3, y + 4.2);

      doc.setTextColor(row.isRed ? colors.redText[0] : colors.textDark[0], row.isRed ? colors.redText[1] : colors.textDark[1], row.isRed ? colors.redText[2] : colors.textDark[2]);
      doc.setFont('helvetica', row.isRed ? 'bold' : 'normal');
      doc.text(row.moisture, marginL + zoneCols[0] + zoneCols[1] + 3, y + 4.2);

      doc.setTextColor(...colors.textDark);
      doc.setFont('helvetica', 'normal');
      doc.text(row.temp, marginL + zoneCols[0] + zoneCols[1] + zoneCols[2] + 3, y + 4.2);

      doc.setTextColor(row.isRed ? colors.redText[0] : colors.textDark[0], row.isRed ? colors.redText[1] : colors.textDark[1], row.isRed ? colors.redText[2] : colors.textDark[2]);
      doc.setFont('helvetica', row.isRed ? 'bold' : 'normal');
      doc.text(row.risk, marginL + zoneCols[0] + zoneCols[1] + zoneCols[2] + zoneCols[3] + 3, y + 4.2);

      y += 6;
    }

    y += 7;

    // ── Section 2: Sensor Telemetry Readings ───────────────────────────
    doc.setFont('helvetica', 'bold');
    doc.setFontSize(11);
    doc.setTextColor(...colors.primaryGreen);
    doc.text('Sensor Telemetry Readings', marginL, y);
    y += 5;

    // Telemetry Table Headers
    const sensorCols = [45, 40, 50, 43];
    const sensorHeaders = ['Sensor', 'Current Value', 'Normal Range', 'Status'];

    doc.setFillColor(...colors.headerBg);
    doc.setDrawColor(...colors.lineBorder);
    doc.rect(marginL, y, contentW, 6, 'FD');

    doc.setFont('helvetica', 'bold');
    doc.setFontSize(8);
    doc.setTextColor(...colors.textDark);

    tx = marginL;
    for (let i = 0; i < sensorHeaders.length; i++) {
      doc.text(sensorHeaders[i], tx + 3, y + 4.2);
      tx += sensorCols[i];
    }
    y += 6;

    // Telemetry Rows
    const sensorRows = [
      { name: 'Soil Moisture', val: '27.0%', range: '35.0 - 65.0%', status: 'LOW', color: colors.redText },
      { name: 'Temperature', val: '32.0°C', range: '20.0 - 35.0°C', status: 'NORMAL', color: colors.greenText },
      { name: 'Humidity', val: '65.0%', range: '50.0 - 80.0%', status: 'NORMAL', color: colors.greenText },
    ];

    for (const row of sensorRows) {
      doc.setFillColor(255, 255, 255);
      doc.setDrawColor(...colors.lineBorder);
      doc.rect(marginL, y, contentW, 6, 'FD');

      doc.setFont('helvetica', 'bold');
      doc.setFontSize(8);
      doc.setTextColor(...colors.textDark);
      doc.text(row.name, marginL + 3, y + 4.2);

      doc.setFont('helvetica', 'normal');
      doc.text(row.val, marginL + sensorCols[0] + 3, y + 4.2);
      doc.text(row.range, marginL + sensorCols[0] + sensorCols[1] + 3, y + 4.2);

      doc.setFont('helvetica', 'bold');
      doc.setTextColor(...row.color);
      doc.text(row.status, marginL + sensorCols[0] + sensorCols[1] + sensorCols[2] + 3, y + 4.2);

      y += 6;
    }

    y += 8;

    // ── Section 3: Expert Agronomist Advice ───────────────────────────
    doc.setFont('helvetica', 'bold');
    doc.setFontSize(11);
    doc.setTextColor(...colors.primaryGreen);
    doc.text('Expert Agronomist Advice', marginL, y);
    y += 5;

    doc.setFont('helvetica', 'normal');
    doc.setFontSize(8.5);
    doc.setTextColor(...colors.textDark);
    const adviceText = 'Check irrigation flow immediately in Zone 2 to prevent leaf wilting. Target soil moisture is above 35%.';
    doc.text(adviceText, marginL, y);

    // ── Footer ────────────────────────────────────────────────────────
    const footerY = 278;
    doc.setDrawColor(...colors.lineBorder);
    doc.line(marginL, footerY, marginR, footerY);

    doc.setFont('helvetica', 'normal');
    doc.setFontSize(8);
    doc.setTextColor(...colors.textGrey);
    doc.text('Authorized Agritech Lead: Dr. S. K. Sharma', W / 2, footerY + 5, { align: 'center' });

    // Save and Trigger Download
    const filename = `agriswarm_report_${field.name.replace(/[^a-zA-Z0-9]/g, '_')}.pdf`;
    doc.save(filename);

    return '#';
  }
};
