import React, { useState } from 'react';
import type { AssessmentReport } from '../../types';
import { Download, Send } from 'lucide-react';
import { reportlabPdfService } from '../../lib/reportlabPdfService';
import { MOCK_FIELDS, MOCK_FINDINGS } from '../../data/mockData';

interface ReportsViewProps {
  reports: AssessmentReport[];
}

export const ReportsView: React.FC<ReportsViewProps> = ({
  reports
}) => {
  const [selectedReportId, setSelectedReportId] = useState<string | null>('REP-904');
  const [sentStatusMessage, setSentStatusMessage] = useState<string | null>(null);

  const selectedReport = reports.find(r => r.id === selectedReportId) || reports[0];

  return (
    <div style={{ padding: '20px 24px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
      {/* Title */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 style={{ fontSize: '22px', fontWeight: 700, color: '#20231F', margin: 0 }}>
            Field Intelligence Reports
          </h1>
          <p style={{ fontSize: '13px', color: '#6B7068', marginTop: '2px' }}>
            Validated multi-spectral field diagnostic assessments generated for farmers.
          </p>
        </div>
      </div>

      {/* Reports Table & Preview Split */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 520px', gap: '20px' }}>
        {/* Reports Data Table */}
        <div className="op-table-container">
          <table className="op-table">
            <thead>
              <tr>
                <th>Report ID</th>
                <th>Farmer Name</th>
                <th>Target Field</th>
                <th>Operation ID</th>
                <th>Generated Date</th>
                <th>Health Score</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {reports.map(rep => {
                const isSelected = rep.id === selectedReportId;
                return (
                  <tr 
                    key={rep.id} 
                    className={isSelected ? 'selected' : ''}
                    onClick={() => setSelectedReportId(rep.id)}
                    style={{ cursor: 'pointer' }}
                  >
                    <td style={{ fontWeight: 600, fontFamily: 'monospace' }}>{rep.id}</td>
                    <td>{rep.farmerName}</td>
                    <td><strong style={{ color: '#4F6848' }}>{rep.fieldName}</strong></td>
                    <td style={{ fontFamily: 'monospace' }}>{rep.operationId}</td>
                    <td style={{ color: '#6B7068', fontSize: '12px' }}>{rep.generatedDate}</td>
                    <td>
                      <strong style={{ color: rep.healthIndexScore < 80 ? '#B8862D' : '#4F6848' }}>
                        {rep.healthIndexScore}%
                      </strong>
                    </td>
                    <td>
                      <span className={`badge badge-${rep.status === 'Ready' ? 'success' : 'pending'}`}>
                        {rep.status}
                      </span>
                    </td>
                    <td>
                      <button 
                        className="op-btn op-btn-secondary op-btn-sm"
                        onClick={(e) => {
                          e.stopPropagation();
                          setSelectedReportId(rep.id);
                        }}
                      >
                        Preview Document
                      </button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>

        {/* Serious PDF-Style Report Preview Document */}
        {selectedReport && (
          <div 
            style={{
              backgroundColor: '#FFFFFF',
              border: '1px solid #DDDED7',
              borderRadius: '4px',
              padding: '24px',
              boxShadow: '0 4px 12px rgba(0,0,0,0.06)',
              display: 'flex',
              flexDirection: 'column',
              justifyContent: 'space-between',
              fontFamily: 'serif'
            }}
          >
            <div>
              {/* Serious Document Header */}
              <div 
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'flex-start',
                  borderBottom: '2px solid #30432E',
                  paddingBottom: '14px',
                  marginBottom: '16px',
                  fontFamily: 'sans-serif'
                }}
              >
                <div>
                  <div style={{ fontSize: '12px', fontWeight: 700, color: '#4F6848', letterSpacing: '1px' }}>
                    AGRI SWARM OPERATOR PLATFORM
                  </div>
                  <h2 style={{ fontSize: '20px', fontWeight: 800, color: '#20231F', margin: '2px 0 0 0' }}>
                    FIELD INTELLIGENCE REPORT
                  </h2>
                </div>
                <div style={{ textAlign: 'right', fontSize: '11px', color: '#6B7068', fontFamily: 'monospace' }}>
                  <div>DOC ID: {selectedReport.id}</div>
                  <div>DATE: {selectedReport.generatedDate}</div>
                </div>
              </div>

              {/* Document Meta Grid */}
              <div 
                style={{
                  display: 'grid',
                  gridTemplateColumns: '1fr 1fr',
                  gap: '12px',
                  backgroundColor: '#FAFBF8',
                  padding: '12px',
                  borderRadius: '3px',
                  border: '1px solid #DDDED7',
                  marginBottom: '16px',
                  fontSize: '12px',
                  fontFamily: 'sans-serif'
                }}
              >
                <div>
                  <span style={{ color: '#6B7068' }}>Farmer Name: </span>
                  <strong>{selectedReport.farmerName}</strong>
                </div>
                <div>
                  <span style={{ color: '#6B7068' }}>Field Asset: </span>
                  <strong>{selectedReport.fieldName} (4.8 ha Wheat)</strong>
                </div>
                <div>
                  <span style={{ color: '#6B7068' }}>Location: </span>
                  <strong>Thane, Maharashtra</strong>
                </div>
                <div>
                  <span style={{ color: '#6B7068' }}>Operation ID: </span>
                  <strong style={{ fontFamily: 'monospace' }}>{selectedReport.operationId}</strong>
                </div>
              </div>

              {/* Health Score Summary */}
              <div style={{ marginBottom: '16px', fontFamily: 'sans-serif' }}>
                <h3 style={{ fontSize: '14px', fontWeight: 700, color: '#20231F', marginBottom: '6px' }}>
                  1. Executive Field Vigor Summary
                </h3>
                <p style={{ fontSize: '13px', color: '#20231F', lineHeight: 1.5 }}>
                  Multispectral aerial imaging conducted over {selectedReport.fieldName} indicates an overall canopy vigor index of <strong>{selectedReport.healthIndexScore}%</strong>. High canopy reflectance uniformity is maintained across 33 of 36 grid zones.
                </p>
              </div>

              {/* Verified AI Findings Section */}
              <div style={{ marginBottom: '16px', fontFamily: 'sans-serif' }}>
                <h3 style={{ fontSize: '14px', fontWeight: 700, color: '#20231F', marginBottom: '6px' }}>
                  2. Validated Crop Anomalies & Detection Delineation
                </h3>
                <div className="op-table-container">
                  <table className="op-table" style={{ fontSize: '12px' }}>
                    <thead>
                      <tr>
                        <th>Zone</th>
                        <th>Finding Type</th>
                        <th>Confidence</th>
                        <th>Soil Moisture</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr>
                        <td style={{ fontWeight: 600, fontFamily: 'monospace' }}>Zone 27</td>
                        <td style={{ color: '#B64A43', fontWeight: 600 }}>Visible crop stress / yellowing</td>
                        <td>91%</td>
                        <td>23% (Low)</td>
                      </tr>
                      <tr>
                        <td style={{ fontWeight: 600, fontFamily: 'monospace' }}>Zone 14</td>
                        <td style={{ color: '#B8862D' }}>Mild canopy density variance</td>
                        <td>78%</td>
                        <td>31%</td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>

              {/* Priority Actionable Recommendations */}
              <div style={{ marginBottom: '16px', fontFamily: 'sans-serif' }}>
                <h3 style={{ fontSize: '14px', fontWeight: 700, color: '#20231F', marginBottom: '6px' }}>
                  3. Actionable Operational Directives
                </h3>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                  {selectedReport.priorityRecommendations.map((rec, i) => (
                    <div key={i} style={{ display: 'flex', gap: '8px', fontSize: '12px', color: '#20231F', lineHeight: 1.4 }}>
                      <span style={{ fontWeight: 700, color: '#4F6848' }}>•</span>
                      <span>{rec}</span>
                    </div>
                  ))}
                </div>
              </div>

              {/* Scientific Notice */}
              <div style={{ fontSize: '11px', color: '#6B7068', fontStyle: 'italic', borderTop: '1px solid #DDDED7', paddingTop: '8px', fontFamily: 'sans-serif' }}>
                Report compiled by Human Operator Vikram Sharma following radiometric calibration and ground truth verification.
              </div>
            </div>

            {/* Document Actions Bar */}
            <div style={{ borderTop: '1px solid #EBECE6', paddingTop: '14px', marginTop: '16px', display: 'flex', gap: '8px', fontFamily: 'sans-serif' }}>
              <button 
                className="op-btn op-btn-secondary"
                style={{ flex: 1 }}
                onClick={async () => {
                  const targetField = MOCK_FIELDS.find(f => f.name === selectedReport.fieldName || f.id === selectedReport.fieldName) || MOCK_FIELDS[0];
                  await reportlabPdfService.exportReportLabPdf(
                    selectedReport, 
                    targetField, 
                    MOCK_FINDINGS.filter(f => f.operationId === selectedReport.operationId || f.fieldId === targetField.id)
                  );
                }}
              >
                <Download size={14} /> Export ReportLab PDF
              </button>
              <button 
                className="op-btn op-btn-primary"
                style={{ flex: 1 }}
                onClick={() => {
                  setSentStatusMessage(`Report ${selectedReport.id} dispatched to farmer ${selectedReport.farmerName} via SMS / Whatsapp link.`);
                  setTimeout(() => setSentStatusMessage(null), 4000);
                }}
              >
                <Send size={14} /> Send to Farmer {selectedReport.farmerName}
              </button>
            </div>

            {sentStatusMessage && (
              <div style={{ marginTop: '10px', padding: '8px', backgroundColor: '#EBF0E9', color: '#30432E', fontSize: '12px', borderRadius: '3px', fontFamily: 'sans-serif' }}>
                {sentStatusMessage}
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
};
