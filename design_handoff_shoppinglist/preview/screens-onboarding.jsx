// screens-onboarding.jsx — Onboarding (1), Auth (2), Home tab root (3)

function Onboarding({ t, slide = 1 }) {
  const slides = [
    {
      eyebrow: '01 / 03',
      title: '家族と作る\n買い物リスト',
      body: '家で思いついたものを誰かが追加して、店頭で別の誰かがチェック。「買ってきて」のやり取りを、ぜんぶこの一枚に。',
      cta: '次へ',
    },
    {
      eyebrow: '02 / 03',
      title: '同じリストを\n同時に編集',
      body: '家族・パートナー・同居人を招待コードで招くと、同じリストを編集できます。誰が追加したかではなく、何を買い忘れずに済むかを大切に。',
      cta: '次へ',
    },
    {
      eyebrow: '03 / 03',
      title: 'お店の近くで\nそっと思い出す',
      body: '登録した店舗の近くに来ると、買い物リストをやさしくお知らせ。通知は必要な時だけ、押し付けがましくなく。',
      cta: 'はじめる',
    },
  ];
  const s = slides[slide - 1];
  return (
    <div style={{ background: t.surface, height: '100%', position: 'relative', overflow: 'hidden', display: 'flex', flexDirection: 'column' }}>
      <div style={{ paddingTop: 44 }}/>
      {/* skip */}
      <div style={{ display: 'flex', justifyContent: 'flex-end', padding: '12px 16px' }}>
        <button style={{
          background: 'transparent', border: 'none', color: t.ink3, fontSize: 13, fontWeight: 600, cursor: 'pointer',
        }}>スキップ</button>
      </div>
      {/* illustration */}
      <div style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '0 32px' }}>
        <OnboardingArt t={t} slide={slide}/>
      </div>
      {/* eyebrow + title + body */}
      <div style={{ padding: '0 28px 14px' }}>
        <div className="mono" style={{ fontSize: 11, color: t.accent, letterSpacing: 0.1, fontWeight: 600, marginBottom: 10 }}>
          {s.eyebrow}
        </div>
        <h1 style={{
          fontSize: 30, fontWeight: 800, lineHeight: 1.18, letterSpacing: -0.02,
          color: t.ink, margin: 0, whiteSpace: 'pre-line',
        }}>{s.title}</h1>
        <p style={{ fontSize: 14, color: t.ink2, lineHeight: 1.7, marginTop: 14, marginBottom: 0, textWrap: 'pretty' }}>
          {s.body}
        </p>
      </div>
      {/* dots + CTA */}
      <div style={{ padding: '14px 20px 40px' }}>
        <div style={{ display: 'flex', gap: 6, justifyContent: 'center', marginBottom: 18 }}>
          {[1,2,3].map(i => (
            <div key={i} style={{
              width: i === slide ? 22 : 6, height: 6, borderRadius: 6,
              background: i === slide ? t.accent : t.divider, transition: 'all 200ms',
            }}/>
          ))}
        </div>
        <Pill t={t} accent lg style={{ width: '100%' }}>
          {s.cta} {slide < 3 && <Icon name="arrow-r" size={16}/>}
        </Pill>
      </div>
    </div>
  );
}

