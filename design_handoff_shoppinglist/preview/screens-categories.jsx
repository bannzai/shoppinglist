// screens-categories.jsx — Category list(11), Category edit(12)

const CAT_PRESETS = [
  { id: 'veg', name: '野菜・果物', color: '#6BAA5E', icon: '🥕', kw: 4 },
  { id: 'meat', name: '肉・魚', color: '#C05757', icon: '🐟', kw: 6 },
  { id: 'dairy', name: '乳製品・卵', color: '#E8B547', icon: '🥚', kw: 5 },
  { id: 'bake', name: 'パン・米', color: '#B98A4C', icon: '🍞', kw: 3 },
  { id: 'drink', name: '飲み物', color: '#5A8AB5', icon: '☕', kw: 7 },
  { id: 'misc', name: 'その他', color: '#8A8275', icon: '📦', kw: 2 },
];

function GroupCategoryPage({ t, state = 'list' }) {
  return (
    <div style={{ background: t.paper, height: '100%', overflow: 'auto', position: 'relative' }}>
      <AppBar title="カテゴリ" t={t} leading={<RoundBtn name="chev-l" t={t}/>}/>
      <div style={{ padding: '14px 16px 100px', display: 'flex', flexDirection: 'column', gap: 12 }}>
        <div style={{ fontSize: 12, color: t.ink2, padding: '0 4px', lineHeight: 1.6 }}>
          アイテム名のキーワードで自動分類されます。並び順はリスト表示に反映されます。
        </div>
        {/* Sort by store dropdown */}
        <div style={{
          display: 'flex', alignItems: 'center', gap: 10, padding: '12px 14px',
          background: t.surface2, borderRadius: 12, border: `1px solid ${t.divider}`,
        }}>
          <Icon name="pin" size={16} stroke={t.ink2}/>
          <div style={{ fontSize: 12, color: t.ink2 }}>並び順</div>
          <div style={{ flex: 1 }}/>
          <button style={{
            background: t.card, border: `1px solid ${t.divider}`, borderRadius: 999,
            padding: '6px 12px', fontSize: 12, fontWeight: 600, color: t.ink, display: 'flex', gap: 4, alignItems: 'center',
          }}>
            イオン藤沢店 <Icon name="chev-d" size={14} stroke={t.ink3}/>
          </button>
        </div>
        {/* List */}
        <div style={{ background: t.card, borderRadius: 14, overflow: 'hidden' }}>
          {CAT_PRESETS.map((c, i) => (
            <React.Fragment key={c.id}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 14px' }}>
                <Icon name="drag" size={16} stroke={t.ink4}/>
                <div style={{
                  width: 32, height: 32, borderRadius: 9,
                  background: c.color + '22', color: c.color,
                  display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 18,
                }}>{c.icon}</div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 14.5, color: t.ink, fontWeight: 600 }}>{c.name}</div>
                  <div style={{ fontSize: 11.5, color: t.ink3, marginTop: 1 }}>キーワード: {c.kw}件</div>
                </div>
                <button style={{ background: 'transparent', border: 'none', color: t.ink3, padding: 4 }}>
                  <Icon name="edit" size={16}/>
                </button>
                <button style={{ background: 'transparent', border: 'none', color: t.ink3, padding: 4 }}>
                  <Icon name="trash" size={16}/>
                </button>
              </div>
              {i < CAT_PRESETS.length - 1 && <Divider t={t} inset={56}/>}
            </React.Fragment>
          ))}
        </div>
        {state === 'free-locked' && (
          <div style={{
            padding: 12, background: t.surface2, borderRadius: 12, border: `1px solid ${t.divider}`,
            display: 'flex', alignItems: 'center', gap: 10, fontSize: 12, color: t.ink2,
          }}>
            <Icon name="crown" size={14} stroke={t.accent}/>
            <div style={{ flex: 1 }}>店舗ごとの並び順はプレミアム機能です</div>
            <span style={{ color: t.accent, fontWeight: 700, fontSize: 12 }}>解除</span>
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
    </div>
  );
}

