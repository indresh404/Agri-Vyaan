import type { AssessmentReport, FieldAsset, CropFinding } from '../types';

/**
 * PDF Generation Service using jsPDF
 * Generates real, downloadable PDF reports for AgriSwarm field intelligence.
 */
export const reportlabPdfService = {
  buildReportLabPayload(report: AssessmentReport, field: FieldAsset, findings: CropFinding[]) {
    return {
      metadata: {
        title: `AGRI_SWARM_INTELLIGENCE_REPORT_${report.id}`,
        author: 'Operator Vikram Sharma (#04)',
        subject: `Field Intelligence Diagnostic for ${report.fieldName}`,
        creator: 'AgriSwarm Operator Platform v2.4'
      },
      report,
      field,
      findings
    };
  },

  /**
   * Generates a real PDF using jsPDF and triggers browser download.
   */
  async exportReportLabPdf(
    report: AssessmentReport,
    field: FieldAsset,
    findings: CropFinding[]
  ): Promise<string> {
    // Dynamically import jsPDF so it only loads when needed
    const { jsPDF } = await import('jspdf');
    const doc = new jsPDF({ orientation: 'portrait', unit: 'mm', format: 'a4' });

    const W = 210; // A4 width mm
    const marginL = 18;
    const marginR = W - 18;
    const contentW = marginR - marginL;
    let y = 20;

    const colors = {
      green:    [48, 67, 46]   as [number, number, number],
      greenMid: [79, 104, 72]  as [number, number, number],
      dark:     [32, 35, 31]   as [number, number, number],
      grey:     [107, 112, 104] as [number, number, number],
      border:   [221, 222, 215] as [number, number, number],
      bgLight:  [250, 251, 248] as [number, number, number],
      red:      [182, 74, 67]  as [number, number, number],
      amber:    [184, 134, 45] as [number, number, number],
    };

    // ── Header Strip ──────────────────────────────────────────────────
    doc.setFillColor(...colors.green);
    doc.rect(0, 0, W, 22, 'F');

    doc.setTextColor(255, 255, 255);
    doc.setFontSize(7);
    doc.setFont('helvetica', 'bold');
    doc.text('AGRI SWARM OPERATOR PLATFORM', marginL, 9);

    doc.setFontSize(13);
    doc.text('FIELD INTELLIGENCE REPORT', marginL, 17);

    doc.setFontSize(7);
    doc.setFont('helvetica', 'normal');
    doc.text(`DOC: ${report.id}   DATE: ${report.generatedDate}`, marginR, 9, { align: 'right' });
    doc.text(`OP: ${report.operationId}`, marginR, 17, { align: 'right' });

    y = 30;

    // ── Meta Grid ────────────────────────────────────────────────────
    doc.setFillColor(...colors.bgLight);
    doc.setDrawColor(...colors.border);
    doc.roundedRect(marginL, y, contentW, 26, 2, 2, 'FD');

    doc.setTextColor(...colors.grey);
    doc.setFontSize(7);
    doc.setFont('helvetica', 'bold');

    const col1 = marginL + 4;
    const col2 = marginL + contentW / 2 + 2;

    const metaRows = [
      ['Farmer Name', report.farmerName, 'Field Asset', report.fieldName],
      ['Location', field.location || 'Maharashtra', 'Crop', `${field.crop} (${field.areaHa} ha)`],
      ['Health Score', `${report.healthIndexScore} / 100`, 'Status', report.status],
    ];

    let my = y + 6;
    for (const row of metaRows) {
      doc.setFont('helvetica', 'bold');
      doc.setTextColor(...colors.grey);
      doc.text(row[0] + ':', col1, my);
      doc.setFont('helvetica', 'normal');
      doc.setTextColor(...colors.dark);
      doc.text(row[1], col1 + 24, my);

      doc.setFont('helvetica', 'bold');
      doc.setTextColor(...colors.grey);
      doc.text(row[2] + ':', col2, my);
      doc.setFont('helvetica', 'normal');
      doc.setTextColor(...colors.dark);
      doc.text(row[3], col2 + 24, my);

      my += 7;
    }

    y = my + 4;

    // ── Health Score Bar ─────────────────────────────────────────────
    const scoreColor: [number, number, number] = report.healthIndexScore >= 80 ? colors.greenMid : colors.amber;
    doc.setFillColor(...colors.border);
    doc.roundedRect(marginL, y, contentW, 4, 2, 2, 'F');
    doc.setFillColor(...scoreColor);
    doc.roundedRect(marginL, y, contentW * (report.healthIndexScore / 100), 4, 2, 2, 'F');

    doc.setFontSize(7);
    doc.setFont('helvetica', 'bold');
    doc.setTextColor(...scoreColor);
    doc.text(`Canopy Vigor Index: ${report.healthIndexScore}%`, marginL, y + 9);

    y += 16;

    // ── Section 1 ─────────────────────────────────────────────────────
    doc.setDrawColor(...colors.greenMid);
    doc.setLineWidth(0.4);
    doc.line(marginL, y, marginR, y);
    y += 5;

    doc.setFontSize(9);
    doc.setFont('helvetica', 'bold');
    doc.setTextColor(...colors.dark);
    doc.text('1. Executive Field Vigor Summary', marginL, y);
    y += 5;

    doc.setFontSize(8);
    doc.setFont('helvetica', 'normal');
    doc.setTextColor(...colors.dark);
    const summary = `Multispectral aerial imaging conducted over ${report.fieldName} indicates an overall canopy vigor index of ${report.healthIndexScore}%. High canopy reflectance uniformity is maintained across the majority of grid zones surveyed during operation ${report.operationId}.`;
    const summaryLines = doc.splitTextToSize(summary, contentW);
    doc.text(summaryLines, marginL, y);
    y += summaryLines.length * 4.5 + 4;

    // ── Section 2 – Findings Table ────────────────────────────────────
    doc.setDrawColor(...colors.greenMid);
    doc.line(marginL, y, marginR, y);
    y += 5;

    doc.setFontSize(9);
    doc.setFont('helvetica', 'bold');
    doc.setTextColor(...colors.dark);
    doc.text('2. Validated Crop Anomalies & Detection Delineation', marginL, y);
    y += 5;

    if (findings.length === 0) {
      doc.setFontSize(8);
      doc.setFont('helvetica', 'italic');
      doc.setTextColor(...colors.grey);
      doc.text('No anomalies detected in this field scan.', marginL, y);
      y += 8;
    } else {
      // Table header
      const cols = [22, 62, 20, 24, 32];
      const headers = ['Zone', 'Finding Type', 'Confidence', 'Soil Moisture', 'Status'];
      let tx = marginL;

      doc.setFillColor(...colors.green);
      doc.rect(marginL, y, contentW, 6, 'F');
      doc.setTextColor(255, 255, 255);
      doc.setFontSize(7);
      doc.setFont('helvetica', 'bold');

      for (let i = 0; i < headers.length; i++) {
        doc.text(headers[i], tx + 2, y + 4);
        tx += cols[i];
      }
      y += 6;

      // Table rows
      for (let ri = 0; ri < findings.length; ri++) {
        const f = findings[ri];
        const isEven = ri % 2 === 0;
        doc.setFillColor(isEven ? 250 : 255, isEven ? 251 : 255, isEven ? 248 : 255);
        doc.rect(marginL, y, contentW, 6, 'F');
        doc.setDrawColor(...colors.border);
        doc.rect(marginL, y, contentW, 6, 'S');

        const rowData = [
          f.zoneId,
          f.findingType,
          `${f.confidencePercent}%`,
          `${f.soilMoisturePercent}%`,
          f.status
        ];

        tx = marginL;
        doc.setTextColor(...colors.dark);
        doc.setFont('helvetica', 'normal');
        doc.setFontSize(7);
        for (let ci = 0; ci < rowData.length; ci++) {
          const cell = doc.splitTextToSize(rowData[ci], cols[ci] - 3);
          doc.text(cell[0], tx + 2, y + 4);
          tx += cols[ci];
        }
        y += 6;
      }
      y += 4;
    }

    // ── Section 3 – Directives ────────────────────────────────────────
    doc.setDrawColor(...colors.greenMid);
    doc.line(marginL, y, marginR, y);
    y += 5;

    doc.setFontSize(9);
    doc.setFont('helvetica', 'bold');
    doc.setTextColor(...colors.dark);
    doc.text('3. Actionable Field Directives & Agronomic Recommendations', marginL, y);
    y += 5;

    doc.setFontSize(8);
    doc.setFont('helvetica', 'normal');
    doc.setTextColor(...colors.dark);

    for (const rec of report.priorityRecommendations) {
      doc.setFillColor(...colors.bgLight);
      const lines = doc.splitTextToSize(rec, contentW - 8);
      const rowH = lines.length * 4.5 + 5;
      doc.roundedRect(marginL, y, contentW, rowH, 1.5, 1.5, 'F');
      doc.setFillColor(...colors.greenMid);
      doc.rect(marginL, y, 2.5, rowH, 'F');
      doc.setTextColor(...colors.dark);
      doc.text(lines, marginL + 6, y + 4);
      y += rowH + 3;
    }

    // ── Footer ────────────────────────────────────────────────────────
    const footerY = 282;
    doc.setDrawColor(...colors.border);
    doc.line(marginL, footerY, marginR, footerY);
    doc.setFontSize(6.5);
    doc.setFont('helvetica', 'italic');
    doc.setTextColor(...colors.grey);
    doc.text(
      'Report compiled by Human Operator Vikram Sharma following radiometric calibration and ground truth verification. AgriSwarm Operator Platform v2.4.',
      marginL,
      footerY + 4
    );
    doc.text('CONFIDENTIAL — For authorized agronomist and farmer use only.', marginR, footerY + 4, { align: 'right' });

    // ── Trigger Download ──────────────────────────────────────────────
    const filename = `AGRI_SWARM_${report.id}_${field.crop.replace(/\s/g, '_')}.pdf`;
    doc.save(filename);

    // Return dummy URL for compatibility
    return '#';
  }
};
