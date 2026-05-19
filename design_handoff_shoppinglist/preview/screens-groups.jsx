// screens-groups.jsx — Groups list(7), Create(8), Setting(9), Invitation accept(10)

function GroupListPage({ t, state = 'multi' }) {
  const groups = [
    { id: 1, name: '家族', count: 3, isDefault: true, members: ['M', 'O', 'A'] },
    { id: 2, name: 'じぶん用', count: 1, members: ['M'] },
    { id: 3, name: 'ルームシェア', count: 4, members: ['M', 'K', 'S', 'Y'] },
  ];
  const free = state === 'free-limit';
  return (
    <div style={{ background: t.paper, height: '100%', position: 'relative', overflow: 'auto' }}>
      <AppBar title="グループ管理" t={t} leading={<RoundBtn name="chev-l" t={t}/>}/>
      <div style={{ padding: '14px 16px 100px', display: 'flex', flexDirection: 'column', gap: 14 }}>
        <div style={{ fontSize: 12, color: t.ink2, padding: '0 4px', lineHeight: 1.6 }}>
          リストはグループに属します。家族と日用品、ルームシェアと食料品など、用途で分けると便利です。
        </div>
        <div style={{ background: t.card, borderRadius: 14, overflow: 'hidden' }}>
          {groups.map((g, i) => (
            <React.Fragment key={g.id}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '14px 16px' }}>
                <div style={{ display: 'flex' }}>
                  {g.members.slice(0, 3).map((m, j) => (
                    <div key={j} style={{
                      width: 28, height: 28, borderRadius: 999,
                      background: ['#C2410C','#1F6B4E','#0F4C81','#B45309'][j % 4],
                      color: '#fff', fontSize: 11, fontWeight: 700,
                      display: 'flex', alignItems: 'center', justifyContent: 'center',
                      border: `1.5px solid ${t.card}`, marginLeft: j ? -8 : 0,
                      fontFamily: 'IBM Plex Mono',
                    }}>{m}</div>
                  ))}
                </div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 15, fontWeight: 600, color: t.ink, display: 'flex', alignItems: 'center', gap: 6 }}>
                    {g.name}
                    {g.isDefault && <span style={{
                      fontSize: 9.5, padding: '2px 6px', borderRadius: 4, background: t.accentSoft, color: t.accent, fontWeight: 700,
                    }}>デフォルト</span>}
                  </div>
                  <div style={{ fontSize: 12, color: t.ink3, marginTop: 1 }}>メンバー {g.count}人</div>
                </div>
                <Icon name="chev-r" size={14} stroke={t.ink4}/>
              </div>
              {i < groups.length - 1 && <Divider t={t} inset={56}/>}
            </React.Fragment>
          ))}
        </div>
        {free && (
          <div style={{
            padding: 14, background: t.accentSoft, borderRadius: 14, color: t.dark ? t.accentInk : t.accent,
            display: 'flex', alignItems: 'center', gap: 10, fontSize: 13, fontWeight: 500,
          }}>
            <Icon name="crown" size={16} stroke={t.accent}/>
            <div style={{ flex: 1 }}>無料プランは最大3グループまでです</div>
            <span style={{ fontWeight: 700 }}>解除</span>
          </div>
        )}
      </div>
      <div style={{ position: 'absolute', right: 16, bottom: 36, zIndex: 5 }}>
        <button style={{
          width: 56, height: 56, borderRadius: 999, background: free ? t.surface2 : t.accent,
          color: free ? t.ink3 : '#fff', border: 'none',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          boxShadow: '0 6px 14px rgba(27,24,19,0.18)', cursor: 'pointer',
        }}>
          <Icon name={free ? 'lock' : 'plus'} size={24} sw={2.2}/>
        </button>
      </div>
    </div>
  );
}

function GroupCreatePage({ t, state = 'idle' }) {
  return (
    <div style={{ background: t.paper, height: '100%', position: 'relative' }}>
      <AppBar title="グループを作る" t={t} leading={<RoundBtn name="chev-l" t={t}/>}/>
      <div style={{ padding: '20px 16px' }}>
        <div style={{ fontSize: 13, color: t.ink2, lineHeight: 1.6, marginBottom: 14 }}>
          後からメンバーを招待できます。たとえば「家族」「ルームシェア」など、生活単位の名前がおすすめです。
        </div>
        <div style={{ background: t.card, padding: '14px 16px', borderRadius: 14 }}>
          <div style={{ fontSize: 11, color: t.ink3, fontWeight: 600, marginBottom: 6 }}>グループ名</div>
          <input placeholder="例: 家族" defaultValue="うちの家族" style={{
            width: '100%', border: 'none', background: 'transparent', outline: 'none',
            fontFamily: 'inherit', fontSize: 17, fontWeight: 500, color: t.ink, padding: 0,
          }}/>
          <div style={{ height: 1, background: t.accent, marginTop: 8 }}/>
        </div>
        <div style={{ marginTop: 24 }}>
          <Pill t={t} accent lg style={{ width: '100%' }}>
            {state === 'creating' ? <Spinner t={t} size={18}/> : '作成する'}
          </Pill>
        </div>
        {state === 'error' && (
          <div style={{
            marginTop: 12, padding: '10px 12px', background: t.dangerSoft, color: t.danger,
            borderRadius: 10, fontSize: 12, fontWeight: 500,
          }}>
            グループの作成に失敗しました。通信状態を確認してください。
          </div>
        )}
      </div>
    </div>
  );
}

