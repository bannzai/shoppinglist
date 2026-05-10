// frame.jsx — custom phone frames (lighter than starter; matches our aesthetic)

function StatusBar({ dark, time = '9:41', invert = false }) {
  const c = invert ? '#fff' : (dark ? '#fff' : '#1B1813');
  return (
    <div style={{
      position: 'absolute', top: 0, left: 0, right: 0, height: 44,
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '14px 28px 0', zIndex: 30, pointerEvents: 'none',
    }}>
      <span style={{ fontWeight: 600, fontSize: 15, color: c, letterSpacing: -0.2 }}>{time}</span>
      <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
        <svg width="17" height="11" viewBox="0 0 17 11"><path d="M.5 8h2v2.5H.5zm4-2h2v4.5h-2zm4-2.5h2V10.5h-2zm4-2.5h2v9.5h-2z" fill={c}/></svg>
        <svg width="15" height="11" viewBox="0 0 15 11"><path d="M7.5 1A11 11 0 0 0 0 4l1.5 1.5a9 9 0 0 1 12 0L15 4A11 11 0 0 0 7.5 1zm0 3A7.5 7.5 0 0 0 2.5 6L4 7.5a5.4 5.4 0 0 1 7 0L12.5 6A7.5 7.5 0 0 0 7.5 4zm0 3A4 4 0 0 0 5 8l2.5 2.5L10 8a4 4 0 0 0-2.5-1z" fill={c}/></svg>
        <svg width="25" height="11" viewBox="0 0 25 11"><rect x="0.5" y="0.5" width="21" height="10" rx="2.5" fill="none" stroke={c} strokeOpacity="0.45"/><rect x="2" y="2" width="18" height="7" rx="1.2" fill={c}/><path d="M22.5 3.5v4c.7-.3 1.2-1 1.2-2s-.5-1.7-1.2-2z" fill={c} fillOpacity="0.55"/></svg>
      </div>
    </div>
  );
}

function Phone({ children, w = 390, h = 844, bg = '#F8F2E2', dark = false, label, sublabel, invert = false }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 10, alignItems: 'flex-start' }}>
      {label && (
        <div style={{ fontSize: 11, letterSpacing: 0.5, textTransform: 'uppercase', color: '#5A5246', fontFamily: 'IBM Plex Mono, monospace', fontWeight: 500 }}>
          {label}{sublabel && <span style={{ color: '#948A77', marginLeft: 8, textTransform: 'none', letterSpacing: 0 }}>— {sublabel}</span>}
        </div>
      )}
      <div style={{
        width: w, height: h, borderRadius: 44,
        position: 'relative', overflow: 'hidden',
        background: bg,
        boxShadow: '0 0 0 1.5px rgba(27,24,19,0.18), 0 30px 60px rgba(27,24,19,0.12), 0 60px 120px rgba(27,24,19,0.06)',
        fontFamily: '"Noto Sans JP", system-ui, sans-serif',
      }}>
        {/* dynamic island */}
        <div style={{
          position: 'absolute', top: 11, left: '50%', transform: 'translateX(-50%)',
          width: 120, height: 34, borderRadius: 22, background: '#0a0805', zIndex: 40,
        }} />
        <StatusBar dark={dark} invert={invert} />
        <div style={{ width: '100%', height: '100%', position: 'relative', zIndex: 1 }}>{children}</div>
        {/* home indicator */}
        <div style={{
          position: 'absolute', bottom: 8, left: 0, right: 0, height: 5,
          display: 'flex', justifyContent: 'center', zIndex: 50, pointerEvents: 'none',
        }}>
          <div style={{
            width: 134, height: 5, borderRadius: 100,
            background: invert ? 'rgba(255,255,255,0.85)' : (dark ? 'rgba(255,255,255,0.7)' : 'rgba(27,24,19,0.32)'),
          }} />
        </div>
      </div>
    </div>
  );
}

// Compact app bar (used inside Phone content)
function AppBar({ title, leading, trailing, dark, t, large = false, subtitle, sticky = true, accent = false, bg }) {
  const ink = t.ink;
  return (
    <div style={{
      position: sticky ? 'sticky' : 'relative', top: 0, zIndex: 5,
      background: bg || t.surface,
      borderBottom: `0.5px solid ${t.divider}`,
      paddingTop: 44,
    }}>
      <div style={{
        height: large ? 52 : 48, display: 'flex', alignItems: 'center',
        padding: '0 8px',
      }}>
        <div style={{ width: 44, display: 'flex', justifyContent: 'flex-start' }}>{leading}</div>
        {!large && <div style={{ flex: 1, textAlign: 'center', fontWeight: 600, fontSize: 17, color: ink, letterSpacing: -0.01 }}>{title}</div>}
        {large && <div style={{ flex: 1 }} />}
        <div style={{ width: 44, display: 'flex', justifyContent: 'flex-end' }}>{trailing}</div>
      </div>
      {large && (
        <div style={{ padding: '4px 20px 14px' }}>
          <div style={{ fontSize: 28, fontWeight: 700, color: ink, letterSpacing: -0.02, lineHeight: 1.15 }}>{title}</div>
          {subtitle && <div style={{ fontSize: 13, color: t.ink2, marginTop: 4 }}>{subtitle}</div>}
        </div>
      )}
    </div>
  );
}

