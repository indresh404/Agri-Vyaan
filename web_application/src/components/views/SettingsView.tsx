import React from 'react';

export const SettingsView: React.FC = () => {
  return (
    <div style={{ padding: '20px 24px', display: 'flex', flexDirection: 'column', gap: '20px' }}>
      {/* Title */}
      <div>
        <h1 style={{ fontSize: '22px', fontWeight: 700, color: '#1C201A', margin: 0 }}>
          System & Platform Settings
        </h1>
        <p style={{ fontSize: '13px', color: '#5F645D', marginTop: '2px' }}>
          Configure drone communications, edge hardware telemetry, Supabase database endpoints, and model thresholds.
        </p>
      </div>

      {/* Settings Sections */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px' }}>
        {/* Section 1: Edge Hardware Node & Telemetry Protocol (Replaced User Name) */}
        <div 
          style={{
            backgroundColor: '#FFFFFF',
            border: '1px solid #D8D9D2',
            borderRadius: '6px',
            padding: '18px',
            boxShadow: '0 1px 3px rgba(0,0,0,0.04)'
          }}
        >
          <h2 style={{ fontSize: '15px', fontWeight: 700, color: '#1C201A', margin: 0, borderBottom: '1px solid #E8E9E3', paddingBottom: '10px' }}>
            Edge AI Hardware & Drone Telemetry Node
          </h2>
          <div style={{ marginTop: '14px', display: 'flex', flexDirection: 'column', gap: '12px', fontSize: '13px' }}>
            <div>
              <label style={{ fontSize: '11px', fontWeight: 600, color: '#5F645D', textTransform: 'uppercase' }}>Target Crop Focus</label>
              <input type="text" className="op-input" style={{ width: '100%', marginTop: '2px', fontWeight: 700, color: '#435C3C' }} defaultValue="Potato (Solanum tuberosum)" readOnly />
            </div>
            <div>
              <label style={{ fontSize: '11px', fontWeight: 600, color: '#5F645D', textTransform: 'uppercase' }}>Edge Hardware Unit</label>
              <input type="text" className="op-input" style={{ width: '100%', marginTop: '2px', fontFamily: 'monospace' }} defaultValue="AgriSwarm-Edge-v2.4 (NVIDIA Jetson Orin Nano)" readOnly />
            </div>
            <div>
              <label style={{ fontSize: '11px', fontWeight: 600, color: '#5F645D', textTransform: 'uppercase' }}>Telemetry Data Frequency</label>
              <select className="op-select" style={{ width: '100%', marginTop: '2px' }} defaultValue="2000">
                <option value="1000">1000 ms (Realtime High Frequency)</option>
                <option value="2000">2000 ms (Standard Balanced Stream)</option>
                <option value="5000">5000 ms (Low Bandwidth Mode)</option>
              </select>
            </div>
            <div>
              <label style={{ fontSize: '11px', fontWeight: 600, color: '#5F645D', textTransform: 'uppercase' }}>Drone Communication Channel</label>
              <input type="text" className="op-input" style={{ width: '100%', marginTop: '2px', fontFamily: 'monospace' }} defaultValue="MAVLink v2.0 / 2.4 GHz Encrypted Radio Telemetry" readOnly />
            </div>
          </div>
        </div>

        {/* Section 2: AI Model Thresholds & Cloud Endpoint */}
        <div 
          style={{
            backgroundColor: '#FFFFFF',
            border: '1px solid #D8D9D2',
            borderRadius: '6px',
            padding: '18px',
            boxShadow: '0 1px 3px rgba(0,0,0,0.04)'
          }}
        >
          <h2 style={{ fontSize: '15px', fontWeight: 700, color: '#1C201A', margin: 0, borderBottom: '1px solid #E8E9E3', paddingBottom: '10px' }}>
            AI Model Thresholds & Database Configuration
          </h2>
          <div style={{ marginTop: '14px', display: 'flex', flexDirection: 'column', gap: '12px', fontSize: '13px' }}>
            <div>
              <label style={{ fontSize: '11px', fontWeight: 600, color: '#5F645D', textTransform: 'uppercase' }}>Potato Anomaly Confidence Cutoff</label>
              <select className="op-select" style={{ width: '100%', marginTop: '2px' }} defaultValue="75">
                <option value="70">70% (Flag early blight / mild leaf spots)</option>
                <option value="75">75% Standard Balanced Threshold</option>
                <option value="85">85% High Precision Only (Late Blight emphasis)</option>
              </select>
            </div>
            <div>
              <label style={{ fontSize: '11px', fontWeight: 600, color: '#5F645D', textTransform: 'uppercase' }}>Multispectral Index Band</label>
              <select className="op-select" style={{ width: '100%', marginTop: '2px' }} defaultValue="ndvi">
                <option value="ndvi">NDVI (Normalized Difference Vegetation Index)</option>
                <option value="ndre">NDRE (Red Edge Chlorophyll for Potato Canopy)</option>
                <option value="rgb">RGB TrueColor Anomaly</option>
              </select>
            </div>
            <div>
              <label style={{ fontSize: '11px', fontWeight: 600, color: '#5F645D', textTransform: 'uppercase' }}>Supabase Cloud Endpoint</label>
              <input type="text" className="op-input" style={{ width: '100%', marginTop: '2px', fontFamily: 'monospace', fontSize: '11px' }} defaultValue="https://agriswarm-platform.supabase.co (PostgreSQL v15)" readOnly />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
