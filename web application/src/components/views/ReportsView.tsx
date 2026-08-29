import React, { useState } from 'react';
import type { AssessmentReport, FieldAsset } from '../../types';
import { MOCK_FIELDS, MOCK_FINDINGS } from '../../data/mockData';
import { reportlabPdfService } from '../../lib/reportlabPdfService';
import { Download } from 'lucide-react';

interface ReportsViewProps {
  reports: AssessmentReport[];
  onNavigate?: (tab: any) => void;
}

// ─── Inline Table Styles ──────────────────────────────────────────────────────
const TH: React.CSSProperties = {
  padding: '7px 10px',
  textAlign: 'left',
  fontWeight: 700,
  fontSize: '12px',
  color: '#1C201A',
  backgroundColor: '#F5F6F2',
  borderBottom: '1px solid #D8D9D2',
  borderRight: '1px solid #E8E9E3',
};
const TD: React.CSSProperties = {
  padding: '7px 10px',
  fontSize: '12px',
  color: '#2D3129',
  borderBottom: '1px solid #ECEEE8',
  borderRight: '1px solid #ECEEE8',
};

// ─── Section Header ───────────────────────────────────────────────────────────
const SectionHeader: React.FC<{ title: string }> = ({ title }) => (
  <div style={{ marginBottom: '6px' }}>
    <div style={{
      fontSize: '13px',
      fontWeight: 800,
      color: '#1F6824',
      textTransform: 'uppercase',
      letterSpacing: '0.4px',
      borderBottom: '2px solid #1F6824',
      paddingBottom: '3px',
      marginBottom: '6px',
    }}>
      {title}
    </div>
  </div>
);

// ─── Progress Bar ─────────────────────────────────────────────────────────────
const ProgressBar: React.FC<{ value: number; max?: number; color: string }> = ({ value, max = 100, color }) => (
  <div style={{ height: '6px', backgroundColor: '#E0E0E0', borderRadius: '3px', marginTop: '6px' }}>
    <div style={{ height: '6px', width: `${(value / max) * 100}%`, backgroundColor: color, borderRadius: '3px' }} />
  </div>
);

// ─── Mini Bar Chart ───────────────────────────────────────────────────────────
const MiniBarChart: React.FC<{ data: { label: string; value: number }[]; color: string }> = ({ data, color }) => {
  const maxVal = Math.max(...data.map(d => d.value));
  return (
    <div style={{ display: 'flex', alignItems: 'flex-end', gap: '10px', height: '70px', paddingBottom: '4px' }}>
      {data.map((d, i) => (
        <div key={i} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', flex: 1, gap: '4px' }}>
          <span style={{ fontSize: '10px', fontWeight: 700, color: '#1C201A' }}>{d.value}</span>
          <div style={{
            width: '100%',
            height: `${(d.value / maxVal) * 52}px`,
            backgroundColor: color,
            borderRadius: '2px 2px 0 0',
          }} />
          <span style={{ fontSize: '9px', color: '#5F645D', whiteSpace: 'nowrap' }}>{d.label}</span>
        </div>
      ))}
    </div>
  );
};

// ─── Potato-specific Zone Data ────────────────────────────────────────────────
const ZONE_DATA = [
  { zone: 'Zone 1', status: 'Late Blight Risk', statusColor: '#D32F2F', moisture: '38.0%', temp: '22.0°C', risk: 'High' },
  { zone: 'Zone 2', status: 'Low Moisture Stress', statusColor: '#D32F2F', moisture: '27.0%', temp: '32.0°C', risk: 'High' },
  { zone: 'Zone 3', status: 'Nutrient Deficiency', statusColor: '#E65100', moisture: '45.0%', temp: '28.0°C', risk: 'Medium' },
  { zone: 'Zone 4', status: 'Early Blight Risk', statusColor: '#B07E28', moisture: '50.0%', temp: '29.0°C', risk: 'Medium' },
];

