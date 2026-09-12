import React from 'react';
import type { NavTab } from '../../types';
import { 
  Map, 
  Radio, 
  FileText, 
  ShieldCheck
} from 'lucide-react';

interface SidebarProps {
  activeTab: NavTab;
  onNavigate: (tab: NavTab) => void;
  pendingValidationCount: number;
  pendingRequestsCount: number;
}

export const Sidebar: React.FC<SidebarProps> = ({
  activeTab,
  onNavigate,
  pendingRequestsCount
}) => {
  const missionNav = [
    { id: 'fields' as NavTab, label: 'Mission Boundary Planner', icon: Map },
    { id: 'operations' as NavTab, label: 'Drone Scan Operations', icon: Radio },
    { id: 'requests' as NavTab, label: 'Field Scan Requests', icon: FileText, badge: pendingRequestsCount },
  ];

  const renderNavItem = (item: { id: NavTab; label: string; icon: React.ElementType; badge?: number }) => {
    const Icon = item.icon;
    const isActive = activeTab === item.id || 
      (item.id === 'fields' && activeTab === 'field-details') ||
      (item.id === 'operations' && activeTab === 'operation-details');

    return (
      <button
        key={item.id}
        onClick={() => onNavigate(item.id)}
        style={{
          width: '100%',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          padding: '9px 12px',
          borderRadius: '6px',
          fontSize: '13px',
          fontWeight: isActive ? 700 : 500,
          color: isActive ? '#30432E' : '#555B52',
          backgroundColor: isActive ? '#EBF0E9' : 'transparent',
          borderLeft: isActive ? '3px solid #4F6848' : '3px solid transparent',
          marginBottom: '4px',
          transition: 'all 0.15s ease',
          cursor: 'pointer'
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <Icon size={17} strokeWidth={1.8} color={isActive ? '#30432E' : '#6B7068'} />
          <span>{item.label}</span>
        </div>
        {item.badge !== undefined && item.badge > 0 && (
          <span 
            style={{
              fontSize: '10px',
              fontWeight: 700,
              backgroundColor: isActive ? '#4F6848' : '#DDDED7',
              color: isActive ? '#FFFFFF' : '#20231F',
              padding: '2px 7px',
              borderRadius: '10px'
            }}
          >
            {item.badge}
          </span>
        )}
      </button>
    );
  };

  return (
    <aside
      style={{
        width: '240px',
        minWidth: '240px',
        height: '100%',
        backgroundColor: '#FFFFFF',
        borderRight: '1px solid #DDDED7',
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'space-between',
        userSelect: 'none'
      }}
    >
      <div>
        {/* Brand Header */}
        <div 
          style={{
            padding: '18px 16px 16px 16px',
            borderBottom: '1px solid #EBECE6',
            display: 'flex',
            alignItems: 'center',
            gap: '10px'
          }}
        >
          <div 
            style={{
              width: '32px',
              height: '32px',
              backgroundColor: '#30432E',
              borderRadius: '6px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: '#FFFFFF',
              fontWeight: 'bold',
              fontSize: '14px',
              boxShadow: '0 2px 6px rgba(48,67,46,0.3)'
            }}
          >
            AS
          </div>
          <div>
            <div style={{ fontSize: '15px', fontWeight: 800, color: '#20231F', lineHeight: 1.2 }}>
              AgriSwarm
            </div>
            <div style={{ fontSize: '10px', color: '#4F6848', letterSpacing: '0.6px', fontWeight: 700 }}>
              MISSION PLANNER WEB
            </div>
          </div>
        </div>

        {/* Navigation Section */}
        <div style={{ padding: '16px 12px' }}>
          <div style={{ fontSize: '10px', fontWeight: 700, color: '#6B7068', letterSpacing: '0.8px', padding: '0 10px 8px 10px' }}>
            PIXHAWK MISSION UPLOADER
          </div>
          {missionNav.map(renderNavItem)}
        </div>
      </div>

      {/* Bottom Operational Status */}
      <div 
        style={{
          borderTop: '1px solid #EBECE6',
          padding: '14px',
          backgroundColor: '#FAFBF8'
        }}
      >
        <div 
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
            fontSize: '11px',
            color: '#30432E',
            backgroundColor: '#EBF0E9',
            padding: '8px 12px',
            borderRadius: '6px',
            border: '1px solid rgba(79, 104, 72, 0.2)'
          }}
        >
          <span 
            style={{
              width: '8px',
              height: '8px',
              borderRadius: '50%',
              backgroundColor: '#587451'
            }}
          />
          <span style={{ fontWeight: 700 }}>Pixhawk Ready</span>
          <ShieldCheck size={14} style={{ marginLeft: 'auto', color: '#4F6848' }} />
        </div>
      </div>
    </aside>
  );
};
