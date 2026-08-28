import React from 'react';
import { Activity, ShieldCheck, Zap, BarChart2 } from 'lucide-react';

export const AnalyticsView: React.FC = () => {
  return (
    <div style={{ padding: '20px 24px', display: 'flex', flexDirection: 'column', gap: '20px' }}>
      {/* Title */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 style={{ fontSize: '22px', fontWeight: 700, color: '#1C201A', margin: 0 }}>
            Operational Analytics & Agronomic Intelligence
          </h1>
          <p style={{ fontSize: '13px', color: '#5F645D', marginTop: '2px' }}>
            Telemetry, inspection efficiency metrics, probability model calibration, and crop health trends.
          </p>
        </div>
        <div style={{ display: 'flex', gap: '8px', fontSize: '11px', color: '#5F645D' }}>
          <span style={{ backgroundColor: '#E7EFE5', color: '#2A3B27', padding: '4px 10px', borderRadius: '4px', border: '1px solid rgba(67, 92, 60, 0.3)', fontWeight: 600 }}>
            Region: Thane & Kalyan Sectors
          </span>
        </div>
      </div>

      {/* Top 4 KPI Highlight Cards (Core Idea Metrics) */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '16px' }}>
        {/* KPI 1: Inspection Effort Reduction */}
        <div style={{ backgroundColor: '#FFFFFF', border: '1px solid #D8D9D2', borderRadius: '6px', padding: '16px', boxShadow: '0 1px 3px rgba(0,0,0,0.04)' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span style={{ fontSize: '11px', fontWeight: 700, color: '#5F645D', textTransform: 'uppercase' }}>Manual Effort Saved</span>
            <Zap size={16} color="#435C3C" />
          </div>
          <div style={{ fontSize: '28px', fontWeight: 800, color: '#1C201A', marginTop: '6px', fontFamily: 'monospace' }}>
            91.6%
          </div>
          <div style={{ fontSize: '11px', color: '#435C3C', fontWeight: 600, marginTop: '2px' }}>
            3 of 36 zones inspected (88.4% reduction)
          </div>
        </div>

        {/* KPI 2: Two-Stage AI Efficiency */}
        <div style={{ backgroundColor: '#FFFFFF', border: '1px solid #D8D9D2', borderRadius: '6px', padding: '16px', boxShadow: '0 1px 3px rgba(0,0,0,0.04)' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span style={{ fontSize: '11px', fontWeight: 700, color: '#5F645D', textTransform: 'uppercase' }}>Stage 1 Quick Pass</span>
            <Activity size={16} color="#4B6B80" />
          </div>
          <div style={{ fontSize: '28px', fontWeight: 800, color: '#1C201A', marginTop: '6px', fontFamily: 'monospace' }}>
            4.2 mins
          </div>
          <div style={{ fontSize: '11px', color: '#5F645D', marginTop: '2px' }}>
            Full 5 ha field edge scan time
          </div>
        </div>

        {/* KPI 3: Model Calibration Confidence */}
        <div style={{ backgroundColor: '#FFFFFF', border: '1px solid #D8D9D2', borderRadius: '6px', padding: '16px', boxShadow: '0 1px 3px rgba(0,0,0,0.04)' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span style={{ fontSize: '11px', fontWeight: 700, color: '#5F645D', textTransform: 'uppercase' }}>Model Precision</span>
            <ShieldCheck size={16} color="#30432E" />
          </div>
          <div style={{ fontSize: '28px', fontWeight: 800, color: '#1C201A', marginTop: '6px', fontFamily: 'monospace' }}>
            91.4%
          </div>
          <div style={{ fontSize: '11px', color: '#30432E', fontWeight: 600, marginTop: '2px' }}>
            Confirmed vs ground soil probe
          </div>
        </div>

        {/* KPI 4: Total Acreage Monitored */}
        <div style={{ backgroundColor: '#FFFFFF', border: '1px solid #D8D9D2', borderRadius: '6px', padding: '16px', boxShadow: '0 1px 3px rgba(0,0,0,0.04)' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span style={{ fontSize: '11px', fontWeight: 700, color: '#5F645D', textTransform: 'uppercase' }}>Monitored Area</span>
            <BarChart2 size={16} color="#B07E28" />
          </div>
          <div style={{ fontSize: '28px', fontWeight: 800, color: '#1C201A', marginTop: '6px', fontFamily: 'monospace' }}>
            124.6 ha
          </div>
          <div style={{ fontSize: '11px', color: '#5F645D', marginTop: '2px' }}>
            18 farmer fields registered
          </div>
        </div>
      </div>

      {/* Analytics Main Grid */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px' }}>
        {/* Metric Card 1: Regional Spatial Zone Health Distribution */}
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
            Regional Spatial Zone Health Distribution
          </h2>
          <div style={{ marginTop: '16px', display: 'flex', flexDirection: 'column', gap: '14px' }}>
            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '12px', marginBottom: '4px' }}>
                <span style={{ color: '#5F645D', fontWeight: 500 }}>Healthy Canopy (NDVI &gt; 0.65)</span>
                <strong style={{ color: '#435C3C', fontFamily: 'monospace' }}>112 Zones (77.7%)</strong>
              </div>
              <div style={{ backgroundColor: '#E8E9E3', height: '8px', borderRadius: '4px', overflow: 'hidden' }}>
                <div style={{ width: '77.7%', backgroundColor: '#435C3C', height: '100%' }} />
              </div>
            </div>

            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '12px', marginBottom: '4px' }}>
                <span style={{ color: '#5F645D', fontWeight: 500 }}>Warning / Moisture Deficit (NDVI 0.40 - 0.60)</span>
                <strong style={{ color: '#B07E28', fontFamily: 'monospace' }}>24 Zones (16.6%)</strong>
              </div>
              <div style={{ backgroundColor: '#E8E9E3', height: '8px', borderRadius: '4px', overflow: 'hidden' }}>
                <div style={{ width: '16.6%', backgroundColor: '#B07E28', height: '100%' }} />
              </div>
            </div>

            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '12px', marginBottom: '4px' }}>
                <span style={{ color: '#5F645D', fontWeight: 500 }}>High Priority Anomaly (Zone 27, Zone 08)</span>
                <strong style={{ color: '#AF413A', fontFamily: 'monospace' }}>8 Zones (5.5%)</strong>
              </div>
              <div style={{ backgroundColor: '#E8E9E3', height: '8px', borderRadius: '4px', overflow: 'hidden' }}>
                <div style={{ width: '5.5%', backgroundColor: '#AF413A', height: '100%' }} />
              </div>
            </div>
          </div>
        </div>

        {/* Metric Card 2: Mission & Validation Throughput */}
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
            Mission Execution & Operator Review Throughput
          </h2>
          <div style={{ marginTop: '16px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '14px' }}>
            <div style={{ padding: '12px', backgroundColor: '#F5F6F2', border: '1px solid #D8D9D2', borderRadius: '4px' }}>
              <div style={{ fontSize: '11px', color: '#5F645D', fontWeight: 600 }}>Avg Flight Time</div>
              <div style={{ fontSize: '20px', fontWeight: 700, color: '#1C201A', marginTop: '2px', fontFamily: 'monospace' }}>18 mins</div>
              <div style={{ fontSize: '11px', color: '#435C3C', marginTop: '4px' }}>Per 5.0 ha parcel</div>
            </div>

            <div style={{ padding: '12px', backgroundColor: '#F5F6F2', border: '1px solid #D8D9D2', borderRadius: '4px' }}>
              <div style={{ fontSize: '11px', color: '#5F645D', fontWeight: 600 }}>Validation Turnaround</div>
              <div style={{ fontSize: '20px', fontWeight: 700, color: '#1C201A', marginTop: '2px', fontFamily: 'monospace' }}>8 mins</div>
              <div style={{ fontSize: '11px', color: '#4B6B80', marginTop: '4px' }}>Operator human sign-off</div>
            </div>

            <div style={{ padding: '12px', backgroundColor: '#F5F6F2', border: '1px solid #D8D9D2', borderRadius: '4px' }}>
              <div style={{ fontSize: '11px', color: '#5F645D', fontWeight: 600 }}>Two-Stage Rescan Ratio</div>
              <div style={{ fontSize: '20px', fontWeight: 700, color: '#30432E', marginTop: '2px', fontFamily: 'monospace' }}>8.4%</div>
              <div style={{ fontSize: '11px', color: '#5F645D', marginTop: '4px' }}>Only flagged zones rescanned</div>
            </div>

            <div style={{ padding: '12px', backgroundColor: '#F5F6F2', border: '1px solid #D8D9D2', borderRadius: '4px' }}>
              <div style={{ fontSize: '11px', color: '#5F645D', fontWeight: 600 }}>Total Service Requests</div>
              <div style={{ fontSize: '20px', fontWeight: 700, color: '#1C201A', marginTop: '2px', fontFamily: 'monospace' }}>18</div>
              <div style={{ fontSize: '11px', color: '#5F645D', marginTop: '4px' }}>100% booked via platform</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