function OnboardingArt({ t, slide }) {
  if (slide === 1) {
    // shared list
    return (
      <div style={{ position: 'relative', width: 280, height: 320 }}>
        <div style={{
          position: 'absolute', top: 0, left: 20, width: 220, padding: 16,
          background: t.card, borderRadius: 18, boxShadow: t.shadow, border: `1px solid ${t.divider}`,
          transform: 'rotate(-3deg)',
        }}>
          <div style={{ fontSize: 11, color: t.ink3, marginBottom: 8, fontWeight: 600 }}>うちの買い物 · 6/8</div>
          {['牛乳 1L', 'トマト', '豚バラ', 'コーヒー'].map((n, i) => (
            <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '4px 0' }}>
              <Checkbox t={t} size={16} checked={i < 2}/>
              <span style={{ fontSize: 13, color: i < 2 ? t.checked : t.ink, textDecoration: i < 2 ? 'line-through' : 'none' }}>{n}</span>
            </div>
          ))}
        </div>
        <div style={{
          position: 'absolute', bottom: 20, right: 0, width: 140, padding: 12,
          background: t.accent, color: '#fff', borderRadius: 14, transform: 'rotate(4deg)',
          boxShadow: '0 12px 30px rgba(194,65,12,0.3)',
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <Icon name="plus" size={14}/>
            <span style={{ fontSize: 12, fontWeight: 700 }}>みかん 1袋</span>
          </div>
          <div style={{ fontSize: 10, opacity: 0.8, marginTop: 2 }}>Mio が追加</div>
        </div>
      </div>
    );
  }
  if (slide === 2) {
    // group of three
    return (
      <div style={{ position: 'relative', width: 300, height: 300 }}>
        <div style={{
          position: 'absolute', inset: 0, borderRadius: '50%',
          border: `1.5px dashed ${t.divider}`,
        }}/>
        {[
          { x: 150, y: 30, label: 'おとうさん', color: '#C2410C', i: 'O' },
          { x: 50, y: 200, label: 'おかあさん', color: '#1F6B4E', i: 'M' },
          { x: 250, y: 200, label: 'むすめ', color: '#0F4C81', i: 'A' },
        ].map((p, i) => (
          <div key={i} style={{ position: 'absolute', left: p.x - 30, top: p.y - 30, textAlign: 'center' }}>
            <div style={{
              width: 60, height: 60, borderRadius: 60, background: p.color, color: '#fff',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: 22, fontWeight: 700, fontFamily: 'IBM Plex Mono',
              boxShadow: '0 6px 16px rgba(0,0,0,0.12)',
            }}>{p.i}</div>
            <div style={{ fontSize: 11, color: t.ink2, marginTop: 6, fontWeight: 600 }}>{p.label}</div>
          </div>
        ))}
        <div style={{
          position: 'absolute', left: 100, top: 130, width: 100, padding: 10,
          background: t.card, borderRadius: 12, boxShadow: t.shadow, border: `1px solid ${t.divider}`,
        }}>
          <div style={{ fontSize: 10, color: t.ink3, marginBottom: 4 }}>共有リスト</div>
          <div style={{ height: 2, background: t.divider, borderRadius: 2, marginBottom: 4 }}/>
          <div style={{ height: 2, background: t.divider, borderRadius: 2, width: '70%' }}/>
        </div>
      </div>
    );
  }
  // slide 3 — store nearby
  return (
    <div style={{ position: 'relative', width: 280, height: 300 }}>
      {/* map ish */}
      <div style={{
        position: 'absolute', inset: 0, borderRadius: 24, overflow: 'hidden',
        background: t.surface2, border: `1px solid ${t.divider}`,
      }}>
        {/* "roads" */}
        <div style={{ position: 'absolute', left: 40, top: 0, bottom: 0, width: 1, background: t.divider }}/>
        <div style={{ position: 'absolute', left: 0, right: 0, top: 130, height: 1, background: t.divider }}/>
        <div style={{ position: 'absolute', left: 180, top: 30, bottom: 60, width: 1, background: t.divider }}/>
      </div>
      <div style={{
        position: 'absolute', left: 130, top: 100,
        width: 60, height: 60, borderRadius: 60, background: t.accent + '22',
        animation: 'pulse 2.4s ease-out infinite',
      }}/>
      <div style={{
        position: 'absolute', left: 144, top: 114, width: 32, height: 32, borderRadius: 32,
        background: t.accent, display: 'flex', alignItems: 'center', justifyContent: 'center',
        boxShadow: '0 4px 12px rgba(194,65,12,0.3)',
      }}>
        <Icon name="store" size={16} stroke="#fff"/>
      </div>
      {/* notification */}
      <div style={{
        position: 'absolute', left: 8, bottom: 8, right: 8, padding: 12,
        background: t.card, borderRadius: 14, boxShadow: t.shadow, border: `1px solid ${t.divider}`,
        display: 'flex', alignItems: 'center', gap: 10,
      }}>
        <div style={{
          width: 32, height: 32, borderRadius: 9, background: t.accent,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <Icon name="cart" size={16} stroke="#fff"/>
        </div>
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 11, color: t.ink3, marginBottom: 1 }}>買い物リスト · いま</div>
          <div style={{ fontSize: 12, color: t.ink, fontWeight: 600 }}>イオン藤沢店の近く · 残り 5件</div>
        </div>
      </div>
    </div>
  );
}

