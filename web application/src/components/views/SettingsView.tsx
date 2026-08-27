import React from 'react';

export const SettingsView: React.FC = () => {
  return (
    <div style={{ padding: '20px 24px', display: 'flex', flexDirection: 'column', gap: '20px' }}>
      {/* Title */}
      <div>
        <h1 style={{ fontSize: '22px', fontWeight: 700, color: '#20231F', margin: 0 }}>
          Operator Workspace Settings
        </h1>
        <p style={{ fontSize: '13px', color: '#6B7068', marginTop: '2px' }}>
          Configure drone communication protocols, operator credentials, and model threshold parameters.
        </p>
      </div>

      {/* Settings Sections */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px' }}>
        <div 
          style={{
            backgroundColor: '#FFFFFF',
            border: '1px solid #DDDED7',
            borderRadius: '4px',
            padding: '16px'
          }}
        >
          <h2 style={{ fontSize: '15px', fontWeight: 600, color: '#20231F', margin: 0, borderBottom: '1px solid #EBECE6', paddingBottom: '8px' }}>
            Operator Identification
          </h2>
          <div style={{ marginTop: '14px', display: 'flex', flexDirection: 'column', gap: '10px', fontSize: '13px' }}>
            <div>
              <label style={{ fontSize: '11px', fontWeight: 600, color: '#6B7068' }}>OPERATOR NAME</label>
              <input type="text" className="op-input" style={{ width: '100%', marginTop: '2px' }} defaultValue="Vikram Sharma" />
            </div>
            <div>
              <label style={{ fontSize: '11px', fontWeight: 600, color: '#6B7068' }}>OPERATOR ID & BADGE</label>
              <input type="text" className="op-input" style={{ width: '100%', marginTop: '2px' }} defaultValue="Operator #04 (Thane Regional Station)" readOnly />
            </div>
            <div>
              <label style={{ fontSize: '11px', fontWeight: 600, color: '#6B7068' }}>SECURITY CLEARANCE</label>
              <div style={{ fontSize: '12px', color: '#30432E', fontWeight: 600, marginTop: '2px' }}>
                Level 2 Certified Flight Operations Supervisor
              </div>
            </div>
          </div>
        </div>

        <div 
          style={{
            backgroundColor: '#FFFFFF',
            border: '1px solid #DDDED7',
            borderRadius: '4px',
            padding: '16px'
          }}
        >
          <h2 style={{ fontSize: '15px', fontWeight: 600, color: '#20231F', margin: 0, borderBottom: '1px solid #EBECE6', paddingBottom: '8px' }}>
            AI Model Threshold Parameters
          </h2>
          <div style={{ marginTop: '14px', display: 'flex', flexDirection: 'column', gap: '10px', fontSize: '13px' }}>
            <div>
              <label style={{ fontSize: '11px', fontWeight: 600, color: '#6B7068' }}>CANOPY ANOMALY CONFIDENCE THRESHOLD</label>
              <select className="op-select" style={{ width: '100%', marginTop: '2px' }} defaultValue="75">
                <option value="70">70% (Flag potential early stress)</option>
                <option value="75">75% Standard Operational Balance</option>
                <option value="85">85% High Precision Only</option>
              </select>
            </div>
            <div>
              <label style={{ fontSize: '11px', fontWeight: 600, color: '#6B7068' }}>CALIBRATION SENSOR BAND</label>
              <select className="op-select" style={{ width: '100%', marginTop: '2px' }} defaultValue="ndvi">
                <option value="ndvi">NDVI (Normalized Difference Vegetation Index)</option>
                <option value="ndre">NDRE (Red Edge Canopy Chlorophyll)</option>
                <option value="rgb">RGB Color Anomaly</option>
              </select>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
