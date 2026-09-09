import React, { useState } from 'react';
import type { CropFinding } from '../../types';
import { Check, X, ShieldAlert, Sliders, Activity, Eye, FileCheck2 } from 'lucide-react';

interface ValidationViewProps {
  findings: CropFinding[];
  onConfirmFinding: (findingId: string) => void;
  onRejectFinding: (findingId: string) => void;
  onNavigateToReport: () => void;
}

export const ValidationView: React.FC<ValidationViewProps> = ({
  findings,
  onConfirmFinding,
  onRejectFinding,
  onNavigateToReport
}) => {
  const [selectedFindingId, setSelectedFindingId] = useState<string>('FND-027');
  const [activeImageTab, setActiveImageTab] = useState<'ndvi' | 'rgb' | 'dual'>('dual');
  const [decisionFeedback, setDecisionFeedback] = useState<string | null>(null);

  const selectedFinding = findings.find(f => f.id === selectedFindingId) || findings[0];

  const handleAction = (action: 'confirm' | 'reject') => {
    if (action === 'confirm') {
      onConfirmFinding(selectedFinding.id);
      setDecisionFeedback(`Finding ${selectedFinding.id} CONFIRMED by Human Operator. Added to Field Intelligence Report REP-904.`);
    } else {
      onRejectFinding(selectedFinding.id);
      setDecisionFeedback(`Finding ${selectedFinding.id} REJECTED by Operator. Logged as spectral false positive anomaly.`);
    }
  };

  return (
    <div style={{ padding: '20px 24px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
      {/* Header with Clear Purpose */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 style={{ fontSize: '22px', fontWeight: 700, color: '#1C201A', margin: 0 }}>
            AI Anomaly Human Validation Engine
          </h1>
          <p style={{ fontSize: '13px', color: '#5F645D', marginTop: '2px' }}>
            Human-in-the-loop audit workspace to inspect spectral signatures and validate AI crop-stress detections before report compilation.
          </p>
        </div>
        <button
          className="op-btn op-btn-primary"
          onClick={onNavigateToReport}
        >
          <FileCheck2 size={15} /> View Compiled Intelligence Reports
        </button>
      </div>

      {/* Clear 3-Step Workflow Guidance Bar */}
      <div
        style={{
          backgroundColor: '#FFFFFF',
          border: '1px solid #D8D9D2',
          borderRadius: '6px',
          padding: '12px 18px',
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          boxShadow: '0 1px 3px rgba(0,0,0,0.04)'
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <span style={{ width: '22px', height: '22px', borderRadius: '50%', backgroundColor: '#30432E', color: '#FFFFFF', fontSize: '11px', fontWeight: 700, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>1</span>
            <span style={{ fontSize: '12px', fontWeight: 600, color: '#1C201A' }}>AI Detection Flagged</span>
          </div>
          <span style={{ color: '#8A9087' }}>→</span>

          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <span style={{ width: '22px', height: '22px', borderRadius: '50%', backgroundColor: '#435C3C', color: '#FFFFFF', fontSize: '11px', fontWeight: 700, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>2</span>
            <span style={{ fontSize: '12px', fontWeight: 600, color: '#435C3C' }}>Spectral Imagery Audit</span>
          </div>
          <span style={{ color: '#8A9087' }}>→</span>

          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <span style={{ width: '22px', height: '22px', borderRadius: '50%', backgroundColor: '#D8D9D2', color: '#5F645D', fontSize: '11px', fontWeight: 700, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>3</span>
            <span style={{ fontSize: '12px', fontWeight: 500, color: '#5F645D' }}>Operator Sign-Off</span>
          </div>
        </div>

        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '6px',
            fontSize: '11px',
            color: '#AF413A',
            backgroundColor: '#FAF0EC',
            padding: '4px 10px',
            borderRadius: '4px',
            border: '1px solid rgba(175, 65, 58, 0.3)'
          }}
        >
          <ShieldAlert size={14} />
          <span>Protocol: Human verification required prior to issuing farmer directives</span>
        </div>
      </div>

      {/* Main Validation 3-Column Workspace */}
      <div style={{ display: 'grid', gridTemplateColumns: '280px minmax(0, 1fr) 360px', gap: '16px', width: '100%' }}>
        {/* Left Column: Validation Queue List */}
        <div className="op-table-container" style={{ padding: '14px', display: 'flex', flexDirection: 'column', gap: '10px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid #E8E9E3', paddingBottom: '8px' }}>
            <span style={{ fontSize: '11px', fontWeight: 700, color: '#5F645D', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
              Validation Queue ({findings.length})
            </span>
            <span style={{ fontSize: '10px', color: '#AF413A', fontWeight: 600 }}>
              {findings.filter(f => f.status === 'Pending Validation').length} Pending
            </span>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', overflowY: 'auto' }}>
            {findings.map(f => {
              const isSelected = f.id === selectedFindingId;
              return (
                <div
                  key={f.id}
                  onClick={() => {
                    setSelectedFindingId(f.id);
                    setDecisionFeedback(null);
                  }}
                  style={{
                    padding: '12px',
                    borderRadius: '4px',
                    backgroundColor: isSelected ? '#E7EFE5' : '#FAFBF7',
                    border: `1px solid ${isSelected ? '#435C3C' : '#D8D9D2'}`,
                    cursor: 'pointer',
                    transition: 'all 0.15s ease'
                  }}
                >
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <span style={{ fontSize: '12px', fontWeight: 700, fontFamily: 'monospace', color: '#1C201A' }}>{f.id}</span>
                    <span className={`badge badge-${f.status === 'Pending Validation' ? 'validation' : 'success'}`}>
                      {f.status}
                    </span>
                  </div>
                  <div style={{ fontSize: '12px', fontWeight: 600, color: '#1C201A', marginTop: '4px' }}>
                    {f.fieldName} · {f.zoneId}
                  </div>
                  <div style={{ fontSize: '11px', color: '#5F645D', marginTop: '2px', display: 'flex', justifyContent: 'space-between' }}>
                    <span>{f.findingType}</span>
                    <strong style={{ color: f.confidencePercent > 85 ? '#AF413A' : '#B07E28' }}>{f.confidencePercent}%</strong>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Middle Column: Prominent Dual Spectral Viewer (NDVI vs RGB) */}
        <div
          style={{
            backgroundColor: '#FFFFFF',
            border: '1px solid #D8D9D2',
            borderRadius: '6px',
            padding: '16px',
            display: 'flex',
            flexDirection: 'column',
            gap: '12px',
            boxShadow: '0 1px 3px rgba(0,0,0,0.06)'
          }}
        >
          {/* Viewer Toolbar */}
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid #E8E9E3', paddingBottom: '10px' }}>
            <div>
              <div style={{ fontSize: '13px', fontWeight: 700, color: '#1C201A' }}>
                CANOPY SPECTRAL AUDIT: {selectedFinding.zoneId} ({selectedFinding.fieldName})
              </div>
              <div style={{ fontSize: '11px', color: '#5F645D' }}>
                MicaSense RedEdge-P 5-Band Sensor · 3.2 cm/pixel · Sun-angle calibrated
              </div>
            </div>

            <div style={{ display: 'flex', gap: '4px', backgroundColor: '#F5F6F2', padding: '3px', borderRadius: '4px', border: '1px solid #D8D9D2' }}>
              <button
                onClick={() => setActiveImageTab('dual')}
                style={{ padding: '3px 8px', fontSize: '11px', fontWeight: 600, borderRadius: '3px', backgroundColor: activeImageTab === 'dual' ? '#30432E' : 'transparent', color: activeImageTab === 'dual' ? '#FFFFFF' : '#5F645D' }}
              >
                <Sliders size={12} style={{ display: 'inline', marginRight: 4 }} /> Dual View
              </button>
              <button
                onClick={() => setActiveImageTab('ndvi')}
                style={{ padding: '3px 8px', fontSize: '11px', fontWeight: 600, borderRadius: '3px', backgroundColor: activeImageTab === 'ndvi' ? '#30432E' : 'transparent', color: activeImageTab === 'ndvi' ? '#FFFFFF' : '#5F645D' }}
              >
                NDVI Spectrum
              </button>
              <button
                onClick={() => setActiveImageTab('rgb')}
                style={{ padding: '3px 8px', fontSize: '11px', fontWeight: 600, borderRadius: '3px', backgroundColor: activeImageTab === 'rgb' ? '#30432E' : 'transparent', color: activeImageTab === 'rgb' ? '#FFFFFF' : '#5F645D' }}
              >
                <Eye size={12} style={{ display: 'inline', marginRight: 4 }} /> TrueColor RGB
              </button>
            </div>
          </div>

          {/* Image Canvas View Container */}
          <div
            style={{
              display: 'grid',
              gridTemplateColumns: activeImageTab === 'dual' ? '1fr 1fr' : '1fr',
              gap: '12px',
              height: '340px'
            }}
          >
            {/* NDVI Multispectral Heatmap View */}
            {(activeImageTab === 'dual' || activeImageTab === 'ndvi') && (
              <div
                style={{
                  position: 'relative',
                  backgroundColor: '#0F150F',
                  borderRadius: '6px',
                  border: '1px solid #30432E',
                  overflow: 'hidden'
                }}
              >
                <img
                  src="/assets/potato_ndvi.png"
                  alt="NDVI Thermal Drone Scan"
                  style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                />
                
                {/* HUD Overlay Label */}
                <div style={{ position: 'absolute', top: 10, left: 10, backgroundColor: 'rgba(15,20,15,0.85)', backdropFilter: 'blur(4px)', color: '#A8D5A2', padding: '4px 10px', borderRadius: '4px', border: '1px solid rgba(255,255,255,0.15)', fontSize: '10px', fontWeight: 700, letterSpacing: '0.5px' }}>
                  🌿 NDVI MULTISPECTRAL HEATMAP
                </div>

                {/* GSD Badge */}
                <div style={{ position: 'absolute', top: 10, right: 10, backgroundColor: 'rgba(15,20,15,0.85)', backdropFilter: 'blur(4px)', color: '#E0E1D8', padding: '4px 8px', borderRadius: '4px', fontSize: '10px', fontFamily: 'monospace' }}>
                  GSD: 0.8 cm/px
                </div>

                {/* AI Detection Bounding Box HUD */}
                <div
                  style={{
                    position: 'absolute',
                    top: '25%',
                    left: '25%',
                    width: '50%',
                    height: '50%',
                    border: '2px dashed #EF5350',
                    backgroundColor: 'rgba(239, 83, 80, 0.15)',
                    boxShadow: '0 0 12px rgba(239,83,80,0.4)',
                    pointerEvents: 'none'
                  }}
                >
                  <div
                    style={{
                      position: 'absolute',
                      top: -24,
                      left: -2,
                      backgroundColor: '#EF5350',
                      color: '#FFFFFF',
                      fontSize: '10px',
                      fontWeight: 700,
                      fontFamily: 'monospace',
                      padding: '2px 6px',
                      borderRadius: '2px',
                      whiteSpace: 'nowrap'
                    }}
                  >
                    NDVI ANOMALY: 0.32 (CRITICAL CANOPY STRESS)
                  </div>
                </div>
              </div>
            )}

            {/* TrueColor RGB View */}
            {(activeImageTab === 'dual' || activeImageTab === 'rgb') && (
              <div
                style={{
                  position: 'relative',
                  backgroundColor: '#0F150F',
                  borderRadius: '6px',
                  border: '1px solid #30432E',
                  overflow: 'hidden'
                }}
              >
                <img
                  src="/assets/potato_rgb.png"
                  alt="High-Res TrueColor RGB Aerial Photo"
                  style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                />

                {/* HUD Overlay Label */}
                <div style={{ position: 'absolute', top: 10, left: 10, backgroundColor: 'rgba(15,20,15,0.85)', backdropFilter: 'blur(4px)', color: '#FFFFFF', padding: '4px 10px', borderRadius: '4px', border: '1px solid rgba(255,255,255,0.15)', fontSize: '10px', fontWeight: 700, letterSpacing: '0.5px' }}>
                  📷 HIGH-RES TRUECOLOR RGB
                </div>

                {/* Altitude Badge */}
                <div style={{ position: 'absolute', top: 10, right: 10, backgroundColor: 'rgba(15,20,15,0.85)', backdropFilter: 'blur(4px)', color: '#E0E1D8', padding: '4px 8px', borderRadius: '4px', fontSize: '10px', fontFamily: 'monospace' }}>
                  ALT: 15 m
                </div>

                {/* AI Leaf Lesion Bounding Box HUD */}
                <div
                  style={{
                    position: 'absolute',
                    top: '20%',
                    left: '20%',
                    width: '60%',
                    height: '60%',
                    border: '2px solid #FFD54F',
                    backgroundColor: 'rgba(255, 213, 79, 0.1)',
                    boxShadow: '0 0 10px rgba(255,213,79,0.3)',
                    pointerEvents: 'none'
                  }}
                >
                  <div
                    style={{
                      position: 'absolute',
                      top: -24,
                      left: -2,
                      backgroundColor: '#FFD54F',
                      color: '#1C201A',
                      fontSize: '10px',
                      fontWeight: 700,
                      fontFamily: 'monospace',
                      padding: '2px 6px',
                      borderRadius: '2px',
                      whiteSpace: 'nowrap'
                    }}
                  >
                    POTATO LEAF LESION DETECTED (91% CONFIDENCE)
                  </div>
                </div>
              </div>
            )}
          </div>

          {/* Spectral Reflectance Curve Readout */}
          <div style={{ backgroundColor: '#F5F6F2', border: '1px solid #D8D9D2', borderRadius: '4px', padding: '10px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', fontSize: '11px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <Activity size={14} color="#435C3C" />
              <span style={{ fontWeight: 600, color: '#1C201A' }}>Spectral Reflectance Index:</span>
            </div>
            <div style={{ display: 'flex', gap: '14px', fontFamily: 'monospace' }}>
              <span>Red (668nm): <strong>0.18</strong></span>
              <span>Red-Edge (705nm): <strong style={{ color: '#B07E28' }}>0.34</strong></span>
              <span>NIR (842nm): <strong style={{ color: '#AF413A' }}>0.48 (Low)</strong></span>
            </div>
          </div>
        </div>

        {/* Right Column: Finding Metadata & Decision Control Panel */}
        <div
          style={{
            backgroundColor: '#FFFFFF',
            border: '1px solid #D8D9D2',
            borderRadius: '6px',
            padding: '16px',
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'space-between',
            boxShadow: '0 1px 3px rgba(0,0,0,0.06)'
          }}
        >
          <div>
            <div style={{ borderBottom: '1px solid #E8E9E3', paddingBottom: '10px', marginBottom: '12px' }}>
              <div style={{ fontSize: '11px', color: '#5F645D', textTransform: 'uppercase', fontWeight: 600 }}>
                AUDIT DIAGNOSTIC METRICS
              </div>
              <h2 style={{ fontSize: '18px', fontWeight: 700, color: '#1C201A', margin: 0, fontFamily: 'monospace' }}>
                {selectedFinding.id}
              </h2>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '10px', fontSize: '13px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <span style={{ color: '#5F645D' }}>Finding Anomaly</span>
                <span style={{ fontWeight: 600, color: '#AF413A' }}>{selectedFinding.findingType}</span>
              </div>

              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span style={{ color: '#5F645D' }}>Model Confidence</span>
                <span
                  style={{
                    fontWeight: 700,
                    color: '#FFFFFF',
                    backgroundColor: selectedFinding.confidencePercent > 85 ? '#AF413A' : '#B07E28',
                    padding: '2px 8px',
                    borderRadius: '10px',
                    fontSize: '12px'
                  }}
                >
                  {selectedFinding.confidencePercent}%
                </span>
              </div>

              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <span style={{ color: '#5F645D' }}>Target Field</span>
                <span>{selectedFinding.fieldName} ({selectedFinding.zoneId})</span>
              </div>

              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <span style={{ color: '#5F645D' }}>Farmer</span>
                <span style={{ fontWeight: 600 }}>{selectedFinding.farmerName}</span>
              </div>

              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <span style={{ color: '#5F645D' }}>GPS Centroid</span>
                <span style={{ fontFamily: 'monospace', fontSize: '12px' }}>{selectedFinding.gpsCoords}</span>
              </div>

              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <span style={{ color: '#5F645D' }}>Soil Moisture Level</span>
                <span style={{ fontWeight: 700, color: selectedFinding.soilMoisturePercent < 25 ? '#AF413A' : '#435C3C' }}>
                  {selectedFinding.soilMoisturePercent}% ({selectedFinding.soilMoisturePercent < 25 ? 'Low' : 'Normal'})
                </span>
              </div>

              {/* Two-Stage AI & Probability Breakdown (Core Idea USP) */}
              <div style={{ marginTop: '6px' }}>
                <div style={{ fontSize: '11px', fontWeight: 600, color: '#5F645D', textTransform: 'uppercase', marginBottom: '6px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <span>AI Probability Distribution</span>
                  <span style={{ fontSize: '10px', color: '#435C3C', fontWeight: 700 }}>Two-Stage Edge Pass</span>
                </div>

                <div style={{ backgroundColor: '#F5F6F2', border: '1px solid #D8D9D2', borderRadius: '4px', padding: '10px', display: 'flex', flexDirection: 'column', gap: '6px' }}>
                  {/* Disease */}
                  <div>
                    <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '11px', marginBottom: '2px' }}>
                      <span style={{ color: '#AF413A', fontWeight: 600 }}>Crop Disease Risk</span>
                      <strong style={{ fontFamily: 'monospace' }}>{selectedFinding.probabilities?.disease || 72}%</strong>
                    </div>
                    <div style={{ height: '5px', backgroundColor: '#E8E9E3', borderRadius: '3px', overflow: 'hidden' }}>
                      <div style={{ width: `${selectedFinding.probabilities?.disease || 72}%`, backgroundColor: '#AF413A', height: '100%' }} />
                    </div>
                  </div>

                  {/* Water Stress */}
                  <div>
                    <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '11px', marginBottom: '2px' }}>
                      <span style={{ color: '#B07E28', fontWeight: 600 }}>Water Stress / Moisture Deficit</span>
                      <strong style={{ fontFamily: 'monospace' }}>{selectedFinding.probabilities?.waterStress || 18}%</strong>
                    </div>
                    <div style={{ height: '5px', backgroundColor: '#E8E9E3', borderRadius: '3px', overflow: 'hidden' }}>
                      <div style={{ width: `${selectedFinding.probabilities?.waterStress || 18}%`, backgroundColor: '#B07E28', height: '100%' }} />
                    </div>
                  </div>

                  {/* Nutrient */}
                  <div>
                    <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '11px', marginBottom: '2px' }}>
                      <span style={{ color: '#4B6B80' }}>Nutrient Deficiency</span>
                      <strong style={{ fontFamily: 'monospace' }}>{selectedFinding.probabilities?.nutrient || 7}%</strong>
                    </div>
                    <div style={{ height: '5px', backgroundColor: '#E8E9E3', borderRadius: '3px', overflow: 'hidden' }}>
                      <div style={{ width: `${selectedFinding.probabilities?.nutrient || 7}%`, backgroundColor: '#4B6B80', height: '100%' }} />
                    </div>
                  </div>

                  {/* Healthy */}
                  <div>
                    <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '11px', marginBottom: '2px' }}>
                      <span style={{ color: '#435C3C' }}>Healthy Canopy Baseline</span>
                      <strong style={{ fontFamily: 'monospace' }}>{selectedFinding.probabilities?.healthy || 3}%</strong>
                    </div>
                    <div style={{ height: '5px', backgroundColor: '#E8E9E3', borderRadius: '3px', overflow: 'hidden' }}>
                      <div style={{ width: `${selectedFinding.probabilities?.healthy || 3}%`, backgroundColor: '#435C3C', height: '100%' }} />
                    </div>
                  </div>
                </div>

                {/* Inspection Reduction Metric Badge */}
                <div style={{ marginTop: '8px', padding: '6px 10px', backgroundColor: '#E7EFE5', border: '1px solid rgba(67, 92, 60, 0.3)', borderRadius: '4px', fontSize: '11px', color: '#2A3B27', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <span>Manual Effort Saved:</span>
                  <strong style={{ fontFamily: 'monospace', fontSize: '12px', color: '#30432E' }}>
                    {selectedFinding.inspectionReductionPercent || 91.6}% (3 / 36 Zones Inspected)
                  </strong>
                </div>
              </div>
            </div>
          </div>

          {/* Feedback & Actions */}
          <div style={{ borderTop: '1px solid #E8E9E3', paddingTop: '14px', marginTop: '16px' }}>
            {decisionFeedback ? (
              <div style={{ padding: '10px', backgroundColor: '#E7EFE5', border: '1px solid #435C3C', borderRadius: '4px', fontSize: '12px', color: '#2A3B27', fontWeight: 500 }}>
                {decisionFeedback}
              </div>
            ) : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                <button
                  className="op-btn op-btn-primary"
                  style={{ width: '100%' }}
                  onClick={() => handleAction('confirm')}
                >
                  <Check size={15} /> Confirm Anomaly for Report
                </button>
                <button
                  className="op-btn op-btn-secondary"
                  style={{ width: '100%' }}
                  onClick={() => handleAction('reject')}
                >
                  <X size={15} /> Reject (False Positive)
                </button>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};
