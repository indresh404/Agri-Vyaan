import React, { useState } from 'react';
import type { AssessmentReport, FieldAsset } from '../../types';
import { MOCK_FIELDS, MOCK_FINDINGS } from '../../data/mockData';
import { reportlabPdfService } from '../../lib/reportlabPdfService';
import { Download } from 'lucide-react';

interface ReportsViewProps {
  reports: AssessmentReport[];
  onNavigate?: (tab: any) => void;
}

export const ReportsView: React.FC<ReportsViewProps> = ({ reports }) => {
  const [selectedReportId, setSelectedReportId] = useState<string>(reports[0]?.id || 'REP-904');
  const selectedReport = reports.find(r => r.id === selectedReportId) || reports[0];

  const targetField: FieldAsset = MOCK_FIELDS.find(f => f.name === selectedReport?.fieldName || f.id === selectedReport?.fieldName) || MOCK_FIELDS[0];

  return (
    <div style={{ padding: '20px 24px', display: 'flex', flexDirection: 'column', gap: '20px' }}>
      {/* Page Title */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 style={{ fontSize: '22px', fontWeight: 700, color: '#1C201A', margin: 0 }}>
            AgriSwarm Crop Intelligence Audits
          </h1>
          <p style={{ fontSize: '13px', color: '#5F645D', marginTop: '2px' }}>
            Validated agronomic field reports with sensor telemetry, zone risk analysis, and expert advice.
          </p>
        </div>
        <button
          className="op-btn op-btn-primary"
          onClick={async () => {
            if (selectedReport) {
              const findings = MOCK_FINDINGS.filter(f => f.operationId === selectedReport.operationId || f.fieldId === targetField.id);
              await reportlabPdfService.exportReportLabPdf(selectedReport, targetField, findings);
            }
          }}
        >
          <Download size={14} /> Export PDF Report
        </button>
      </div>

      {/* Main Grid: Left List + Right Report Document */}
      <div style={{ display: 'grid', gridTemplateColumns: '320px 1fr', gap: '20px', alignItems: 'start' }}>
        {/* Left Side: Report Selection List */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
          <div style={{ fontSize: '11px', fontWeight: 700, color: '#5F645D', textTransform: 'uppercase', paddingLeft: '2px' }}>
            Generated Field Audits ({reports.length})
          </div>
          {reports.map(rep => {
            const isSelected = rep.id === selectedReportId;
            return (
              <div
                key={rep.id}
                onClick={() => setSelectedReportId(rep.id)}
                style={{
                  backgroundColor: '#FFFFFF',
                  border: isSelected ? '2px solid #1F6824' : '1px solid #D8D9D2',
                  borderRadius: '6px',
                  padding: '14px',
                  cursor: 'pointer',
                  boxShadow: isSelected ? '0 2px 6px rgba(31,104,36,0.12)' : 'none',
                  transition: 'all 0.15s ease'
                }}
              >
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '4px' }}>
                  <span style={{ fontFamily: 'monospace', fontSize: '12px', fontWeight: 700, color: '#1C201A' }}>
                    {rep.id}
                  </span>
                  <span
                    style={{
                      fontSize: '10px',
                      fontWeight: 700,
                      padding: '2px 6px',
                      borderRadius: '3px',
                      backgroundColor: rep.status === 'Ready' ? '#E7EFE5' : rep.status === 'Sent' ? '#EBF3F8' : '#FEF5E4',
                      color: rep.status === 'Ready' ? '#2A3B27' : rep.status === 'Sent' ? '#4B6B80' : '#B07E28'
                    }}
                  >
                    {rep.status}
                  </span>
                </div>
                <div style={{ fontSize: '14px', fontWeight: 700, color: '#1C201A' }}>
                  {rep.fieldName}
                </div>
                <div style={{ fontSize: '12px', color: '#5F645D', marginTop: '2px' }}>
                  Farmer: {rep.farmerName}
                </div>
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '11px', color: '#5F645D', marginTop: '8px', paddingTop: '8px', borderTop: '1px solid #E8E9E3' }}>
                  <span>Score: <strong style={{ color: rep.healthIndexScore >= 80 ? '#2E7D32' : '#D32F2F' }}>{rep.healthIndexScore}/100</strong></span>
                  <span>{rep.generatedDate}</span>
                </div>
              </div>
            );
          })}
        </div>

        {/* Right Side: Exact PDF/HTML Preview Document Layout requested by User */}
        {selectedReport && (
          <div
            style={{
              backgroundColor: '#FFFFFF',
              border: '1px solid #D8D9D2',
              borderRadius: '8px',
              padding: '36px 40px',
              boxShadow: '0 4px 16px rgba(0,0,0,0.06)',
              display: 'flex',
              flexDirection: 'column',
              gap: '16px'
            }}
          >
            {/* Green Main Header */}
            <div>
              <h1 style={{ fontSize: '24px', fontWeight: 700, color: '#1F6824', margin: 0 }}>
                AgriSwarm Crop Intelligence Audit
              </h1>
              <hr style={{ border: 0, borderTop: '1px solid #D8D9D2', margin: '8px 0 6px 0' }} />
              <div style={{ fontSize: '12px', color: '#5F645D' }}>
                Report Date: {selectedReport.generatedDate} | Field: {selectedReport.fieldName}
              </div>
            </div>

            {/* Meta Grid (2 columns) */}
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '8px 24px', fontSize: '13px', color: '#1C201A' }}>
              <div>
                <span style={{ color: '#5F645D' }}>Crop Type: </span>
                <strong>Potato</strong>
              </div>
              <div>
                <span style={{ color: '#5F645D' }}>Field Area: </span>
                <strong>{targetField.areaHa} ha ({(targetField.areaHa * 2.471).toFixed(1)} acres)</strong>
              </div>
              <div>
                <span style={{ color: '#5F645D' }}>Sowing Date: </span>
                <strong>{targetField.sowingDate || '2026-06-15'}</strong>
              </div>
              <div>
                <span style={{ color: '#5F645D' }}>Growth Stage: </span>
                <strong>{targetField.cropStage || 'Tuber bulking stage'}</strong>
              </div>
            </div>

            {/* Dual Outlined KPI Highlight Cards (Side-by-Side) */}
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px', margin: '6px 0' }}>
              {/* Crop Health Score Card */}
              <div
                style={{
                  border: '1px solid #4CAF50',
                  borderRadius: '6px',
                  padding: '14px 18px',
                  backgroundColor: '#FFFFFF'
                }}
              >
                <div style={{ fontSize: '11px', fontWeight: 700, color: '#4CAF50', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
                  CROP HEALTH SCORE
                </div>
                <div style={{ fontSize: '28px', fontWeight: 800, color: '#1C201A', marginTop: '4px', fontFamily: 'monospace' }}>
                  {selectedReport.healthIndexScore} / 100
                </div>
              </div>

              {/* Soil Moisture Status Card */}
              <div
                style={{
                  border: '1px solid #2196F3',
                  borderRadius: '6px',
                  padding: '14px 18px',
                  backgroundColor: '#FFFFFF'
                }}
              >
                <div style={{ fontSize: '11px', fontWeight: 700, color: '#2196F3', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
                  SOIL MOISTURE STATUS
                </div>
                <div style={{ fontSize: '28px', fontWeight: 800, color: '#2196F3', marginTop: '4px', fontFamily: 'monospace' }}>
                  {targetField.moistureStatus || 'LOW'}
                </div>
              </div>
            </div>

            {/* Red Alert Findings Banner */}
            <div
              style={{
                border: '1px solid #FFCDD2',
                backgroundColor: '#FFF0F0',
                borderRadius: '4px',
                padding: '12px 16px',
                color: '#D32F2F',
                fontSize: '13px',
                fontWeight: 600,
                lineHeight: 1.4
              }}
            >
              Findings: Low soil moisture detected in Zone 2. High moisture stress observed.
            </div>

            {/* Section 1: Zone Condition Analysis */}
            <div style={{ marginTop: '8px' }}>
              <h2 style={{ fontSize: '16px', fontWeight: 700, color: '#1F6824', margin: '0 0 10px 0' }}>
                Zone Condition Analysis
              </h2>
              <div className="op-table-container">
                <table className="op-table" style={{ fontSize: '13px', width: '100%', borderCollapse: 'collapse' }}>
                  <thead>
                    <tr style={{ backgroundColor: '#FAFAFA', borderBottom: '1px solid #E0E0E0' }}>
                      <th style={{ padding: '8px 12px', textAlign: 'left', fontWeight: 700, color: '#1C201A' }}>Zone</th>
                      <th style={{ padding: '8px 12px', textAlign: 'left', fontWeight: 700, color: '#1C201A' }}>Status</th>
                      <th style={{ padding: '8px 12px', textAlign: 'left', fontWeight: 700, color: '#1C201A' }}>Moisture</th>
                      <th style={{ padding: '8px 12px', textAlign: 'left', fontWeight: 700, color: '#1C201A' }}>Temperature</th>
                      <th style={{ padding: '8px 12px', textAlign: 'left', fontWeight: 700, color: '#1C201A' }}>Risk</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr style={{ borderBottom: '1px solid #F0F0F0' }}>
                      <td style={{ padding: '8px 12px', fontWeight: 600 }}>Zone 1</td>
                      <td style={{ padding: '8px 12px', color: '#2E7D32', fontWeight: 600 }}>Healthy</td>
                      <td style={{ padding: '8px 12px', fontFamily: 'monospace' }}>52.0%</td>
                      <td style={{ padding: '8px 12px', fontFamily: 'monospace' }}>29.0°C</td>
                      <td style={{ padding: '8px 12px' }}>None</td>
                    </tr>
                    <tr style={{ borderBottom: '1px solid #F0F0F0', backgroundColor: '#FFF0F0' }}>
                      <td style={{ padding: '8px 12px', fontWeight: 600 }}>Zone 2</td>
                      <td style={{ padding: '8px 12px', color: '#D32F2F', fontWeight: 600 }}>Low moisture</td>
                      <td style={{ padding: '8px 12px', fontFamily: 'monospace', color: '#D32F2F', fontWeight: 700 }}>27.0%</td>
                      <td style={{ padding: '8px 12px', fontFamily: 'monospace' }}>32.0°C</td>
                      <td style={{ padding: '8px 12px', color: '#D32F2F', fontWeight: 600 }}>Moderate</td>
                    </tr>
                    <tr style={{ borderBottom: '1px solid #F0F0F0' }}>
                      <td style={{ padding: '8px 12px', fontWeight: 600 }}>Zone 3</td>
                      <td style={{ padding: '8px 12px', color: '#2E7D32', fontWeight: 600 }}>Possible nutrient stress</td>
                      <td style={{ padding: '8px 12px', fontFamily: 'monospace' }}>45.0%</td>
                      <td style={{ padding: '8px 12px', fontFamily: 'monospace' }}>30.0°C</td>
                      <td style={{ padding: '8px 12px' }}>Low</td>
                    </tr>
                    <tr style={{ borderBottom: '1px solid #F0F0F0' }}>
                      <td style={{ padding: '8px 12px', fontWeight: 600 }}>Zone 4</td>
                      <td style={{ padding: '8px 12px', color: '#2E7D32', fontWeight: 600 }}>Healthy</td>
                      <td style={{ padding: '8px 12px', fontFamily: 'monospace' }}>50.0%</td>
                      <td style={{ padding: '8px 12px', fontFamily: 'monospace' }}>29.0°C</td>
                      <td style={{ padding: '8px 12px' }}>None</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>

            {/* Section 2: Sensor Telemetry Readings */}
            <div style={{ marginTop: '8px' }}>
              <h2 style={{ fontSize: '16px', fontWeight: 700, color: '#1F6824', margin: '0 0 10px 0' }}>
                Sensor Telemetry Readings
              </h2>
              <div className="op-table-container">
                <table className="op-table" style={{ fontSize: '13px', width: '100%', borderCollapse: 'collapse' }}>
                  <thead>
                    <tr style={{ backgroundColor: '#FAFAFA', borderBottom: '1px solid #E0E0E0' }}>
                      <th style={{ padding: '8px 12px', textAlign: 'left', fontWeight: 700, color: '#1C201A' }}>Sensor</th>
                      <th style={{ padding: '8px 12px', textAlign: 'left', fontWeight: 700, color: '#1C201A' }}>Current Value</th>
                      <th style={{ padding: '8px 12px', textAlign: 'left', fontWeight: 700, color: '#1C201A' }}>Normal Range</th>
                      <th style={{ padding: '8px 12px', textAlign: 'left', fontWeight: 700, color: '#1C201A' }}>Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr style={{ borderBottom: '1px solid #F0F0F0' }}>
                      <td style={{ padding: '8px 12px', fontWeight: 600 }}>Soil Moisture</td>
                      <td style={{ padding: '8px 12px', fontFamily: 'monospace' }}>27.0%</td>
                      <td style={{ padding: '8px 12px', fontFamily: 'monospace' }}>35.0 - 65.0%</td>
                      <td style={{ padding: '8px 12px', color: '#D32F2F', fontWeight: 700 }}>LOW</td>
                    </tr>
                    <tr style={{ borderBottom: '1px solid #F0F0F0' }}>
                      <td style={{ padding: '8px 12px', fontWeight: 600 }}>Temperature</td>
                      <td style={{ padding: '8px 12px', fontFamily: 'monospace' }}>32.0°C</td>
                      <td style={{ padding: '8px 12px', fontFamily: 'monospace' }}>20.0 - 35.0°C</td>
                      <td style={{ padding: '8px 12px', color: '#2E7D32', fontWeight: 700 }}>NORMAL</td>
                    </tr>
                    <tr style={{ borderBottom: '1px solid #F0F0F0' }}>
                      <td style={{ padding: '8px 12px', fontWeight: 600 }}>Humidity</td>
                      <td style={{ padding: '8px 12px', fontFamily: 'monospace' }}>65.0%</td>
                      <td style={{ padding: '8px 12px', fontFamily: 'monospace' }}>50.0 - 80.0%</td>
                      <td style={{ padding: '8px 12px', color: '#2E7D32', fontWeight: 700 }}>NORMAL</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>

            {/* Section 3: Expert Agronomist Advice */}
            <div style={{ marginTop: '8px' }}>
              <h2 style={{ fontSize: '16px', fontWeight: 700, color: '#1F6824', margin: '0 0 8px 0' }}>
                Expert Agronomist Advice
              </h2>
              <p style={{ fontSize: '13px', color: '#1C201A', lineHeight: 1.5, margin: 0 }}>
                Check irrigation flow immediately in Zone 2 to prevent leaf wilting. Target soil moisture is above 35%.
              </p>
            </div>

            {/* Footer */}
            <div style={{ marginTop: '16px', paddingTop: '16px', borderTop: '1px solid #E0E0E0', textAlign: 'center', fontSize: '12px', color: '#616161' }}>
              Authorized Agritech Lead: Dr. S. K. Sharma
            </div>
          </div>
        )}
      </div>
    </div>
  );
};
