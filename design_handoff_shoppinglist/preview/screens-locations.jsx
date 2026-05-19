// screens-locations.jsx — Shopping locations(13), Location picker(14)

function ShoppingLocationPage({ t, state = 'list' }) {
  const places = [
    { id: 1, name: 'イオン藤沢店', sub: '位置情報を設定済み · 200m圏内で通知', hasGeo: true },
    { id: 2, name: 'マルエツ プチ', sub: '位置情報を設定済み', hasGeo: true },
    { id: 3, name: '近所のドラッグストア', sub: '位置情報なし', hasGeo: false },
  ];
  return (
    <div style={{ background: t.paper, height: '100%', overflow: 'auto', position: 'relative' }}>
      <AppBar title="買い物する場所" t={t} leading={<RoundBtn name="chev-l" t={t}/>}/>
      <div style={{ padding: '14px 16px 100px', display: 'flex', flexDirection: 'column', gap: 12 }}>
        <div style={{ fontSize: 12, color: t.ink2, padding: '0 4px', lineHeight: 1.6 }}>
          場所を登録するとリストに紐付けられます。位置情報を設定すれば、お店の近くで通知できます。
        </div>
        {state === 'empty' ? (
          <div style={{
            padding: '40px 24px', background: t.surface2, borderRadius: 16, border: `1px dashed ${t.divider}`,
            textAlign: 'center', color: t.ink2,
          }}>
            <Icon name="store" size={36} stroke={t.ink3}/>
            <div style={{ fontSize: 14, marginTop: 10, fontWeight: 600, color: t.ink }}>買い物する場所がまだありません</div>
            <div style={{ fontSize: 12, marginTop: 4 }}>右下の + から追加できます</div>
          </div>
        ) : (
          <div style={{ background: t.card, borderRadius: 14, overflow: 'hidden' }}>
            {places.map((p, i) => (
              <React.Fragment key={p.id}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '14px 16px' }}>
                  <div style={{
                    width: 36, height: 36, borderRadius: 10, background: p.hasGeo ? t.accentSoft : t.surface2,
                    color: p.hasGeo ? t.accent : t.ink3,
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                  }}>
                    <Icon name={p.hasGeo ? 'pin-fill' : 'store'} size={18}/>
                  </div>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ fontSize: 14.5, color: t.ink, fontWeight: 600 }}>{p.name}</div>
                    <div style={{ fontSize: 11.5, color: t.ink3, marginTop: 2 }}>{p.sub}</div>
                  </div>
                  <button style={{ background: 'transparent', border: 'none', color: t.ink3, padding: 4 }}>
                    <Icon name="edit" size={16}/>
                  </button>
                  <button style={{ background: 'transparent', border: 'none', color: t.ink3, padding: 4 }}>
                    <Icon name="trash" size={16}/>
                  </button>
                </div>
                {i < places.length - 1 && <Divider t={t} inset={64}/>}
              </React.Fragment>
            ))}
          </div>
        )}
      </div>
      <div style={{ position: 'absolute', right: 16, bottom: 36 }}>
        <button style={{
          width: 56, height: 56, borderRadius: 999, background: t.accent, color: '#fff', border: 'none',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          boxShadow: '0 6px 14px rgba(194,65,12,0.3)',
        }}><Icon name="plus" size={24} sw={2.2}/></button>
      </div>
      {state === 'add' && <AddLocationDialog t={t}/>}
    </div>
  );
}

function AddLocationDialog({ t }) {
  return (
    <DialogShell t={t}>
      <div style={{ padding: '20px 20px 4px' }}>
        <div style={{ fontSize: 16, fontWeight: 700, color: t.ink, marginBottom: 12 }}>場所を追加</div>
        <div style={{ background: t.surface2, borderRadius: 12, padding: '12px 14px', marginBottom: 10 }}>
          <div style={{ fontSize: 11, color: t.ink3, fontWeight: 600, marginBottom: 4 }}>場所の名前</div>
          <input placeholder="例: イオン藤沢店" style={{
            width: '100%', border: 'none', background: 'transparent', outline: 'none',
            fontFamily: 'inherit', fontSize: 16, color: t.ink,
          }}/>
        </div>
        <button style={{
          width: '100%', padding: '12px 14px', background: t.surface2, border: `1px dashed ${t.divider}`,
          borderRadius: 12, display: 'flex', alignItems: 'center', gap: 10, fontFamily: 'inherit', cursor: 'pointer',
        }}>
          <Icon name="pin" size={18} stroke={t.ink2}/>
          <div style={{ flex: 1, textAlign: 'left' }}>
            <div style={{ fontSize: 13.5, color: t.ink, fontWeight: 600 }}>地図で場所を設定</div>
            <div style={{ fontSize: 11, color: t.ink3 }}>近くで通知できるようになります</div>
          </div>
          <span style={{ fontSize: 10.5, padding: '2px 6px', borderRadius: 4, background: t.accent, color: '#fff', fontWeight: 700 }}>PRO</span>
        </button>
      </div>
      <div style={{ display: 'flex', gap: 8, padding: 16 }}>
        <Pill t={t} ghost lg style={{ flex: 1 }}>キャンセル</Pill>
        <Pill t={t} accent lg style={{ flex: 1 }}>追加</Pill>
      </div>
    </DialogShell>
  );
}