function GroupSettingPage({ t, role = 'owner' }) {
  const members = [
    { id: 1, name: 'おとうさん (Mio)', meta: 'オーナー', color: '#C2410C', i: 'M' },
    { id: 2, name: 'おかあさん (Aya)', meta: '自分', color: '#1F6B4E', i: 'A' },
    { id: 3, name: 'むすめ (Yui)', color: '#0F4C81', i: 'Y' },
  ];
  return (
    <div style={{ background: t.paper, height: '100%', overflow: 'auto', position: 'relative' }}>
      <AppBar title="グループ設定" t={t} leading={<RoundBtn name="chev-l" t={t}/>} trailing={<RoundBtn name="more-h" t={t}/>}/>
      <div style={{ padding: '14px 16px 60px', display: 'flex', flexDirection: 'column', gap: 16 }}>
        <Section t={t} label="グループ名">
          <div style={{ padding: '12px 16px', background: t.card, borderRadius: 14 }}>
            <input defaultValue="うちの家族" style={{
              width: '100%', border: 'none', background: 'transparent', outline: 'none',
              fontFamily: 'inherit', fontSize: 16, fontWeight: 500, color: t.ink,
            }}/>
          </div>
        </Section>
        <Section t={t} label={`メンバー (${members.length})`}>
          <div style={{ background: t.card, borderRadius: 14, overflow: 'hidden' }}>
            {members.map((m, i) => (
              <React.Fragment key={m.id}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 16px' }}>
                  <div style={{
                    width: 36, height: 36, borderRadius: 999, background: m.color, color: '#fff',
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    fontWeight: 700, fontFamily: 'IBM Plex Mono',
                  }}>{m.i}</div>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontSize: 14, color: t.ink, fontWeight: 500 }}>{m.name}</div>
                    {m.meta && <div style={{ fontSize: 11, color: m.meta === '自分' ? t.accent : t.ink3, fontWeight: 600 }}>{m.meta}</div>}
                  </div>
                  {role === 'owner' && m.meta !== 'オーナー' && m.meta !== '自分' && (
                    <button style={{ background: 'transparent', border: 'none', color: t.ink3, padding: 6 }}>
                      <Icon name="more-h" size={16}/>
                    </button>
                  )}
                </div>
                {i < members.length - 1 && <Divider t={t} inset={64}/>}
              </React.Fragment>
            ))}
          </div>
          <Pill t={t} soft icon="person-add" style={{ marginTop: 8 }}>招待コードを発行</Pill>
        </Section>
        <Section t={t} label="リストの軸">
          <div style={{ background: t.card, borderRadius: 14, overflow: 'hidden' }}>
            <Cell t={t} title="買い物する場所" sub="3件登録" icon={{ name: 'pin', color: t.accent }}/>
            <Divider t={t}/>
            <Cell t={t} title="カテゴリ" sub="6件登録" icon={{ name: 'tag', color: t.ok }}/>
          </div>
        </Section>
      </div>
    </div>
  );
}

function GroupInvitationAcceptPage({ t, state = 'valid' }) {
  const code = state === 'invalid' ? 'X9K1' : 'X9KP2H4M';
  return (
    <div style={{ background: t.paper, height: '100%', position: 'relative' }}>
      <AppBar title="招待コードで参加" t={t} leading={<RoundBtn name="chev-l" t={t}/>}/>
      <div style={{ padding: '40px 28px 20px', textAlign: 'center' }}>
        <div style={{
          width: 72, height: 72, borderRadius: 18, background: t.accentSoft,
          display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <Icon name="person-add" size={32} stroke={t.accent}/>
        </div>
        <div style={{ fontSize: 19, fontWeight: 700, color: t.ink, marginTop: 16, lineHeight: 1.4 }}>
          グループに参加
        </div>
        <div style={{ fontSize: 13, color: t.ink2, marginTop: 6, lineHeight: 1.7 }}>
          メンバーから共有された 8桁の招待コードを入力してください。
        </div>
      </div>
      <div style={{ padding: '0 24px' }}>
        <div className="mono" style={{
          background: t.card, borderRadius: 16, padding: '20px 16px',
          fontSize: 28, fontWeight: 600, letterSpacing: 6, color: t.ink, textAlign: 'center',
          border: `1px solid ${state === 'invalid' ? t.danger : (state === 'valid' ? t.accent : t.divider)}`,
        }}>
          {code.padEnd(8, '·').split('').map((c, i) => (
            <span key={i} style={{ color: c === '·' ? t.ink4 : t.ink, marginRight: i === 3 ? 12 : 0 }}>{c}</span>
          ))}
        </div>
        {state === 'invalid' && (
          <div style={{ fontSize: 12, color: t.danger, marginTop: 8, textAlign: 'center', fontWeight: 500 }}>
            コードは 8桁の英数字です
          </div>
        )}
      </div>
      <div style={{ padding: '24px 24px 0', display: 'flex', flexDirection: 'column', gap: 10 }}>
        <Pill t={t} accent lg style={{ width: '100%' }} disabled={state !== 'valid'}>
          {state === 'verifying' ? <Spinner t={t} size={18}/> : '参加する'}
        </Pill>
        <Pill t={t} ghost lg style={{ width: '100%' }}>キャンセル</Pill>
      </div>
    </div>
  );
}

Object.assign(window, { GroupListPage, GroupCreatePage, GroupSettingPage, GroupInvitationAcceptPage });
