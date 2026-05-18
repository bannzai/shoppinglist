// screens-settings.jsx — Setting(15), Theme color(16), Paywall(17)

function SettingPage({ t, state = 'free' }) {
  const isPremium = state === 'premium';
  return (
    <div style={{ background: t.paper, height: '100%', position: 'relative', overflow: 'auto' }}>
      <div style={{ paddingTop: 44 }}/>
      <div style={{ padding: '12px 20px 14px' }}>
        <div style={{ fontSize: 28, fontWeight: 700, color: t.ink, letterSpacing: -0.02 }}>設定</div>
      </div>
      <div style={{ padding: '0 16px 100px', display: 'flex', flexDirection: 'column', gap: 16 }}>
        {/* Profile card */}
        <div style={{
          background: t.card, borderRadius: 16, padding: 16,
          display: 'flex', alignItems: 'center', gap: 12,
        }}>
          <div style={{
            width: 48, height: 48, borderRadius: 999, background: '#1F6B4E', color: '#fff',
            fontWeight: 700, fontFamily: 'IBM Plex Mono',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>A</div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 15, fontWeight: 600, color: t.ink }}>Aya</div>
            <div style={{ fontSize: 12, color: t.ink3 }}>aya@example.com</div>
          </div>
          <Pill t={t} ghost>編集</Pill>
        </div>

        {/* Premium card */}
        <div style={{
          background: isPremium ? `linear-gradient(135deg, ${t.accent} 0%, #7C2A07 100%)` : t.surface2,
          color: isPremium ? '#fff' : t.ink,
          borderRadius: 16, padding: 16, position: 'relative', overflow: 'hidden',
          border: isPremium ? 'none' : `1px solid ${t.divider}`,
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <div style={{
              width: 36, height: 36, borderRadius: 10,
              background: isPremium ? 'rgba(255,255,255,0.18)' : t.accentSoft,
              color: isPremium ? '#fff' : t.accent,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <Icon name="crown" size={20}/>
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14, fontWeight: 700 }}>{isPremium ? 'プレミアム会員' : 'プレミアムにアップグレード'}</div>
              <div style={{ fontSize: 11.5, opacity: isPremium ? 0.85 : 1, color: isPremium ? '#fff' : t.ink2, marginTop: 1 }}>
                {isPremium ? '全機能が利用可能' : '位置リマインダー・写真添付など'}
              </div>
            </div>
            <Icon name="chev-r" size={16} stroke={isPremium ? '#fff' : t.ink3}/>
          </div>
        </div>

        <Section t={t} label="グループ">
          <div style={{ background: t.card, borderRadius: 14, overflow: 'hidden' }}>
            <Cell t={t} title="グループ管理" sub="3グループ" icon={{ name: 'people', color: t.accent }}/>
            <Divider t={t}/>
            <Cell t={t} title="招待コードでグループに参加" icon={{ name: 'qr', color: t.ink2 }}/>
          </div>
        </Section>

        <Section t={t} label="外観">
          <div style={{ background: t.card, borderRadius: 14, overflow: 'hidden' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '13px 16px' }}>
              <div style={{ width: 32, height: 32, borderRadius: 9, background: t.accent }}/>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 15, color: t.ink, fontWeight: 500 }}>テーマカラー</div>
                <div style={{ fontSize: 12, color: t.ink3, marginTop: 1 }}>朱 (デフォルト)</div>
              </div>
              {!isPremium && <Icon name="crown" size={14} stroke={t.accent}/>}
              <Icon name="chev-r" size={14} stroke={t.ink4}/>
            </div>
          </div>
        </Section>

        <Section t={t} label="通知">
          <div style={{ background: t.card, borderRadius: 14, overflow: 'hidden' }}>
            <Cell t={t} title="リスト更新通知" sub="メンバーがアイテムを追加・チェックした時"
              switch swOn icon={{ name: 'bell', color: t.ink2 }}/>
            <Divider t={t}/>
            <Cell t={t} title="お店の近くで通知" sub={state === 'no-loc-perm' ? '位置情報の権限が必要です' : 'プレミアムで設定可能'}
              switch swOn={false} icon={{ name: 'pin', color: t.ink2 }}/>
          </div>
        </Section>

        <Section t={t} label="アプリについて">
          <div style={{ background: t.card, borderRadius: 14, overflow: 'hidden' }}>
            <Cell t={t} title="利用規約"/>
            <Divider t={t}/>
            <Cell t={t} title="プライバシーポリシー"/>
            <Divider t={t}/>
            <Cell t={t} title="特定商取引法に基づく表記"/>
            <Divider t={t}/>
            <Cell t={t} title="お問い合わせ" icon={{ name: 'mail', color: t.ink2 }}/>
          </div>
        </Section>

        <button style={{
          padding: '12px 14px', background: 'transparent', border: 'none',
          color: t.ink3, fontSize: 12, fontFamily: 'inherit', cursor: 'pointer',
        }}>退会する</button>

        <div className="mono" style={{ textAlign: 'center', fontSize: 10, color: t.ink4 }}>
          v1.4.2 (build 248)
        </div>
      </div>
      <TabBar t={t} active="settings"/>
    </div>
  );
}