const SENSOR_DATA = [
  { name: 'Soil Moisture', value: '27.0%', range: '35.0–65.0%', status: 'LOW', statusColor: '#D32F2F' },
  { name: 'Temperature', value: '32.0°C', range: '20.0–35.0°C', status: 'NORMAL', statusColor: '#2E7D32' },
  { name: 'Humidity', value: '65.0%', range: '50.0–80.0%', status: 'NORMAL', statusColor: '#2E7D32' },
];

const DRONE_IMAGERY = [
  { label: 'Zone 1 Drone Scan', zone: 'Zone 1', assessment: 'Warning: Late Blight Lesions Detected' },
  { label: 'Zone 2 Drone Scan', zone: 'Zone 2', assessment: 'Warning: Low Moisture Stress' },
  { label: 'Zone 3 Drone Scan', zone: 'Zone 3', assessment: 'Warning: Nutrient Deficiency' },
  { label: 'Zone 4 Drone Scan', zone: 'Zone 4', assessment: 'Warning: Early Blight Risk' },
];

const TELEMETRY_TREND = [
  { metric: 'Crop Health Score', s1: 58, s2: 65, s3: 72, current: 78 },
  { metric: 'Soil Moisture (%)', s1: 22, s2: 25, s3: 27, current: 27 },
];

const RECOMMENDATIONS = [
  {
    zone: 'Zone 1',
    problem: 'Late Blight Risk in Zone 1',
    assessment: 'AI Assessment: Issue detected: Late Blight (Phytophthora infestans)',
    action: 'Action Plan: Apply Metalaxyl-M + Mancozeb (2.5 g/l) immediately. Scout for water-soaked leaf lesions and remove infected foliage.',
  },
  {
    zone: 'Zone 2',
    problem: 'Low Moisture Stress in Zone 2',
    assessment: 'AI Assessment: Issue detected: Critical Soil Moisture Deficit',
    action: 'Action Plan: Check irrigation flow immediately. Target soil moisture above 35%. High stress during tuber bulking causes yield loss.',
  },
  {
    zone: 'Zone 3',
    problem: 'Nutrient Deficiency in Zone 3',
    assessment: 'AI Assessment: Issue detected: Potassium / Nitrogen Deficiency',
    action: 'Action Plan: Apply balanced NPK fertilizer. Monitor nutrient uptake over the next 2 weeks via canopy color index.',
  },
  {
    zone: 'Zone 4',
    problem: 'Early Blight Risk in Zone 4',
    assessment: 'AI Assessment: Issue detected: Early Blight (Alternaria solani)',
    action: 'Action Plan: Apply Chlorothalonil @ 2 g/l spray at 10-day intervals. Avoid plant water stress. Maintain adequate potassium fertility.',
  },
];

