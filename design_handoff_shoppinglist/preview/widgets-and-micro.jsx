// widgets-and-micro.jsx — Home screen widgets (iOS small/medium/large + Android) + micro-interactions

const WIDGET_ITEMS = [
  { name: '牛乳 1L', cat: '#E8B547', checked: false },
  { name: 'トマト 4個', cat: '#6BAA5E', checked: false },
  { name: '卵 10個入り', cat: '#E8B547', checked: true },
  { name: '豚バラ 300g', cat: '#C05757', checked: false },
  { name: '食パン 6枚', cat: '#B98A4C', checked: true },
  { name: 'コーヒー豆', cat: '#5A8AB5', checked: false },
  { name: '玉ねぎ 大1袋', cat: '#6BAA5E', checked: false },
  { name: '猫砂', cat: '#8A8275', checked: false },
  { name: 'バナナ', cat: '#6BAA5E', checked: false },
  { name: 'ヨーグルト', cat: '#E8B547', checked: false },
];

function IOSWidget({ size = 'medium', t, accent = '#C2410C' }) {
  const dims = { small: 158, medium: 338, large: 354 };
  const w = dims[size];
  const h = size === 'large' ? 354 : (size === 'medium' ? 158 : 158);
  const cap = size === 'large' ? 10 : 4;
  const items = WIDGET_ITEMS.slice(0, cap);
  const total = WIDGET_ITEMS.length;
  const done = WIDGET_ITEMS.filter(i => i.checked).length;
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 10, alignItems: 'center' }}>
      <div className="mono" style={{ fontSize: 10, color: '#5A5246', fontWeight: 600, letterSpacing: 0.4, textTransform: 'uppercase' }}>
        iOS · {size}
      </div>
      <div style={{
        width: w, height: h, borderRadius: 22, padding: 14,
        background: '#FFFCF3', boxSizing: 'border-box', position: 'relative',
        boxShadow: '0 12px 30px rgba(27,24,19,0.14), 0 0 0 1px rgba(27,24,19,0.08)',
        fontFamily: '"Noto Sans JP", system-ui',
      }}>
        {/* header */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 8 }}>
          <div style={{
            width: 18, height: 18, borderRadius: 5, background: accent, color: '#fff',
            display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 11,
          }}>
            <Icon name="cart" size={11} stroke="#fff" sw={2.2}/>
          </div>
          <div style={{ fontSize: 11.5, fontWeight: 700, color: '#1B1813', flex: 1, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
            うちの買い物
          </div>
          <div className="mono" style={{ fontSize: 10, color: '#8A8275', fontWeight: 500 }}>
            {done}/{total}
          </div>
        </div>
        {/* items */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: size === 'large' ? 8 : 6 }}>
          {items.map((it, i) => (
            <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 7 }}>
              <div style={{
                width: 14, height: 14, borderRadius: 14,
                border: it.checked ? `2px solid ${accent}` : `1.5px solid #BDB39E`,
                background: it.checked ? accent : 'transparent', flexShrink: 0,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                {it.checked && <Icon name="check" size={9} stroke="#fff" sw={3}/>}
              </div>
              {it.cat && <span style={{ width: 5, height: 5, borderRadius: 5, background: it.cat, flexShrink: 0 }}/>}
              <span style={{
                fontSize: size === 'small' ? 11.5 : 12,
                color: it.checked ? '#A89E89' : '#1B1813',
                fontWeight: 500, flex: 1, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap',
                textDecoration: it.checked ? 'line-through' : 'none',
                textDecorationColor: '#BDB39E',
              }}>{it.name}</span>
            </div>
          ))}
          {total > cap && (
            <div style={{ fontSize: 10.5, color: '#8A8275', fontWeight: 500, marginTop: 2 }}>
              他 {total - cap} 件
            </div>
          )}
        </div>
        {/* progress sliver bottom */}
        <div style={{
          position: 'absolute', left: 14, right: 14, bottom: 12, height: 2.5,
          background: '#EBE2C9', borderRadius: 3, overflow: 'hidden',
        }}>
          <div style={{ height: '100%', width: `${(done / total) * 100}%`, background: accent }}/>
        </div>
      </div>
    </div>
  );
}

