import React, { useState } from 'react';
import type { LibraryItem } from '../../types';

interface LibraryViewProps {
  library: LibraryItem[];
}

export const LibraryView: React.FC<LibraryViewProps> = ({ library }) => {
  const [activeTab, setActiveTab] = useState<'Crop' | 'Pest' | 'Disease'>('Crop');
  const [selectedItem, setSelectedItem] = useState<LibraryItem | null>(null);
  const [searchQuery, setSearchQuery] = useState('');

  const filtered = library.filter(item =>
    item.type === activeTab &&
    (item.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
     item.description.toLowerCase().includes(searchQuery.toLowerCase()))
  );

  const typeColors: Record<string, { bg: string; text: string; border: string }> = {
    Crop:    { bg: '#EBF0E9', text: '#30432E', border: 'rgba(79, 104, 72, 0.3)' },
    Pest:    { bg: '#FAEAE9', text: '#B64A43', border: 'rgba(182, 74, 67, 0.3)' },
    Disease: { bg: '#FEF5E4', text: '#B8862D', border: 'rgba(184, 134, 45, 0.3)' }
  };

  if (selectedItem) {
    const colors = typeColors[selectedItem.type];
    return (
      <div style={{ padding: '20px 24px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
        {/* Back Header */}
        <div>
          <button
            onClick={() => setSelectedItem(null)}
            style={{ fontSize: '12px', color: '#6B7068', display: 'inline-flex', alignItems: 'center', gap: '4px', marginBottom: '8px' }}
          >
            ← Back to Library
          </button>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <h1 style={{ fontSize: '24px', fontWeight: 700, color: '#20231F', margin: 0 }}>
                  {selectedItem.name}
                </h1>
                <span style={{
                  fontSize: '10px', fontWeight: 700, textTransform: 'uppercase',
                  backgroundColor: colors.bg, color: colors.text,
                  border: `1px solid ${colors.border}`, borderRadius: '3px', padding: '2px 8px'
                }}>
                  {selectedItem.type}
                </span>
              </div>
              <p style={{ fontSize: '13px', color: '#6B7068', marginTop: '4px' }}>
                Affected crops: {selectedItem.affectedCrops.join(', ')}
              </p>
            </div>
          </div>
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
          {/* Left: Description + Details */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
            <div style={{ backgroundColor: '#FFFFFF', border: '1px solid #DDDED7', borderRadius: '4px', padding: '16px' }}>
              <div style={{ fontSize: '11px', fontWeight: 700, color: '#6B7068', textTransform: 'uppercase', marginBottom: '8px' }}>
                Description
              </div>
              <p style={{ fontSize: '13px', color: '#20231F', lineHeight: 1.5, margin: 0 }}>
                {selectedItem.description}
              </p>
            </div>

            <div style={{ backgroundColor: '#FFFFFF', border: '1px solid #DDDED7', borderRadius: '4px', padding: '16px' }}>
              <div style={{ fontSize: '11px', fontWeight: 700, color: '#6B7068', textTransform: 'uppercase', marginBottom: '10px' }}>
                {selectedItem.type === 'Crop' ? 'Growing Conditions' : 'Key Facts'}
              </div>
              <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                {selectedItem.details.map((detail, i) => (
                  <div key={i} style={{ display: 'flex', gap: '8px', fontSize: '12px' }}>
                    <span style={{ color: '#4F6848', fontWeight: 700, flexShrink: 0 }}>→</span>
                    <span style={{ color: '#20231F' }}>{detail}</span>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Right: Symptoms + Prevention + Management */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
            {selectedItem.symptoms && (
              <div style={{
                backgroundColor: '#FAEAE9',
                border: '1px solid rgba(182, 74, 67, 0.2)',
                borderRadius: '4px',
                padding: '14px'
              }}>
                <div style={{ fontSize: '11px', fontWeight: 700, color: '#B64A43', textTransform: 'uppercase', marginBottom: '6px' }}>
                  Symptoms
                </div>
                <p style={{ fontSize: '12px', color: '#20231F', lineHeight: 1.5, margin: 0 }}>
                  {selectedItem.symptoms}
                </p>
              </div>
            )}

            {selectedItem.prevention && (
              <div style={{
                backgroundColor: '#EBF0E9',
                border: '1px solid rgba(79, 104, 72, 0.2)',
                borderRadius: '4px',
                padding: '14px'
              }}>
                <div style={{ fontSize: '11px', fontWeight: 700, color: '#30432E', textTransform: 'uppercase', marginBottom: '6px' }}>
                  Prevention
                </div>
                <p style={{ fontSize: '12px', color: '#20231F', lineHeight: 1.5, margin: 0 }}>
                  {selectedItem.prevention}
                </p>
              </div>
            )}

            {selectedItem.management && (
              <div style={{
                backgroundColor: '#FFFFFF',
                border: '1px solid #DDDED7',
                borderRadius: '4px',
                padding: '14px'
              }}>
                <div style={{ fontSize: '11px', fontWeight: 700, color: '#6B7068', textTransform: 'uppercase', marginBottom: '6px' }}>
                  Management / Treatment
                </div>
                <p style={{ fontSize: '12px', color: '#20231F', lineHeight: 1.5, margin: 0 }}>
                  {selectedItem.management}
                </p>
              </div>
            )}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div style={{ padding: '20px 24px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
      {/* Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 style={{ fontSize: '22px', fontWeight: 700, color: '#20231F', margin: 0 }}>
            Agricultural Knowledge Library
          </h1>
          <p style={{ fontSize: '13px', color: '#6B7068', marginTop: '2px' }}>
            Crops, pests, and diseases — growing conditions, diagnostics, and management.
          </p>
        </div>
        <input
          className="op-input"
          type="text"
          placeholder="Search library..."
          value={searchQuery}
          onChange={e => setSearchQuery(e.target.value)}
          style={{ width: '220px' }}
        />
      </div>

      {/* Tab Bar */}
      <div style={{ display: 'flex', gap: '4px', borderBottom: '1px solid #DDDED7', paddingBottom: '0' }}>
        {(['Crop', 'Pest', 'Disease'] as const).map(tab => {
          const colors = typeColors[tab];
          const count = library.filter(i => i.type === tab).length;
          return (
            <button
              key={tab}
              onClick={() => setActiveTab(tab)}
              style={{
                padding: '8px 16px',
                fontSize: '13px',
                fontWeight: activeTab === tab ? 700 : 400,
                color: activeTab === tab ? colors.text : '#6B7068',
                borderBottom: activeTab === tab ? `2px solid ${colors.text}` : '2px solid transparent',
                marginBottom: '-1px',
                backgroundColor: 'transparent'
              }}
            >
              {tab}s
              <span style={{
                marginLeft: '6px',
                fontSize: '10px',
                padding: '1px 5px',
                borderRadius: '10px',
                backgroundColor: activeTab === tab ? colors.bg : '#F0F0EC',
                color: activeTab === tab ? colors.text : '#6B7068',
                fontWeight: 600
              }}>
                {count}
              </span>
            </button>
          );
        })}
      </div>

      {/* Grid */}
      {filtered.length === 0 ? (
        <div style={{ textAlign: 'center', padding: '40px', color: '#6B7068', fontSize: '13px' }}>
          No results found for "{searchQuery}".
        </div>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))', gap: '14px' }}>
          {filtered.map(item => {
            const colors = typeColors[item.type];
            return (
              <div
                key={item.id}
                onClick={() => setSelectedItem(item)}
                style={{
                  backgroundColor: '#FFFFFF',
                  border: '1px solid #DDDED7',
                  borderRadius: '4px',
                  padding: '16px',
                  cursor: 'pointer',
                  transition: 'border-color 0.15s ease'
                }}
                onMouseEnter={e => e.currentTarget.style.borderColor = '#4F6848'}
                onMouseLeave={e => e.currentTarget.style.borderColor = '#DDDED7'}
              >
                {/* Badge + Name */}
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '8px' }}>
                  <h2 style={{ fontSize: '15px', fontWeight: 700, color: '#20231F', margin: 0 }}>
                    {item.name}
                  </h2>
                  <span style={{
                    fontSize: '9px', fontWeight: 700, textTransform: 'uppercase',
                    backgroundColor: colors.bg, color: colors.text,
                    border: `1px solid ${colors.border}`, borderRadius: '3px', padding: '2px 6px'
                  }}>
                    {item.type}
                  </span>
                </div>

                {/* Description */}
                <p style={{
                  fontSize: '12px', color: '#6B7068', lineHeight: 1.4, margin: '0 0 10px 0',
                  display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden'
                }}>
                  {item.description}
                </p>

                {/* Affected Crops */}
                <div style={{ fontSize: '11px', color: '#6B7068' }}>
                  <span style={{ fontWeight: 600 }}>Crops: </span>
                  {item.affectedCrops.join(', ')}
                </div>

                {/* Key Detail */}
                <div style={{
                  marginTop: '10px', paddingTop: '10px', borderTop: '1px solid #EBECE6',
                  fontSize: '11px', color: '#4F6848', fontWeight: 600
                }}>
                  {item.details[0]}
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
};