function GroupCategoryEditPage({ t }) {
  const swatches = ['none', '#6BAA5E', '#C05757', '#E8B547', '#B98A4C', '#5A8AB5', '#8A8275', '#7B5BA8', '#1F6B4E'];
  const icons = ['🥕','🐟','🥚','🍞','☕','📦','🧴','🍱','🍎','🥦','🍣','🍫'];
  const keywords = [
    { kw: 'トマト', mode: '部分一致' },
    { kw: 'にんじん', mode: '部分一致' },
    { kw: '玉ねぎ', mode: '部分一致' },
    { kw: 'キャベツ', mode: '完全一致' },
  ];
  return (
    <div style={{ background: t.paper, height: '100%', overflow: 'auto', position: 'relative' }}>
      <AppBar title="カテゴリ編集" t={t} leading={<RoundBtn name="chev-l" t={t}/>}/>
      <div style={{ padding: '14px 16px 60px', display: 'flex', flexDirection: 'column', gap: 16 }}>
        <Section t={t} label="名前">
          <div style={{ padding: '12px 16px', background: t.card, borderRadius: 14 }}>
            <input defaultValue="野菜・果物" style={{
              width: '100%', border: 'none', background: 'transparent', outline: 'none',
              fontFamily: 'inherit', fontSize: 16, fontWeight: 500, color: t.ink,
            }}/>
          </div>
        </Section>
        <Section t={t} label="色">
          <div style={{ background: t.card, borderRadius: 14, padding: 14, display: 'flex', flexWrap: 'wrap', gap: 10 }}>
            {swatches.map((c, i) => (
              <div key={i} style={{
                width: 40, height: 40, borderRadius: 999,
                background: c === 'none' ? t.surface2 : c,
                border: i === 1 ? `2px solid ${t.ink}` : `1px solid ${t.divider}`,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                position: 'relative',
              }}>
                {c === 'none' && <Icon name="x" size={16} stroke={t.ink3}/>}
                {i === 1 && <div style={{
                  position: 'absolute', inset: -4, borderRadius: 999, border: `2px solid ${t.ink}`,
                }}/>}
              </div>
            ))}
          </div>
        </Section>
        <Section t={t} label="アイコン">
          <div style={{ background: t.card, borderRadius: 14, padding: 14 }}>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(6, 1fr)', gap: 8 }}>
              <div style={{
                height: 44, borderRadius: 10, background: t.surface2, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
                border: `1px solid ${t.divider}`, gap: 1,
              }}>
                <span style={{ fontSize: 14, fontWeight: 700, color: t.ink2 }}>野</span>
                <span className="mono" style={{ fontSize: 7, color: t.ink3, letterSpacing: 0.3 }}>未設定</span>
              </div>
              {icons.map((ic, i) => (
                <div key={i} style={{
                  height: 44, borderRadius: 10,
                  background: i === 0 ? t.accentSoft : t.surface2,
                  border: i === 0 ? `1.5px solid ${t.accent}` : `1px solid ${t.divider}`,
                  display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 22,
                }}>{ic}</div>
              ))}
              <div style={{
                height: 44, borderRadius: 10, background: t.accentSoft,
                border: `1px dashed ${t.accent}`,
                display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
                color: t.accent, position: 'relative', gap: 1,
              }}>
                <Icon name="wand" size={14} stroke={t.accent}/>
                <span className="mono" style={{ fontSize: 7, fontWeight: 700, letterSpacing: 0.3 }}>AI 生成</span>
                <div style={{
                  position: 'absolute', top: 2, right: 2,
                  width: 12, height: 12, borderRadius: 999, background: '#fff',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  border: `1px solid ${t.accent}`,
                }}><Icon name="crown" size={7} stroke={t.accent} sw={2}/></div>
              </div>
            </div>
            <div style={{
              marginTop: 10, padding: '8px 10px', borderRadius: 8, background: t.surface2,
              fontSize: 11, color: t.ink3, lineHeight: 1.5, display: 'flex', gap: 6,
            }}>
              <Icon name="info" size={12} stroke={t.ink3}/>
              <span>未設定の場合はカテゴリ名の先頭1文字が表示されます。「AI 生成」はプレミアム機能で、足りないアイコンをその場で作れます。</span>
            </div>
          </div>
        </Section>
        <Section t={t} label={`キーワード (${keywords.length})`}>
          <div style={{ background: t.card, borderRadius: 14, overflow: 'hidden' }}>
            {keywords.map((k, i) => (
              <React.Fragment key={i}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 14px' }}>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontSize: 14, color: t.ink, fontWeight: 500 }}>{k.kw}</div>
                    <div style={{ fontSize: 11.5, color: t.ink3, marginTop: 1 }}>{k.mode}</div>
                  </div>
                  <button style={{ background: 'transparent', border: 'none', color: t.ink3, padding: 4 }}>
                    <Icon name="x" size={16}/>
                  </button>
                </div>
                {i < keywords.length - 1 && <Divider t={t} inset={14}/>}
              </React.Fragment>
            ))}
          </div>
          <Pill t={t} ghost icon="plus" style={{ marginTop: 8 }}>キーワードを追加</Pill>
        </Section>
      </div>
    </div>
  );
}

Object.assign(window, { GroupCategoryPage, GroupCategoryEditPage, CAT_PRESETS });