function AndroidWidget({ accent = '#C2410C', label = 'Android · 4×2' }) {
  const items = WIDGET_ITEMS.slice(0, 5);
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 10, alignItems: 'center' }}>
      <div className="mono" style={{ fontSize: 10, color: '#5A5246', fontWeight: 600, letterSpacing: 0.4, textTransform: 'uppercase' }}>{label}</div>
      <div style={{
        width: 320, height: 200, borderRadius: 24, background: '#F6F0E2',
        padding: 14, boxSizing: 'border-box', boxShadow: '0 8px 20px rgba(27,24,19,0.12)',
        fontFamily: '"Noto Sans JP", system-ui', position: 'relative',
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 10 }}>
          <Icon name="agenda" size={16} stroke="#1B1813"/>
          <div style={{ fontSize: 13, fontWeight: 700, color: '#1B1813', flex: 1 }}>うちの買い物</div>
          <span className="mono" style={{ fontSize: 11, color: '#8A8275', fontWeight: 500 }}>2/10</span>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 7 }}>
          {items.map((it, i) => (
            <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <span className="mono" style={{
                fontSize: 13, color: it.checked ? '#A89E89' : '#1B1813', fontWeight: 700,
              }}>{it.checked ? '☑' : '☐'}</span>
              <span style={{
                fontSize: 13, color: it.checked ? '#A89E89' : '#1B1813',
                textDecoration: it.checked ? 'line-through' : 'none',
                fontWeight: 500,
              }}>{it.name}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

// ───────── Micro-interactions ─────────

function MicroEnterFlow({ t }) {
  const steps = [
    { ph: 'けいせ', line2: '', state: 1 },
    { ph: '鶏むね', line2: '', state: 2 },
    { ph: '鶏むね 300g', line2: '', state: 3 },
    { ph: '鶏むね 300g', line2: '|', state: 4 },
    { ph: '鶏むね 300g', line2: 'もやし 1袋', state: 5 },
  ];
  return (
    <MicroFrame t={t} title="連続入力" sub="行 = TextField · return で次の空行へ">
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(5, 1fr)', gap: 8 }}>
        {steps.map((s, i) => (
          <div key={i} style={{ background: t.card, borderRadius: 12, overflow: 'hidden', border: `1px solid ${t.divider}` }}>
            <div className="mono" style={{ fontSize: 9, color: t.ink3, padding: '6px 10px', borderBottom: `1px solid ${t.divider}` }}>
              {String(i + 1).padStart(2, '0')}
            </div>
            <div style={{ padding: 10, display: 'flex', flexDirection: 'column', gap: 6 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                <Checkbox t={t} size={14}/>
                <span style={{ fontSize: 11.5, color: t.ink, fontWeight: 500 }}>
                  {s.ph}
                  {i < 4 && <span className="fake-caret"/>}
                </span>
              </div>
              {s.line2 !== '' || s.state === 5 ? (
                <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                  <Checkbox t={t} size={14}/>
                  <span style={{ fontSize: 11.5, color: s.line2 === '|' ? t.ink3 : t.ink, fontWeight: 500 }}>
                    {s.line2 === '|' ? <span className="fake-caret"/> : s.line2}
                    {s.state === 5 && <span className="fake-caret"/>}
                  </span>
                </div>
              ) : null}
            </div>
            <div style={{
              fontSize: 9, padding: '4px 10px 6px', color: t.ink3,
              borderTop: `1px solid ${t.divider2}`, background: t.surface2,
            }}>
              {['入力中', 'IME 確定', '量を追記', 'return', '次行へ'][i]}
            </div>
          </div>
        ))}
      </div>
    </MicroFrame>
  );
}

function MicroCheckFeedback({ t }) {
  const states = [
    { c: false, scale: 1, ring: 0 },
    { c: false, scale: 0.9, ring: 0 },
    { c: true, scale: 1.18, ring: 0.5 },
    { c: true, scale: 1.05, ring: 0.25 },
    { c: true, scale: 1, ring: 0 },
  ];
  return (
    <MicroFrame t={t} title="チェックの手応え" sub="スケールパルス + 細い波紋 (200ms)">
      <div style={{ display: 'flex', gap: 18, alignItems: 'center', justifyContent: 'space-around', padding: '10px 0' }}>
        {states.map((s, i) => (
          <div key={i} style={{ textAlign: 'center' }}>
            <div style={{ position: 'relative', width: 40, height: 40, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              {s.ring > 0 && (
                <div style={{
                  position: 'absolute', inset: -4, borderRadius: 999,
                  border: `2px solid ${t.accent}`, opacity: s.ring,
                }}/>
              )}
              <div style={{ transform: `scale(${s.scale})`, transition: 'transform 100ms' }}>
                <Checkbox t={t} checked={s.c} size={26}/>
              </div>
            </div>
            <div className="mono" style={{ fontSize: 9.5, color: t.ink3, marginTop: 4 }}>{i * 50}ms</div>
          </div>
        ))}
      </div>
    </MicroFrame>
  );
}

function MicroAIProgress({ t }) {
  return (
    <MicroFrame t={t} title="画像 / URL からアイテム生成" sub="処理中バナーと候補プレビュー">
      <div style={{
        display: 'flex', alignItems: 'center', gap: 10, padding: 10,
        background: t.accentSoft, borderRadius: 10,
      }}>
        <div style={{
          width: 32, height: 32, borderRadius: 8, background: '#fff',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }} className="stripe-ph"/>
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 11, fontWeight: 700, color: t.dark ? t.accentInk : t.accent, display: 'flex', alignItems: 'center', gap: 4 }}>
            <Icon name="wand" size={11}/>レシート画像から抽出中
          </div>
          <div style={{ height: 2, background: 'rgba(255,255,255,0.5)', borderRadius: 2, overflow: 'hidden', marginTop: 4 }}>
            <div style={{ height: '100%', width: '62%', background: t.accent, borderRadius: 2 }}/>
          </div>
        </div>
        <span className="mono" style={{ fontSize: 10, color: t.accent, fontWeight: 600 }}>62%</span>
      </div>
      <div style={{ marginTop: 8, display: 'flex', flexDirection: 'column', gap: 4 }}>
        {['牛乳 1L', '食パン 6枚切', '卵 10個', '+ 4 件をプレビュー'].map((n, i) => (
          <div key={i} style={{
            display: 'flex', alignItems: 'center', gap: 6, padding: '4px 6px',
            background: i === 3 ? 'transparent' : t.surface2,
            borderRadius: 6, fontSize: 11, color: i === 3 ? t.accent : t.ink, fontWeight: i === 3 ? 600 : 400,
          }}>
            {i < 3 && <Checkbox t={t} size={14}/>}
            {i === 3 && <Icon name="chev-r" size={12} stroke={t.accent}/>}
            <span>{n}</span>
            {i < 3 && <span className="mono" style={{ marginLeft: 'auto', fontSize: 9, color: t.ok, background: t.okSoft, padding: '0 6px', borderRadius: 4, fontWeight: 700 }}>NEW</span>}
          </div>
        ))}
      </div>
    </MicroFrame>
  );
}

function MicroNotifySnack({ t }) {
  return (
    <MicroFrame t={t} title="メンバー通知 SnackBar" sub="アイテム変更後 ・ 全員/個別に通知できる">
      <div style={{
        background: t.ink, color: t.surface, borderRadius: 12, padding: '10px 12px',
        display: 'flex', alignItems: 'center', gap: 10,
      }}>
        <Icon name="bell" size={14} stroke={t.surface}/>
        <div style={{ flex: 1, fontSize: 11.5, fontWeight: 500 }}>
          <div>「みかん 1袋」を追加しました</div>
          <div style={{ fontSize: 10, opacity: 0.7 }}>誰に伝えますか?</div>
        </div>
        <div style={{ display: 'flex' }}>
          {['M','O','A'].map((m, i) => (
            <div key={i} style={{
              width: 22, height: 22, borderRadius: 999,
              background: ['#C2410C','#1F6B4E','#0F4C81'][i], color: '#fff',
              fontSize: 9, fontWeight: 700, display: 'flex', alignItems: 'center', justifyContent: 'center',
              border: `1.5px solid ${t.ink}`, marginLeft: i ? -6 : 0, fontFamily: 'IBM Plex Mono',
            }}>{m}</div>
          ))}
        </div>
        <button style={{
          background: t.accent, color: '#fff', border: 'none', borderRadius: 999,
          padding: '4px 10px', fontWeight: 700, fontSize: 10.5,
        }}>全員</button>
      </div>
    </MicroFrame>
  );
}

function MicroFrame({ t, title, sub, children }) {
  return (
    <div style={{
      background: t.paper, borderRadius: 18, padding: 16,
      border: `1px solid ${t.divider}`,
    }}>
      <div className="mono" style={{ fontSize: 10, color: t.ink3, fontWeight: 600, letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 4 }}>
        マイクロインタラクション
      </div>
      <div style={{ fontSize: 15, fontWeight: 700, color: t.ink, marginBottom: 2 }}>{title}</div>
      <div style={{ fontSize: 11.5, color: t.ink2, marginBottom: 14 }}>{sub}</div>
      {children}
    </div>
  );
}

Object.assign(window, {
  IOSWidget, AndroidWidget, WIDGET_ITEMS,
  MicroEnterFlow, MicroCheckFeedback, MicroAIProgress, MicroNotifySnack, MicroFrame,
});
