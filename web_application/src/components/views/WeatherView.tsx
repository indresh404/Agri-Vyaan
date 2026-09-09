import React, { useState } from 'react';
import type { WeatherForecast } from '../../types';

interface WeatherViewProps {
  weather: WeatherForecast[];
}

export const WeatherView: React.FC<WeatherViewProps> = ({ weather }) => {
  const [selectedDay, setSelectedDay] = useState<number>(0);
  const today = weather[0];
  const selected = weather[selectedDay];

  const getSprayColor = (condition: string) => {
    if (condition === 'GOOD') return { bg: '#EBF0E9', text: '#30432E', border: 'rgba(79, 104, 72, 0.4)' };
    if (condition === 'MODERATE') return { bg: '#FEF5E4', text: '#B8862D', border: 'rgba(184, 134, 45, 0.4)' };
    return { bg: '#FAEAE9', text: '#B64A43', border: 'rgba(182, 74, 67, 0.4)' };
  };

  const getWeatherIcon = (condition: string) => {
    if (condition === 'Sunny') return '☀';
    if (condition === 'Rainy') return '🌧';
    if (condition === 'Cloudy' || condition === 'Overcast') return '☁';
    return '⛅';
  };

  const sprayColors = getSprayColor(today.sprayingCondition);

  return (
    <div style={{ padding: '20px 24px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
      {/* Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 style={{ fontSize: '22px', fontWeight: 700, color: '#20231F', margin: 0 }}>
            Weather & Spraying Conditions
          </h1>
          <p style={{ fontSize: '13px', color: '#6B7068', marginTop: '2px' }}>
            6-day operational weather forecast with spray window advisory.
          </p>
        </div>
        <div style={{ fontSize: '11px', color: '#6B7068', textAlign: 'right' }}>
          <div style={{ fontWeight: 600, color: '#20231F' }}>Thane, Maharashtra</div>
          <div>27 Aug 2026 · 05:30 IST</div>
        </div>
      </div>

      {/* Today's Summary Strip */}
      <div style={{
        display: 'grid',
        gridTemplateColumns: '1fr 1fr 1fr',
        gap: '12px'
      }}>
        {/* Temperature */}
        <div style={{
          backgroundColor: '#FFFFFF',
          border: '1px solid #DDDED7',
          borderRadius: '4px',
          padding: '16px'
        }}>
          <div style={{ fontSize: '11px', fontWeight: 600, color: '#6B7068', textTransform: 'uppercase', marginBottom: '8px' }}>
            Today · Temperature
          </div>
          <div style={{ fontSize: '36px', fontWeight: 700, color: '#20231F', lineHeight: 1 }}>
            {today.temperature}°C
          </div>
          <div style={{ fontSize: '12px', color: '#6B7068', marginTop: '4px' }}>
            {today.weatherCondition} · Wind {today.windSpeed} km/h
          </div>
        </div>

        {/* Spray Condition */}
        <div style={{
          backgroundColor: sprayColors.bg,
          border: `1px solid ${sprayColors.border}`,
          borderRadius: '4px',
          padding: '16px'
        }}>
          <div style={{ fontSize: '11px', fontWeight: 600, color: '#6B7068', textTransform: 'uppercase', marginBottom: '8px' }}>
            Spray Window Condition
          </div>
          <div style={{ fontSize: '24px', fontWeight: 700, color: sprayColors.text, lineHeight: 1 }}>
            {today.sprayingCondition}
          </div>
          <div style={{ fontSize: '12px', color: sprayColors.text, marginTop: '4px', opacity: 0.8 }}>
            Best window: {today.bestWindow}
          </div>
        </div>

        {/* Humidity / Rain */}
        <div style={{
          backgroundColor: '#FFFFFF',
          border: '1px solid #DDDED7',
          borderRadius: '4px',
          padding: '16px'
        }}>
          <div style={{ fontSize: '11px', fontWeight: 600, color: '#6B7068', textTransform: 'uppercase', marginBottom: '8px' }}>
            Humidity & Rainfall Risk
          </div>
          <div style={{ display: 'flex', gap: '16px' }}>
            <div>
              <div style={{ fontSize: '20px', fontWeight: 700, color: '#55758A' }}>{today.humidity}%</div>
              <div style={{ fontSize: '11px', color: '#6B7068' }}>Humidity</div>
            </div>
            <div>
              <div style={{ fontSize: '20px', fontWeight: 700, color: today.rainProbability > 50 ? '#B64A43' : '#20231F' }}>
                {today.rainProbability}%
              </div>
              <div style={{ fontSize: '11px', color: '#6B7068' }}>Rain Risk</div>
            </div>
          </div>
        </div>
      </div>

      {/* 6-Day Forecast Strip */}
      <div className="op-table-container" style={{ padding: '12px 0' }}>
        <div style={{ fontSize: '11px', fontWeight: 700, color: '#6B7068', textTransform: 'uppercase', marginBottom: '10px', padding: '0 14px' }}>
          6-Day Forecast
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(6, 1fr)', gap: '0', borderTop: '1px solid #EBECE6' }}>
          {weather.map((day, idx) => {
            const isSelected = idx === selectedDay;
            const colors = getSprayColor(day.sprayingCondition);
            return (
              <button
                key={idx}
                onClick={() => setSelectedDay(idx)}
                style={{
                  padding: '12px 8px',
                  borderRight: idx < weather.length - 1 ? '1px solid #EBECE6' : 'none',
                  backgroundColor: isSelected ? '#FAFBF8' : 'transparent',
                  borderBottom: isSelected ? '2px solid #4F6848' : '2px solid transparent',
                  textAlign: 'center',
                  cursor: 'pointer'
                }}
              >
                <div style={{ fontSize: '11px', fontWeight: 600, color: '#6B7068' }}>{day.dayName}</div>
                <div style={{ fontSize: '11px', color: '#6B7068', marginBottom: '6px' }}>{day.date}</div>
                <div style={{ fontSize: '22px', lineHeight: 1, marginBottom: '6px' }}>{getWeatherIcon(day.weatherCondition)}</div>
                <div style={{ fontSize: '14px', fontWeight: 700, color: '#20231F' }}>{day.temperature}°C</div>
                <div style={{
                  marginTop: '6px',
                  fontSize: '9px',
                  fontWeight: 700,
                  color: colors.text,
                  backgroundColor: colors.bg,
                  padding: '2px 4px',
                  borderRadius: '3px'
                }}>
                  {day.sprayingCondition}
                </div>
              </button>
            );
          })}
        </div>
      </div>

      {/* Selected Day Detail */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
        {/* Conditions Card */}
        <div style={{
          backgroundColor: '#FFFFFF',
          border: '1px solid #DDDED7',
          borderRadius: '4px',
          padding: '16px'
        }}>
          <div style={{ fontSize: '13px', fontWeight: 700, color: '#20231F', marginBottom: '14px', borderBottom: '1px solid #EBECE6', paddingBottom: '8px' }}>
            {selected.dayName} · {selected.date} — Conditions
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px', fontSize: '13px' }}>
            {[
              ['Temperature',  `${selected.temperature}°C`],
              ['Rain Probability', `${selected.rainProbability}%`],
              ['Humidity',     `${selected.humidity}%`],
              ['Wind Speed',   `${selected.windSpeed} km/h`],
              ['Weather',      selected.weatherCondition],
              ['Best Spray Window', selected.bestWindow]
            ].map(([label, value]) => (
              <div key={label} style={{ display: 'flex', justifyContent: 'space-between' }}>
                <span style={{ color: '#6B7068' }}>{label}</span>
                <span style={{ fontWeight: 600, color: '#20231F' }}>{value}</span>
              </div>
            ))}
          </div>
        </div>

        {/* AI Advisory */}
        <div style={{
          backgroundColor: '#FFFFFF',
          border: '1px solid #DDDED7',
          borderRadius: '4px',
          padding: '16px'
        }}>
          <div style={{ fontSize: '13px', fontWeight: 700, color: '#20231F', marginBottom: '14px', borderBottom: '1px solid #EBECE6', paddingBottom: '8px' }}>
            Operational Advisory
          </div>

          {/* Spray Badge */}
          <div style={{
            backgroundColor: getSprayColor(selected.sprayingCondition).bg,
            border: `1px solid ${getSprayColor(selected.sprayingCondition).border}`,
            borderRadius: '4px',
            padding: '10px 12px',
            marginBottom: '12px'
          }}>
            <div style={{ fontSize: '11px', fontWeight: 700, color: '#6B7068', textTransform: 'uppercase' }}>Spray Condition</div>
            <div style={{ fontSize: '18px', fontWeight: 700, color: getSprayColor(selected.sprayingCondition).text, marginTop: '2px' }}>
              {selected.sprayingCondition}
            </div>
          </div>

          {/* Summary */}
          <div style={{ fontSize: '12px', color: '#20231F', lineHeight: 1.5 }}>
            {selected.aiSummary}
          </div>

          {/* Quick Tips */}
          <div style={{ marginTop: '14px', borderTop: '1px solid #EBECE6', paddingTop: '12px' }}>
            <div style={{ fontSize: '11px', fontWeight: 600, color: '#6B7068', textTransform: 'uppercase', marginBottom: '8px' }}>
              Cultivation Tips
            </div>
            {[
              'Apply nitrogen in split doses to minimize run-off loss.',
              'Drip irrigation saves up to 40% water vs flood irrigation.',
              'Rotate cereal crops with legumes to fix soil nitrogen.',
            ].map((tip, i) => (
              <div key={i} style={{ display: 'flex', gap: '8px', marginBottom: '6px', fontSize: '12px', color: '#6B7068' }}>
                <span style={{ color: '#B8862D', flexShrink: 0 }}>•</span>
                <span>{tip}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};