// Tab bar (bottom)
function TabBar({ active = 'list', t, onTab }) {
  const items = [
    { id: 'list', icon: 'cart', label: '買い物リスト' },
    { id: 'settings', icon: 'gear', label: '設定' },
  ];
  return (
    <div style={{
      position: 'absolute', bottom: 0, left: 0, right: 0,
      paddingTop: 6, paddingBottom: 28,
      background: t.surface, borderTop: `0.5px solid ${t.divider}`,
      display: 'flex', zIndex: 20,
    }}>
      {items.map(it => {
        const a = it.id === active;
        return (
          <div key={it.id} style={{
            flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 3,
            color: a ? t.accent : t.ink3, padding: '6px 0',
          }}>
            <Icon name={it.icon} size={22} sw={a ? 2 : 1.7}/>
            <div style={{ fontSize: 10.5, fontWeight: a ? 600 : 500, letterSpacing: 0.02 }}>{it.label}</div>
          </div>
        );
      })}
    </div>
  );
}

// Pill button
function Pill({ children, onClick, t, soft, accent, danger, ghost, lg, style, icon, disabled }) {
  let bg = t.surface2, fg = t.ink, bd = `1px solid ${t.divider}`;
  if (accent) { bg = t.accent; fg = '#fff'; bd = 'none'; }
  else if (soft) { bg = t.accentSoft; fg = t.dark ? t.accentInk : t.accent; bd = 'none'; }
  else if (danger) { bg = t.dangerSoft; fg = t.danger; bd = 'none'; }
  else if (ghost) { bg = 'transparent'; bd = `1px solid ${t.divider}`; }
  return (
    <button onClick={onClick} disabled={disabled} style={{
      display: 'inline-flex', alignItems: 'center', gap: 6, justifyContent: 'center',
      height: lg ? 50 : 36, padding: lg ? '0 24px' : '0 14px',
      borderRadius: 999, background: bg, color: fg, border: bd,
      fontFamily: 'inherit', fontWeight: 600, fontSize: lg ? 15 : 13.5, cursor: 'pointer',
      letterSpacing: -0.005, opacity: disabled ? 0.5 : 1,
      ...style,
    }}>
      {icon && <Icon name={icon} size={lg ? 18 : 16}/>}
      {children}
    </button>
  );
}

// Round icon button
function RoundBtn({ name, t, soft, onClick, size = 36, icon = 18, sw = 1.7, color, bg, ring }) {
  return (
    <button onClick={onClick} style={{
      width: size, height: size, borderRadius: size,
      background: bg || (soft ? t.accentSoft : 'transparent'),
      color: color || (soft ? t.accent : t.ink),
      border: ring ? `1px solid ${t.divider}` : 'none',
      display: 'inline-flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer',
    }}>
      <Icon name={name} size={icon} sw={sw}/>
    </button>
  );
}

// Round checkbox (the heart of the list)
function Checkbox({ checked, t, size = 22, color }) {
  const fill = color || t.accent;
  return (
    <div style={{
      width: size, height: size, borderRadius: size,
      border: checked ? `1.5px solid ${fill}` : `1.5px solid ${t.ink4}`,
      background: checked ? fill : 'transparent',
      display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
      flexShrink: 0, transition: 'all 120ms',
    }}>
      {checked && <Icon name="check" size={size * 0.62} stroke="#fff" sw={2.4}/>}
    </div>
  );
}

// Chip
function Chip({ children, t, active, icon, soft, onClick, dot }) {
  return (
    <button onClick={onClick} style={{
      display: 'inline-flex', alignItems: 'center', gap: 6,
      height: 30, padding: '0 12px', borderRadius: 999,
      whiteSpace: 'nowrap', flexShrink: 0, flexGrow: 0, width: 'auto',
      background: active ? (soft ? t.accentSoft : t.ink) : t.surface,
      color: active ? (soft ? t.accent : (t.dark ? t.surface : '#fff')) : t.ink2,
      border: active ? 'none' : `1px solid ${t.divider}`,
      fontFamily: 'inherit', fontWeight: active ? 600 : 500, fontSize: 12.5, cursor: 'pointer',
      letterSpacing: -0.005,
    }}>
      {dot && <span style={{ width: 7, height: 7, borderRadius: 7, background: dot }}/>}
      {icon && <Icon name={icon} size={14}/>}
      {children}
    </button>
  );
}

Object.assign(window, { Phone, AppBar, TabBar, Pill, RoundBtn, Checkbox, Chip, StatusBar });
