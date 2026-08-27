import React, { useState } from 'react';
import type { NavTab } from '../../types';
import { Search, Bell, ChevronRight, X } from 'lucide-react';

interface HeaderProps {
  activeTab: NavTab;
  onNavigate: (tab: NavTab) => void;
  searchQuery: string;
  onSearchChange: (q: string) => void;
  selectedFieldId?: string;
  selectedOpId?: string;
}

export const Header: React.FC<HeaderProps> = ({
  activeTab,
  onNavigate,
  searchQuery,
  onSearchChange,
  selectedFieldId,
  selectedOpId
}) => {
  const [showNotifications, setShowNotifications] = useState(false);

  const getBreadcrumbs = () => {
    switch (activeTab) {
      case 'dashboard':
        return ['Operations', 'Dashboard'];
      case 'requests':
        return ['Operations', 'Requests'];
      case 'fields':
        return ['Operations', 'Fields'];
      case 'field-details':
        return ['Operations', 'Fields', selectedFieldId || 'Field A'];
      case 'operations':
        return ['Operations', 'Drone Operations'];
      case 'operation-details':
        return ['Operations', 'Drone Operations', selectedOpId || 'OP-0142'];
      case 'validation':
        return ['Operations', 'AI Validation Queue'];
      case 'reports':
        return ['Insights', 'Field Reports'];
      case 'analytics':
        return ['Insights', 'Analytics & Trends'];
      case 'activity':
        return ['System', 'Activity Log'];
      case 'settings':
        return ['System', 'Settings'];
      default:
        return ['Operations', 'Dashboard'];
    }
  };

  const breadcrumbs = getBreadcrumbs();

  const notifications = [
    { id: 1, title: 'Validation Required', text: 'Finding FND-027 on Zone 27 needs human review.', time: '10 min ago', type: 'critical' },
    { id: 2, title: 'Operation Update', text: 'OP-0142 reached 68% progress over Field A.', time: '25 min ago', type: 'info' },
    { id: 3, title: 'New Request Received', text: 'REQ-1024 submitted by Ramesh Kumar.', time: '1 hour ago', type: 'warning' }
  ];

  return (
    <header
      style={{
        height: '48px',
        minHeight: '48px',
        backgroundColor: '#FFFFFF',
        borderBottom: '1px solid #DDDED7',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        padding: '0 20px',
        zIndex: 50,
        userSelect: 'none'
      }}
    >
      {/* Breadcrumb Trail */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '12px', color: '#5F645D' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
          <span className="pulse-dot" title="Operational Connection Active (14ms)" />
          <span style={{ fontWeight: 700, color: '#1C201A' }}>AgriSwarm</span>
        </div>
        {breadcrumbs.map((crumb, idx) => (
          <React.Fragment key={idx}>
            <ChevronRight size={12} color="#A8AAA0" />
            <span 
              style={{
                color: idx === breadcrumbs.length - 1 ? '#1C201A' : '#5F645D',
                fontWeight: idx === breadcrumbs.length - 1 ? 600 : 400
              }}
            >
              {crumb}
            </span>
          </React.Fragment>
        ))}
      </div>

      {/* Right Controls: Search, Notifications, Profile */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
        {/* Compact Search Bar with Shortcut */}
        <div style={{ position: 'relative', width: '260px' }}>
          <Search 
            size={13} 
            color="#5F645D" 
            style={{ position: 'absolute', left: '9px', top: '50%', transform: 'translateY(-50%)' }} 
          />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => onSearchChange(e.target.value)}
            placeholder="Search REQ-1024, Field A, OP-0142..."
            className="op-input"
            style={{
              width: '100%',
              paddingLeft: '28px',
              paddingRight: searchQuery ? '26px' : '36px',
              fontSize: '12px',
              height: '28px'
            }}
          />
          {!searchQuery && (
            <span 
              style={{
                position: 'absolute',
                right: '8px',
                top: '50%',
                transform: 'translateY(-50%)',
                fontSize: '10px',
                color: '#8A9087',
                backgroundColor: '#F5F6F2',
                border: '1px solid #D8D9D2',
                borderRadius: '3px',
                padding: '0 4px',
                fontFamily: 'monospace'
              }}
            >
              /
            </span>
          )}
          {searchQuery && (
            <button
              onClick={() => onSearchChange('')}
              style={{
                position: 'absolute',
                right: '6px',
                top: '50%',
                transform: 'translateY(-50%)',
                color: '#5F645D'
              }}
            >
              <X size={12} />
            </button>
          )}
        </div>

        {/* Notifications Icon & Popover */}
        <div style={{ position: 'relative' }}>
          <button
            onClick={() => setShowNotifications(!showNotifications)}
            style={{
              position: 'relative',
              width: '28px',
              height: '28px',
              borderRadius: '4px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              border: '1px solid #DDDED7',
              backgroundColor: showNotifications ? '#F0F1EA' : '#FFFFFF'
            }}
            title="Notifications"
          >
            <Bell size={14} color="#20231F" />
            <span 
              style={{
                position: 'absolute',
                top: '3px',
                right: '3px',
                width: '6px',
                height: '6px',
                backgroundColor: '#B64A43',
                borderRadius: '50%'
              }}
            />
          </button>

          {/* Notifications Dropdown */}
          {showNotifications && (
            <div
              style={{
                position: 'absolute',
                right: 0,
                top: '34px',
                width: '300px',
                backgroundColor: '#FFFFFF',
                border: '1px solid #DDDED7',
                borderRadius: '4px',
                boxShadow: '0 4px 12px rgba(0,0,0,0.1)',
                zIndex: 100,
                padding: '10px'
              }}
            >
              <div 
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  paddingBottom: '8px',
                  borderBottom: '1px solid #EBECE6',
                  fontSize: '12px',
                  fontWeight: 600,
                  color: '#20231F'
                }}
              >
                <span>Operational Alerts</span>
                <span style={{ fontSize: '10px', color: '#6B7068' }}>3 Unread</span>
              </div>

              <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', marginTop: '8px' }}>
                {notifications.map(n => (
                  <div
                    key={n.id}
                    onClick={() => {
                      setShowNotifications(false);
                      if (n.id === 1) onNavigate('validation');
                      else if (n.id === 2) onNavigate('operations');
                      else onNavigate('requests');
                    }}
                    style={{
                      padding: '8px',
                      borderRadius: '3px',
                      backgroundColor: n.type === 'critical' ? '#FAF0E6' : '#FAFBF8',
                      borderLeft: `3px solid ${n.type === 'critical' ? '#B64A43' : '#55758A'}`,
                      cursor: 'pointer'
                    }}
                  >
                    <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '11px', fontWeight: 600, color: '#20231F' }}>
                      <span>{n.title}</span>
                      <span style={{ fontSize: '10px', color: '#6B7068', fontWeight: 'normal' }}>{n.time}</span>
                    </div>
                    <div style={{ fontSize: '11px', color: '#6B7068', marginTop: '2px' }}>
                      {n.text}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>

        {/* Date Display */}
        <div style={{ fontSize: '12px', color: '#6B7068', fontWeight: 500, paddingLeft: '6px', borderLeft: '1px solid #DDDED7' }}>
          Thu, Aug 27, 2026
        </div>
      </div>
    </header>
  );
};