function LocationPickerPage({ t, state = 'idle' }) {
  return (
    <div style={{ background: '#E8E0D0', height: '100%', position: 'relative', overflow: 'hidden' }}>
      <AppBar title="場所を地図で選択" t={t} leading={<RoundBtn name="chev-l" t={t}/>} bg={t.surface}/>
      {/* Map */}
      <div style={{ position: 'absolute', top: 92, left: 0, right: 0, bottom: 200, overflow: 'hidden' }}>
        <MapBg t={t}/>
        {/* Center pin */}
        <div style={{
          position: 'absolute', left: '50%', top: '50%', transform: 'translate(-50%, -100%)',
          filter: 'drop-shadow(0 4px 6px rgba(0,0,0,0.3))',
        }}>
          <Icon name="pin-fill" size={42} stroke={t.accent}/>
        </div>
        {/* Crosshair button */}
        <div style={{
          position: 'absolute', right: 16, bottom: 16, width: 44, height: 44, borderRadius: 999,
          background: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center',
          boxShadow: '0 4px 10px rgba(0,0,0,0.18)',
        }}>
          <Icon name="crosshair" size={22} stroke={t.accent}/>
        </div>
      </div>
      {/* Bottom card */}
      <div style={{
        position: 'absolute', left: 16, right: 16, bottom: 36,
        background: t.card, borderRadius: 18, padding: 16,
        boxShadow: '0 -4px 30px rgba(0,0,0,0.1)',
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 6 }}>
          <Icon name="pin" size={16} stroke={t.accent}/>
          <span style={{ fontSize: 11, fontWeight: 700, color: t.ink2, letterSpacing: 0.05, textTransform: 'uppercase' }}>選択中の場所</span>
        </div>
        {state === 'loading' ? (
          <>
            <div className="stripe-ph" style={{ height: 14, width: '70%', borderRadius: 4, marginBottom: 6 }}/>
            <div className="stripe-ph" style={{ height: 11, width: '50%', borderRadius: 4 }}/>
            <div style={{ height: 3, background: t.divider2, borderRadius: 3, overflow: 'hidden', marginTop: 12 }}>
              <div style={{ height: '100%', width: '40%', background: t.accent }}/>
            </div>
          </>
        ) : (
          <>
            <div style={{ fontSize: 15, fontWeight: 600, color: t.ink, lineHeight: 1.4 }}>
              神奈川県藤沢市辻堂神台1丁目3
            </div>
            <div style={{ fontSize: 12, color: t.ink3, marginTop: 2 }}>イオン藤沢店 付近</div>
          </>
        )}
        <Pill t={t} accent lg style={{ width: '100%', marginTop: 14 }}>この場所を設定</Pill>
      </div>
    </div>
  );
}

function MapBg({ t }) {
  return (
    <svg width="100%" height="100%" viewBox="0 0 400 500" preserveAspectRatio="xMidYMid slice" style={{ display: 'block' }}>
      <rect width="400" height="500" fill="#E5DFCF"/>
      {/* blocks */}
      {[
        [40, 80, 120, 90], [200, 60, 70, 110], [300, 80, 80, 80],
        [60, 220, 90, 100], [180, 200, 60, 130], [280, 240, 100, 90],
        [40, 360, 110, 90], [180, 360, 100, 90], [310, 370, 70, 90],
      ].map(([x,y,w,h], i) => (
        <rect key={i} x={x} y={y} width={w} height={h} fill={i % 2 ? '#F0EBDB' : '#EAE3D0'} rx="4"/>
      ))}
      {/* roads */}
      <path d="M0 180 H400" stroke="#fff" strokeWidth="14"/>
      <path d="M0 340 H400" stroke="#fff" strokeWidth="10"/>
      <path d="M170 0 V500" stroke="#fff" strokeWidth="12"/>
      <path d="M270 0 V500" stroke="#fff" strokeWidth="8"/>
      {/* park */}
      <circle cx="350" cy="180" r="32" fill="#C7D7B5"/>
      <text x="338" y="184" fontSize="9" fill="#7A8A6A" fontFamily="IBM Plex Mono">公園</text>
      {/* labels */}
      <text x="80" y="130" fontSize="8" fill="#9A8F77" fontFamily="IBM Plex Mono">辻堂神台</text>
      <text x="220" y="115" fontSize="8" fill="#9A8F77" fontFamily="IBM Plex Mono">1丁目</text>
    </svg>
  );
}

Object.assign(window, { ShoppingLocationPage, LocationPickerPage, AddLocationDialog });