export const ReportsView: React.FC<ReportsViewProps> = ({ reports }) => {
  const [selectedReportId, setSelectedReportId] = useState<string>(reports[0]?.id || 'REP-904');
  const selectedReport = reports.find(r => r.id === selectedReportId) || reports[0];
  const targetField: FieldAsset = MOCK_FIELDS.find(f => f.name === selectedReport?.fieldName || f.id === selectedReport?.fieldName) || MOCK_FIELDS[0];

  return (
    <div style={{ padding: '20px 24px', display: 'flex', flexDirection: 'column', gap: '20px' }}>
      {/* Page Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 style={{ fontSize: '20px', fontWeight: 700, color: '#1C201A', margin: 0 }}>
            AgriSwarm Crop Intelligence Audits
          </h1>
          <p style={{ fontSize: '12px', color: '#5F645D', marginTop: '2px' }}>
            Validated field audit reports — sensor telemetry, zone risk analysis, drone imagery & expert recommendations.
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
          <Download size={14} /> Export PDF
        </button>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '280px 1fr', gap: '20px', alignItems: 'start' }}>
        {/* ── Left: Report List ─────────────────────────────────────────── */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
          <div style={{ fontSize: '10px', fontWeight: 700, color: '#5F645D', textTransform: 'uppercase', paddingLeft: '2px' }}>
            Field Audit Records ({reports.length})
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
                  padding: '12px',
                  cursor: 'pointer',
                  boxShadow: isSelected ? '0 2px 6px rgba(31,104,36,0.12)' : 'none',
                  transition: 'all 0.15s ease',
                }}
              >
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '3px' }}>
                  <span style={{ fontFamily: 'monospace', fontSize: '11px', fontWeight: 700, color: '#1C201A' }}>{rep.id}</span>
                  <span style={{
                    fontSize: '10px', fontWeight: 700, padding: '1px 6px', borderRadius: '3px',
                    backgroundColor: rep.status === 'Ready' ? '#E7EFE5' : '#FEF5E4',
                    color: rep.status === 'Ready' ? '#2A3B27' : '#B07E28',
                  }}>{rep.status}</span>
                </div>
                <div style={{ fontSize: '13px', fontWeight: 700, color: '#1C201A' }}>{rep.fieldName}</div>
                <div style={{ fontSize: '11px', color: '#5F645D', marginTop: '2px' }}>Farmer: {rep.farmerName}</div>
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '10px', color: '#5F645D', marginTop: '8px', paddingTop: '6px', borderTop: '1px solid #E8E9E3' }}>
                  <span>Score: <strong style={{ color: rep.healthIndexScore >= 80 ? '#2E7D32' : '#D32F2F' }}>{rep.healthIndexScore}/100</strong></span>
                  <span>{rep.generatedDate}</span>
                </div>
              </div>
            );
          })}
        </div>

        {/* ── Right: Full Report Document ───────────────────────────────── */}
        {selectedReport && (
          <div style={{
            backgroundColor: '#FFFFFF',
            border: '1px solid #D8D9D2',
            borderRadius: '6px',
            padding: '28px 32px',
            boxShadow: '0 2px 12px rgba(0,0,0,0.06)',
            display: 'flex',
            flexDirection: 'column',
            gap: '18px',
            fontFamily: 'Arial, sans-serif',
          }}>

            {/* ── REPORT HEADER ──────────────────────────────────────────── */}
            <div>
              <div style={{ fontSize: '20px', fontWeight: 900, color: '#1F6824', letterSpacing: '0.5px' }}>
                AGRISWARM CROP INTELLIGENCE REPORT
              </div>
              <div style={{ fontSize: '11px', color: '#5F645D', marginTop: '3px' }}>
                Report Date: {selectedReport.generatedDate} &nbsp;|&nbsp; Field: {selectedReport.fieldName}
              </div>
              <hr style={{ border: 0, borderTop: '1.5px solid #1F6824', marginTop: '8px' }} />
            </div>

            {/* ── FIELD SPECIFICATIONS ──────────────────────────────────── */}
            <div>
              <SectionHeader title="Field Specifications" />
              <table style={{ width: '100%', borderCollapse: 'collapse', border: '1px solid #D8D9D2', marginBottom: '12px' }}>
                <tbody>
                  <tr>
                    <td style={{ ...TD, fontWeight: 600, width: '20%' }}>Crop Cultivar:</td>
                    <td style={{ ...TD, width: '30%' }}>Potato (Kufri Jyoti)</td>
                    <td style={{ ...TD, fontWeight: 600, width: '20%' }}>Field Area:</td>
                    <td style={{ ...TD }}>{(targetField.areaHa * 2.471).toFixed(1)} acres</td>
                  </tr>
                  <tr>
                    <td style={{ ...TD, fontWeight: 600 }}>Sowing Date:</td>
                    <td style={TD}>{targetField.sowingDate || '2026-06-15'}</td>
                    <td style={{ ...TD, fontWeight: 600 }}>Growth Stage:</td>
                    <td style={TD}>{targetField.cropStage || 'Tuber bulking stage'}</td>
                  </tr>
                </tbody>
              </table>

              {/* Dual KPI Cards */}
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                {/* Health Score Card */}
                <div style={{ border: '1px solid #B8D4B8', borderRadius: '4px', padding: '12px 16px', backgroundColor: '#F8FBF7' }}>
                  <div style={{ fontSize: '10px', fontWeight: 700, color: '#2E7D32', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
                    CROP HEALTH SCORE
                  </div>
                  <div style={{ fontSize: '26px', fontWeight: 900, color: '#1C201A', marginTop: '4px', lineHeight: 1 }}>
                    {selectedReport.healthIndexScore} / 100
                  </div>
                  <ProgressBar value={selectedReport.healthIndexScore} color="#4CAF50" />
                </div>

                {/* Soil Moisture Card */}
                <div style={{ border: '1px solid #B3D4F0', borderRadius: '4px', padding: '12px 16px', backgroundColor: '#F5FAFF' }}>
                  <div style={{ fontSize: '10px', fontWeight: 700, color: '#1565C0', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
                    SOIL MOISTURE STATUS
                  </div>
                  <div style={{ fontSize: '26px', fontWeight: 900, color: '#1565C0', marginTop: '4px', lineHeight: 1 }}>
                    27.0% (LOW)
                  </div>
                  <ProgressBar value={27} color="#2196F3" />
                </div>
              </div>
            </div>

            {/* ── AUDIT FINDINGS ALERT BANNER ──────────────────────────── */}
            <div style={{
              border: '1px solid #FFCDD2',
              backgroundColor: '#FFF8F8',
              borderRadius: '3px',
              padding: '8px 14px',
              fontSize: '12px',
              color: '#C62828',
              fontWeight: 600,
            }}>
              Audit Findings: Late Blight Risk, Low Moisture Stress, Nutrient Deficiency, Early Blight Risk
            </div>

            {/* ── ZONE CONDITION ANALYSIS ──────────────────────────────── */}
            <div>
              <SectionHeader title="Zone Condition Analysis" />
              <table style={{ width: '100%', borderCollapse: 'collapse', border: '1px solid #D8D9D2' }}>
                <thead>
                  <tr>
                    {['Zone', 'Status', 'Moisture', 'Temperature', 'Risk'].map(h => (
                      <th key={h} style={TH}>{h}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {ZONE_DATA.map((row, i) => (
                    <tr key={i} style={{ backgroundColor: i % 2 === 0 ? '#FFFFFF' : '#FAFBF8' }}>
                      <td style={TD}>{row.zone}</td>
                      <td style={{ ...TD, color: row.statusColor, fontWeight: 600 }}>{row.status}</td>
                      <td style={TD}>{row.moisture}</td>
                      <td style={TD}>{row.temp}</td>
                      <td style={{ ...TD, color: row.risk === 'High' ? '#D32F2F' : '#B07E28', fontWeight: 600 }}>{row.risk}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {/* ── SENSOR TELEMETRY READINGS ────────────────────────────── */}
            <div>
              <SectionHeader title="Sensor Telemetry Readings" />
              <table style={{ width: '100%', borderCollapse: 'collapse', border: '1px solid #D8D9D2' }}>
                <thead>
                  <tr>
                    {['Sensor', 'Value', 'Normal Range', 'Status'].map(h => (
                      <th key={h} style={TH}>{h}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {SENSOR_DATA.map((row, i) => (
                    <tr key={i} style={{ backgroundColor: i % 2 === 0 ? '#FFFFFF' : '#FAFBF8' }}>
                      <td style={{ ...TD, fontWeight: 600 }}>{row.name}</td>
                      <td style={TD}>{row.value}</td>
                      <td style={TD}>{row.range}</td>
                      <td style={{ ...TD, color: row.statusColor, fontWeight: 700 }}>{row.status}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {/* ── DRONE IMAGERY SURVEY LOGS ────────────────────────────── */}
            <div>
              <SectionHeader title="Drone Imagery Survey Logs" />
              <table style={{ width: '100%', borderCollapse: 'collapse', border: '1px solid #D8D9D2' }}>
                <thead>
                  <tr>
                    {['Aerial Image Scan Label', 'Covered Zone', 'Vegetation Assessment'].map(h => (
                      <th key={h} style={TH}>{h}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {DRONE_IMAGERY.map((row, i) => (
                    <tr key={i} style={{ backgroundColor: i % 2 === 0 ? '#FFFFFF' : '#FAFBF8' }}>
                      <td style={TD}>{row.label}</td>
                      <td style={TD}>{row.zone}</td>
                      <td style={{ ...TD, color: '#D32F2F', fontStyle: 'italic' }}>{row.assessment}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {/* ── TELEMETRY INDEX TREND LINES ──────────────────────────── */}
            <div>
              <SectionHeader title="Telemetry Index Trend Lines" />
              <table style={{ width: '100%', borderCollapse: 'collapse', border: '1px solid #D8D9D2' }}>
                <thead>
                  <tr>
                    {['Telemetry Metric', 'Scan 1', 'Scan 2', 'Scan 3', 'Current Value'].map(h => (
                      <th key={h} style={TH}>{h}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {TELEMETRY_TREND.map((row, i) => (
                    <tr key={i} style={{ backgroundColor: i % 2 === 0 ? '#FFFFFF' : '#FAFBF8' }}>
                      <td style={{ ...TD, fontWeight: 600 }}>{row.metric}</td>
                      <td style={TD}>{row.s1}</td>
                      <td style={TD}>{row.s2}</td>
                      <td style={TD}>{row.s3}</td>
                      <td style={{ ...TD, fontWeight: 700, color: '#1F6824' }}>{row.current}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {/* ── HISTORICAL ANALYTICS TREND PROGRESS (VISUAL CHARTS) ── */}
            <div>
              <SectionHeader title="Historical Analytics Trend Progress (Visual Charts)" />
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
                {/* Crop Health Index Chart */}
                <div style={{ border: '1px solid #D8D9D2', borderRadius: '4px', padding: '12px' }}>
                  <div style={{ fontSize: '11px', fontWeight: 700, color: '#1C201A', marginBottom: '8px' }}>
                    Crop Health Index History
                  </div>
                  <MiniBarChart
                    data={[
                      { label: 'Scan 1', value: 58 },
                      { label: 'Scan 2', value: 65 },
                      { label: 'Scan 3', value: 72 },
                      { label: 'Current', value: 78 },
                    ]}
                    color="#4CAF50"
                  />
                </div>

                {/* Soil Moisture Chart */}
                <div style={{ border: '1px solid #D8D9D2', borderRadius: '4px', padding: '12px' }}>
                  <div style={{ fontSize: '11px', fontWeight: 700, color: '#1C201A', marginBottom: '8px' }}>
                    Soil Moisture (%) History
                  </div>
                  <MiniBarChart
                    data={[
                      { label: 'Scan 1', value: 22 },
                      { label: 'Scan 2', value: 25 },
                      { label: 'Scan 3', value: 27 },
                      { label: 'Current', value: 27 },
                    ]}
                    color="#2196F3"
                  />
                </div>
              </div>
            </div>

            {/* ── EXPERT RECOMMENDATION & CROP SOLUTIONS ───────────────── */}
            <div>
              <SectionHeader title="Expert Recommendation & Crop Solutions" />
              <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                {RECOMMENDATIONS.map((rec, i) => (
                  <div key={i} style={{
                    border: '1px solid #E8E9E3',
                    borderRadius: '3px',
                    padding: '10px 14px',
                    backgroundColor: '#FAFBF8',
                    borderLeft: '3px solid #D32F2F',
                  }}>
                    <div style={{ fontSize: '12px', fontWeight: 700, color: '#C62828', marginBottom: '3px' }}>
                      Problem: {rec.problem}
                    </div>
                    <div style={{ fontSize: '11px', color: '#5F645D', marginBottom: '2px' }}>
                      {rec.assessment}
                    </div>
                    <div style={{ fontSize: '11px', color: '#2D3129', fontStyle: 'italic' }}>
                      {rec.action}
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* ── FOOTER ──────────────────────────────────────────────── */}
            <div style={{
              marginTop: '8px',
              paddingTop: '10px',
              borderTop: '1px solid #D8D9D2',
              textAlign: 'right',
              fontSize: '11px',
              color: '#5F645D',
              fontStyle: 'italic',
            }}>
              Authorised Agritech Lead Signature: Dr. S. K. Sharma
            </div>

          </div>
        )}
      </div>
    </div>
  );
};
