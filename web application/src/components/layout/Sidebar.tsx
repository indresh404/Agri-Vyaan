import React from 'react';
import type { NavTab } from '../../types';
import { 
  LayoutDashboard, 
  FileText, 
  Map, 
  Radio, 
  CheckCircle2, 
  FileCheck, 
  BarChart3, 
  Activity, 
  Settings, 
  ShieldCheck,
  Cloud,
  BookOpen
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
  pendingValidationCount,
  pendingRequestsCount
}) => {
  const operationsNav = [
    { id: 'dashboard' as NavTab, label: 'Dashboard', icon: LayoutDashboard },
    { id: 'requests' as NavTab, label: 'Requests', icon: FileText, badge: pendingRequestsCount },
    { id: 'fields' as NavTab, label: 'Fields', icon: Map },
    { id: 'operations' as NavTab, label: 'Operations', icon: Radio },
    { id: 'validation' as NavTab, label: 'Validation', icon: CheckCircle2, badge: pendingValidationCount }
  ];

  const insightsNav = [
    { id: 'reports' as NavTab, label: 'Reports', icon: FileCheck },
    { id: 'analytics' as NavTab, label: 'Analytics', icon: BarChart3 },
    { id: 'weather' as NavTab, label: 'Weather', icon: Cloud },
    { id: 'library' as NavTab, label: 'Library', icon: BookOpen }
  ];

  const systemNav = [
    { id: 'activity' as NavTab, label: 'Activity', icon: Activity },
    { id: 'settings' as NavTab, label: 'Settings', icon: Settings }
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
          padding: '7px 12px',
          borderRadius: '4px',
          fontSize: '13px',
          fontWeight: isActive ? 600 : 400,
          color: isActive ? '#20231F' : '#6B7068',
          backgroundColor: isActive ? '#EBF0E9' : 'transparent',
          borderLeft: isActive ? '3px solid #4F6848' : '3px solid transparent',
          marginBottom: '2px',
          transition: 'all 0.1s ease'
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <Icon size={16} strokeWidth={1.75} color={isActive ? '#30432E' : '#6B7068'} />
          <span>{item.label}</span>
        </div>
        {item.badge !== undefined && item.badge > 0 && (
          <span 
            style={{
              fontSize: '10px',
              fontWeight: 600,
              backgroundColor: isActive ? '#4F6848' : '#DDDED7',
              color: isActive ? '#FFFFFF' : '#20231F',
              padding: '1px 6px',
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
        width: '230px',
        minWidth: '230px',
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
            padding: '16px 16px 14px 16px',
            borderBottom: '1px solid #EBECE6',
            display: 'flex',
            alignItems: 'center',
            gap: '10px'
          }}
        >
          <div 
            style={{
              width: '28px',
              height: '28px',
              backgroundColor: '#30432E',
              borderRadius: '4px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: '#FFFFFF',
              fontWeight: 'bold',
              fontSize: '13px'
            }}
          >
            AS
          </div>
          <div>
            <div style={{ fontSize: '14px', fontWeight: 700, color: '#20231F', lineHeight: 1.2 }}>
              AgriSwarm
            </div>
            <div style={{ fontSize: '11px', color: '#6B7068', letterSpacing: '0.4px', fontWeight: 500 }}>
              OPERATOR PLATFORM
            </div>
          </div>
        </div>

        {/* Navigation Sections */}
        <div style={{ padding: '12px 10px' }}>
          {/* OPERATIONS */}
          <div style={{ fontSize: '10px', fontWeight: 700, color: '#6B7068', letterSpacing: '0.8px', padding: '6px 10px 4px 10px' }}>
            OPERATIONS
          </div>
          {operationsNav.map(renderNavItem)}

          {/* INSIGHTS */}
          <div style={{ fontSize: '10px', fontWeight: 700, color: '#6B7068', letterSpacing: '0.8px', padding: '14px 10px 4px 10px' }}>
            INSIGHTS
          </div>
          {insightsNav.map(renderNavItem)}

          {/* SYSTEM */}
          <div style={{ fontSize: '10px', fontWeight: 700, color: '#6B7068', letterSpacing: '0.8px', padding: '14px 10px 4px 10px' }}>
            SYSTEM
          </div>
          {systemNav.map(renderNavItem)}
        </div>
      </div>

      {/* Bottom Operational Status */}
      <div 
        style={{
          borderTop: '1px solid #EBECE6',
          padding: '12px 14px',
          backgroundColor: '#FAFBF8'
        }}
      >
        {/* Operational Badge */}
        <div 
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
            fontSize: '11px',
            color: '#30432E',
            backgroundColor: '#EBF0E9',
            padding: '6px 10px',
            borderRadius: '4px',
            border: '1px solid rgba(79, 104, 72, 0.2)'
          }}
        >
          <span 
            style={{
              width: '7px',
              height: '7px',
              borderRadius: '50%',
              backgroundColor: '#587451'
            }}
          />
          <span style={{ fontWeight: 600 }}>System Operational</span>
          <ShieldCheck size={13} style={{ marginLeft: 'auto', color: '#4F6848' }} />
        </div>
      </div>
    </aside>
  );
};