function ThemeColorSelectionPage({ t, selected = 'shu' }) {
  const colors = [
    { id: 'shu', name: '朱', c: '#C2410C' },
    { id: 'matcha', name: '抹茶', c: '#1F6B4E' },
    { id: 'ai', name: '藍', c: '#0F4C81' },
    { id: 'kuchiba', name: '朽葉', c: '#B45309' },
    { id: 'beni', name: '紅', c: '#B23A48' },
    { id: 'momo', name: '桃', c: '#D8839B' },
    { id: 'kihada', name: '黄檗', c: '#C7B452' },
    { id: 'wakatake', name: '若竹', c: '#5A8F4A' },
    { id: 'asagi', name: '浅葱', c: '#3B7E84' },
    { id: 'sumi', name: '墨', c: '#1B1B1B' },
  ];
  return (
    <div style={{ background: t.paper, height: '100%', overflow: 'auto', position: 'relative' }}>
      <AppBar title="テーマカラー" t={t} leading={<RoundBtn name="chev-l" t={t}/>}/>
      <div style={{ padding: '20px 24px 60px' }}>
        <div style={{ fontSize: 13, color: t.ink2, lineHeight: 1.7, marginBottom: 20 }}>
          アプリ全体のアクセントカラーを選びます。リスト・ボタン・進捗バーに使われます。
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(5, 1fr)', gap: 14, justifyItems: 'center' }}>
          {colors.map(c => {
            const sel = c.id === selected;
            return (
              <div key={c.id} style={{ textAlign: 'center' }}>
                <div style={{
                  width: 52, height: 52, borderRadius: 999, background: c.c,
                  border: sel ? `3px solid ${t.surface}` : `1px solid rgba(0,0,0,0.08)`,
                  outline: sel ? `2px solid ${t.ink}` : 'none',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  position: 'relative',
                  boxShadow: sel ? '0 4px 14px rgba(0,0,0,0.16)' : 'none',
                }}>
                  {sel && <Icon name="check" size={22} stroke="#fff" sw={2.4}/>}
                </div>
                <div className="serif" style={{ fontSize: 12, color: t.ink2, marginTop: 6, fontWeight: 600 }}>{c.name}</div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}

function PaywallPage({ t, state = 'plans' }) {
  return (
    <div style={{ background: t.paper, height: '100%', position: 'relative', overflow: 'auto' }}>
      <AppBar title="プレミアムプラン" t={t} leading={<RoundBtn name="x" t={t}/>}/>
      {/* Hero */}
      <div style={{ padding: '8px 24px 12px', textAlign: 'center' }}>
        <div style={{
          width: 64, height: 64, borderRadius: 18, margin: '8px auto 14px',
          background: `linear-gradient(135deg, ${t.accent}, #7C2A07)`, color: '#fff',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          boxShadow: '0 12px 24px rgba(194,65,12,0.25)',
        }}>
          <Icon name="crown" size={28}/>
        </div>
        <div style={{ fontSize: 22, fontWeight: 800, color: t.ink, letterSpacing: -0.02 }}>
          全機能を解放しよう
        </div>
        <div style={{ fontSize: 13, color: t.ink2, lineHeight: 1.6, marginTop: 8 }}>
          家族みんなで快適に使える便利機能。<br/>いつでも解約できます。
        </div>
      </div>
      {/* Features */}
      <div style={{ padding: '0 20px', marginBottom: 16 }}>
        <div style={{ background: t.card, borderRadius: 16, padding: '4px 14px' }}>
          {[
            { icon: 'pin', t: '位置情報リマインダー' },
            { icon: 'image', t: 'アイテムに写真を添付' },
            { icon: 'wand', t: 'AI 認識の上限を解除' },
            { icon: 'palette', t: 'テーマカラーを変更' },
            { icon: 'export', t: 'リストをエクスポート' },
            { icon: 'doc', t: 'リストを期限なしで保存' },
          ].map((f, i, arr) => (
            <React.Fragment key={i}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '11px 0' }}>
                <div style={{
                  width: 28, height: 28, borderRadius: 8, background: t.accentSoft, color: t.accent,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>
                  <Icon name={f.icon} size={15}/>
                </div>
                <div style={{ fontSize: 13.5, color: t.ink, fontWeight: 500, flex: 1 }}>{f.t}</div>
                <Icon name="check" size={14} stroke={t.ok} sw={2.4}/>
              </div>
              {i < arr.length - 1 && <Divider t={t} inset={40}/>}
            </React.Fragment>
          ))}
        </div>
      </div>

      {/* Plans */}
      <div style={{ padding: '0 20px 130px' }}>
        {state === 'loading' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {[0,1,2].map(i => (
              <div key={i} style={{
                height: 76, borderRadius: 16, background: t.surface2,
                border: `1px solid ${t.divider}`, position: 'relative', overflow: 'hidden',
              }} className="stripe-ph"/>
            ))}
            <div style={{ textAlign: 'center', marginTop: 14, color: t.ink3, fontSize: 12 }}>
              <Spinner t={t}/> プランを読み込み中…
            </div>
          </div>
        )}
        {state === 'error' && (
          <div style={{
            padding: 18, borderRadius: 16, background: t.dangerSoft, color: t.danger,
            textAlign: 'center', fontSize: 13,
          }}>
            <div style={{ fontWeight: 700, marginBottom: 4 }}>プランを取得できませんでした</div>
            <div style={{ fontSize: 12, color: t.ink2, marginBottom: 12 }}>通信状態をご確認ください</div>
            <Pill t={t} accent>再試行</Pill>
          </div>
        )}
        {state === 'no-plans' && (
          <div style={{
            padding: 24, borderRadius: 16, background: t.surface2,
            textAlign: 'center', border: `1px dashed ${t.divider}`, color: t.ink2, fontSize: 13,
          }}>
            現在ご利用いただけるプランがありません。<br/>しばらくしてから再度お試しください。
          </div>
        )}
        {state === 'plans' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            <PlanCard t={t} title="月額プラン" price="¥480" cycle="/月" sub="気軽に試したい方に"/>
            <PlanCard t={t} title="年間プラン" price="¥3,800" cycle="/年" sub="¥316/月 · 月額より34%おトク"
              recommended/>
            <PlanCard t={t} title="買い切り" price="¥9,800" cycle=""
              sub="一度購入すれば、ずっと使えます"/>
          </div>
        )}
        <div style={{ textAlign: 'center', fontSize: 11, color: t.ink3, marginTop: 16, lineHeight: 1.7 }}>
          いつでも解約できます。<br/>
          <span className="lk">利用規約</span> · <span className="lk">プライバシーポリシー</span> · <span className="lk">復元</span>
        </div>
      </div>
    </div>
  );
}

function PlanCard({ t, title, price, cycle, sub, recommended }) {
  return (
    <div style={{
      background: t.card, borderRadius: 16, padding: 16,
      border: recommended ? `1.5px solid ${t.accent}` : `1px solid ${t.divider}`,
      position: 'relative', display: 'flex', alignItems: 'center', gap: 14,
    }}>
      {recommended && (
        <span style={{
          position: 'absolute', top: -8, left: 14, background: t.accent, color: '#fff',
          fontSize: 10, padding: '2px 8px', borderRadius: 999, fontWeight: 700, letterSpacing: 0.05,
        }}>おすすめ</span>
      )}
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 14, fontWeight: 700, color: t.ink }}>{title}</div>
        <div style={{ fontSize: 11.5, color: t.ink3, marginTop: 2 }}>{sub}</div>
      </div>
      <div style={{ textAlign: 'right', marginRight: 4 }}>
        <span className="mono" style={{ fontSize: 19, fontWeight: 700, color: t.ink }}>{price}</span>
        <span className="mono" style={{ fontSize: 12, color: t.ink3 }}>{cycle}</span>
      </div>
      <button style={{
        padding: '10px 16px', borderRadius: 999, background: recommended ? t.accent : t.surface2,
        color: recommended ? '#fff' : t.ink, border: recommended ? 'none' : `1px solid ${t.divider}`,
        fontFamily: 'inherit', fontWeight: 700, fontSize: 13, cursor: 'pointer',
      }}>選ぶ</button>
    </div>
  );
}

Object.assign(window, { SettingPage, ThemeColorSelectionPage, PaywallPage, PlanCard });