// AUTH PAGE
function AuthPage({ t, state = 'idle' }) {
  return (
    <div style={{ background: t.surface, height: '100%', position: 'relative', overflow: 'hidden', display: 'flex', flexDirection: 'column' }}>
      <div style={{ paddingTop: 44, padding: '44px 16px 0' }}>
        <div style={{ height: 48, display: 'flex', alignItems: 'center', justifyContent: 'center', position: 'relative' }}>
          <button style={{ position: 'absolute', left: 0, background: 'transparent', border: 'none', color: t.ink2, padding: 8 }}>
            <Icon name="chev-l" size={22}/>
          </button>
          <span style={{ fontWeight: 600, fontSize: 17 }}>サインイン</span>
        </div>
      </div>
      <div style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '0 28px' }}>
        <AuthArt t={t}/>
      </div>
      <div style={{ padding: '0 28px 8px' }}>
        <div style={{ fontSize: 22, fontWeight: 700, color: t.ink, letterSpacing: -0.01, lineHeight: 1.3, marginBottom: 8 }}>
          家族の買い物を、<br/>ひとつのリストへ
        </div>
        <div style={{ fontSize: 13, color: t.ink2, lineHeight: 1.7 }}>
          サインインすると端末をまたいでリストが同期します。広告もメールマガジンもありません。
        </div>
      </div>
      <div style={{ padding: '20px 24px 36px', display: 'flex', flexDirection: 'column', gap: 10 }}>
        <button style={{
          height: 52, borderRadius: 14, background: '#000', color: '#fff', border: 'none',
          fontFamily: 'inherit', fontWeight: 600, fontSize: 15, display: 'flex', alignItems: 'center',
          justifyContent: 'center', gap: 8, cursor: 'pointer', position: 'relative',
        }}>
          <Icon name="apple" size={18} stroke="#fff" fill="#fff"/>
          {state === 'loading-apple' ? <span style={{ display: 'inline-block', width: 14, height: 14, border: '2px solid #fff', borderTopColor: 'transparent', borderRadius: 999, animation: 'spin 0.8s linear infinite' }}/> : 'Apple でサインイン'}
        </button>
        <button style={{
          height: 52, borderRadius: 14, background: t.surface2, color: t.ink, border: `1px solid ${t.divider}`,
          fontFamily: 'inherit', fontWeight: 600, fontSize: 15, display: 'flex', alignItems: 'center',
          justifyContent: 'center', gap: 10, cursor: 'pointer',
        }}>
          <Icon name="google" size={18}/>
          Google でサインイン
        </button>
        {state === 'error' && (
          <div style={{
            background: t.dangerSoft, color: t.danger, padding: '10px 12px', borderRadius: 10,
            fontSize: 12, fontWeight: 500, display: 'flex', alignItems: 'center', gap: 8,
          }}>
            <Icon name="x" size={14}/>サインインに失敗しました。もう一度お試しください。
          </div>
        )}
        <div style={{ fontSize: 11, color: t.ink3, lineHeight: 1.6, marginTop: 8, textAlign: 'center' }}>
          続けることで <span className="lk">利用規約</span> と <span className="lk">プライバシーポリシー</span> に同意したものとみなされます。
        </div>
      </div>
    </div>
  );
}

function AuthArt({ t }) {
  return (
    <div style={{ position: 'relative', width: 220, height: 220 }}>
      {/* paper bag */}
      <div style={{
        position: 'absolute', left: 30, top: 40, width: 160, height: 160,
        background: '#E8C896', borderRadius: '8px 8px 14px 14px',
        boxShadow: 'inset -10px 0 20px rgba(0,0,0,0.06), 0 12px 30px rgba(0,0,0,0.08)',
      }}>
        <div style={{ position: 'absolute', left: 0, right: 0, top: 0, height: 20, background: '#D4AF7A', borderRadius: '8px 8px 0 0' }}/>
        <div style={{ position: 'absolute', left: 30, right: 30, top: -16, height: 32, background: '#D4AF7A', borderRadius: '50% 50% 4px 4px' }}/>
      </div>
      {/* leaves poking out */}
      <div style={{ position: 'absolute', left: 70, top: 6, fontSize: 36, transform: 'rotate(-12deg)' }}>🥬</div>
      <div style={{ position: 'absolute', left: 130, top: 12, fontSize: 30, transform: 'rotate(20deg)' }}>🥖</div>
      <div style={{ position: 'absolute', left: 100, top: 20, fontSize: 28 }}>🍅</div>
      {/* tag */}
      <div style={{
        position: 'absolute', right: -8, top: 90,
        padding: '6px 10px', background: t.surface, borderRadius: 8,
        border: `1px solid ${t.divider}`, fontSize: 10, fontWeight: 600, color: t.ink2,
        transform: 'rotate(8deg)', boxShadow: t.shadow,
      }}>うちの買い物</div>
    </div>
  );
}

// HOME ROOT — appears as the main shell when settings tab selected
function HomeRoot({ t, tab = 'list' }) {
  return (
    <div style={{ background: t.surface, height: '100%', position: 'relative', overflow: 'hidden' }}>
      {tab === 'list' && <ShoppingListFlat t={t}/>}
      {tab === 'settings' && <SettingPage t={t}/>}
    </div>
  );
}

Object.assign(window, { Onboarding, OnboardingArt, AuthPage, AuthArt, HomeRoot });
