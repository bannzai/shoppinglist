// app.jsx — main canvas composition

const { useState } = React;

const DEFAULTS = /*EDITMODE-BEGIN*/{
  "dark": false,
  "accent": "shu",
  "snack": false
}/*EDITMODE-END*/;

function App() {
  const [tw, setTweak] = useTweaks(DEFAULTS);
  const t = mkTheme(tw.dark, tw.accent);

  return (
    <>
      <DesignCanvas
        title="買い物リスト · UI 再設計"
        subtitle="家族と作る買い物リスト · iPhone 中心 + iOS/Android ウィジェット · 全17画面 + 状態 + マイクロインタラクション"
        background={t.paper}
        textColor={t.ink}
      >
        {/* SECTION: System overview */}
        <DCSection id="00-overview" title="00 — デザインシステム">
          <DCArtboard id="ds-summary" label="トーン & 色 / 型 / プリンシプル" width={1320} height={520}>
            <SystemSummary t={t}/>
          </DCArtboard>
        </DCSection>

        {/* SECTION: Onboarding & Auth */}
        <DCSection id="01-entry" title="01 — オンボーディング・サインイン・タブルート">
          <DCArtboard id="01-onboarding-1" label="OnboardingPage · スライド 1 / 3" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.surface}><Onboarding t={t} slide={1}/></Phone>
          </DCArtboard>
          <DCArtboard id="01-onboarding-2" label="OnboardingPage · スライド 2 / 3" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.surface}><Onboarding t={t} slide={2}/></Phone>
          </DCArtboard>
          <DCArtboard id="01-onboarding-3" label="OnboardingPage · スライド 3 / 3" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.surface}><Onboarding t={t} slide={3}/></Phone>
          </DCArtboard>
          <DCArtboard id="02-auth" label="AuthPage · 通常" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.surface}><AuthPage t={t}/></Phone>
          </DCArtboard>
          <DCArtboard id="02-auth-loading" label="AuthPage · 認証中" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.surface}><AuthPage t={t} state="loading-apple"/></Phone>
          </DCArtboard>
          <DCArtboard id="02-auth-error" label="AuthPage · エラー" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.surface}><AuthPage t={t} state="error"/></Phone>
          </DCArtboard>
          <DCArtboard id="03-home" label="HomePage · タブ = 買い物リスト" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.surface}><HomeRoot t={t} tab="list"/></Phone>
          </DCArtboard>
          <DCArtboard id="03-home-settings" label="HomePage · タブ = 設定" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.surface}><HomeRoot t={t} tab="settings"/></Phone>
          </DCArtboard>
        </DCSection>

        {/* SECTION: ShoppingListPage — the heart */}
        <DCSection id="04-list" title="04 — ShoppingListPage（中核 UX · 連続入力 TextField 行）">
          <DCArtboard id="04-flat" label="数件・フラット表示・末尾の空行にフォーカス" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.surface}><ShoppingListFlat t={t} snack={tw.snack}/></Phone>
          </DCArtboard>
          <DCArtboard id="04-bycat" label="カテゴリ順表示" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.surface}><ShoppingListByCategory t={t}/></Phone>
          </DCArtboard>
          <DCArtboard id="04-empty" label="0件・初期状態（空行に直接入力）" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.surface}><ShoppingListEmpty t={t}/></Phone>
          </DCArtboard>
          <DCArtboard id="04-alldone" label="全チェック済み・「完了!」" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.surface}><ShoppingListAllDone t={t}/></Phone>
          </DCArtboard>
          <DCArtboard id="04-ai" label="AI 処理中（写真→アイテム）" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.surface}><ShoppingListAIProcessing t={t}/></Phone>
          </DCArtboard>
          <DCArtboard id="04-error" label="エラー（読み込み失敗）" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.surface}><ShoppingListError t={t}/></Phone>
          </DCArtboard>
          <DCArtboard id="04-50plus" label="50件超 + 無料プラン保持期間表示" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.surface}><ShoppingListFreeNotice t={t}/></Phone>
          </DCArtboard>
          <DCArtboard id="04-snack" label="メンバー通知 SnackBar 表示" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.surface}><ShoppingListFlat t={t} snack/></Phone>
          </DCArtboard>
        </DCSection>

        {/* SECTION: List settings + filter */}
        <DCSection id="05-list-cfg" title="05 — リスト設定・フィルター">
          <DCArtboard id="05-list-setting" label="ShoppingListSettingPage" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.paper}><ShoppingListSettingPage t={t}/></Phone>
          </DCArtboard>
          <DCArtboard id="05-list-invite" label="招待コード dialog" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.paper}><ShoppingListSettingPage t={t} state="invite"/></Phone>
          </DCArtboard>
          <DCArtboard id="05-list-delete" label="削除確認 dialog" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.paper}><ShoppingListSettingPage t={t} state="delete"/></Phone>
          </DCArtboard>
          <DCArtboard id="06-filter" label="ShoppingListItemFilterPage" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.paper}><FilterPage t={t}/></Phone>
          </DCArtboard>
          <DCArtboard id="06-filter-disabled" label="フィルター・カテゴリなし" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.paper}><FilterPage t={t} hasCategory={false}/></Phone>
          </DCArtboard>
        </DCSection>

        {/* SECTION: Groups */}
        <DCSection id="07-groups" title="07 — グループ管理・作成・設定・参加">
          <DCArtboard id="07-grp-list" label="GroupListPage · 複数" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.paper}><GroupListPage t={t}/></Phone>
          </DCArtboard>
          <DCArtboard id="07-grp-list-locked" label="GroupListPage · 無料上限" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.paper}><GroupListPage t={t} state="free-limit"/></Phone>
          </DCArtboard>
          <DCArtboard id="08-grp-create" label="GroupCreatePage" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.paper}><GroupCreatePage t={t}/></Phone>
          </DCArtboard>
          <DCArtboard id="09-grp-set" label="GroupSettingPage · オーナー" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.paper}><GroupSettingPage t={t} role="owner"/></Phone>
          </DCArtboard>
          <DCArtboard id="10-grp-accept" label="GroupInvitationAcceptPage · 入力" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.paper}><GroupInvitationAcceptPage t={t} state="valid"/></Phone>
          </DCArtboard>
          <DCArtboard id="10-grp-accept-err" label="参加 · 不正コード" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.paper}><GroupInvitationAcceptPage t={t} state="invalid"/></Phone>
          </DCArtboard>
        </DCSection>

        {/* SECTION: Categories + locations */}
        <DCSection id="11-cat-loc" title="11 — カテゴリ・買い物場所・地図">
          <DCArtboard id="11-cat-list" label="GroupCategoryPage" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.paper}><GroupCategoryPage t={t}/></Phone>
          </DCArtboard>
          <DCArtboard id="12-cat-edit" label="GroupCategoryEditPage" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.paper}><GroupCategoryEditPage t={t}/></Phone>
          </DCArtboard>
          <DCArtboard id="13-loc-list" label="ShoppingLocationPage" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.paper}><ShoppingLocationPage t={t}/></Phone>
          </DCArtboard>
          <DCArtboard id="13-loc-empty" label="場所なし" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.paper}><ShoppingLocationPage t={t} state="empty"/></Phone>
          </DCArtboard>
          <DCArtboard id="13-loc-add" label="場所追加 dialog" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.paper}><ShoppingLocationPage t={t} state="add"/></Phone>
          </DCArtboard>
          <DCArtboard id="14-loc-pick" label="LocationPickerPage" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.paper}><LocationPickerPage t={t}/></Phone>
          </DCArtboard>
          <DCArtboard id="14-loc-pick-loading" label="LocationPicker · 住所取得中" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.paper}><LocationPickerPage t={t} state="loading"/></Phone>
          </DCArtboard>
        </DCSection>

        {/* SECTION: Settings + premium */}
        <DCSection id="15-settings" title="15 — 設定・テーマ色・プレミアム">
          <DCArtboard id="15-settings-free" label="SettingPage · 無料" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.paper}><SettingPage t={t} state="free"/></Phone>
          </DCArtboard>
          <DCArtboard id="15-settings-premium" label="SettingPage · プレミアム" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.paper}><SettingPage t={t} state="premium"/></Phone>
          </DCArtboard>
          <DCArtboard id="16-theme" label="ThemeColorSelectionPage" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.paper}><ThemeColorSelectionPage t={t}/></Phone>
          </DCArtboard>
          <DCArtboard id="17-paywall-plans" label="PaywallPage · プラン表示" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.paper}><PaywallPage t={t} state="plans"/></Phone>
          </DCArtboard>
          <DCArtboard id="17-paywall-loading" label="PaywallPage · 価格ロード中" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.paper}><PaywallPage t={t} state="loading"/></Phone>
          </DCArtboard>
          <DCArtboard id="17-paywall-error" label="PaywallPage · 取得失敗" width={390} height={844}>
            <Phone t={t} dark={tw.dark} bg={t.paper}><PaywallPage t={t} state="error"/></Phone>
          </DCArtboard>
        </DCSection>

        {/* SECTION: Dark mode showcase */}
        <DCSection id="dark" title="DARK — 中核画面のダーク表示">
          <DCArtboard id="d-list" label="ShoppingListPage · ダーク" width={390} height={844}>
            <Phone t={mkTheme(true, tw.accent)} dark bg={mkTheme(true).surface}>
              <ShoppingListFlat t={mkTheme(true, tw.accent)}/>
            </Phone>
          </DCArtboard>
          <DCArtboard id="d-bycat" label="カテゴリ順 · ダーク" width={390} height={844}>
            <Phone t={mkTheme(true, tw.accent)} dark bg={mkTheme(true).surface}>
              <ShoppingListByCategory t={mkTheme(true, tw.accent)}/>
            </Phone>
          </DCArtboard>
          <DCArtboard id="d-onboarding" label="Onboarding · ダーク" width={390} height={844}>
            <Phone t={mkTheme(true, tw.accent)} dark bg={mkTheme(true).surface}>
              <Onboarding t={mkTheme(true, tw.accent)} slide={3}/>
            </Phone>
          </DCArtboard>
          <DCArtboard id="d-paywall" label="Paywall · ダーク" width={390} height={844}>
            <Phone t={mkTheme(true, tw.accent)} dark bg={mkTheme(true).paper}>
              <PaywallPage t={mkTheme(true, tw.accent)}/>
            </Phone>
          </DCArtboard>
          <DCArtboard id="d-settings" label="Setting · ダーク" width={390} height={844}>
            <Phone t={mkTheme(true, tw.accent)} dark bg={mkTheme(true).paper}>
              <SettingPage t={mkTheme(true, tw.accent)} state="premium"/>
            </Phone>
          </DCArtboard>
        </DCSection>

        {/* SECTION: Widgets */}
        <DCSection id="widgets" title="ホーム画面ウィジェット — iOS small / medium / large + Android">
          <DCArtboard id="w-bg" label="ホーム画面に並べたウィジェット" width={1320} height={620}>
            <WidgetShowcase t={t} accent={ACCENT_PRESETS[tw.accent].light}/>
          </DCArtboard>
        </DCSection>

        {/* SECTION: Microinteractions */}
        <DCSection id="micro" title="主要マイクロインタラクション">
          <DCArtboard id="m-enter" label="連続入力 (return → 次行)" width={840} height={300}>
            <MicroEnterFlow t={t}/>
          </DCArtboard>
          <DCArtboard id="m-check" label="チェックの手応え" width={500} height={260}>
            <MicroCheckFeedback t={t}/>
          </DCArtboard>
          <DCArtboard id="m-ai" label="AI 認識・処理中" width={500} height={300}>
            <MicroAIProgress t={t}/>
          </DCArtboard>
          <DCArtboard id="m-snack" label="メンバー通知 SnackBar" width={500} height={220}>
            <MicroNotifySnack t={t}/>
          </DCArtboard>
        </DCSection>
      </DesignCanvas>

      <TweaksPanel title="Tweaks">
        <TweakSection title="表示">
          <TweakToggle label="ダークモード" value={tw.dark} onChange={v => setTweak('dark', v)}/>
          <TweakToggle label="メンバー通知 SnackBar を表示" value={tw.snack} onChange={v => setTweak('snack', v)}/>
        </TweakSection>
        <TweakSection title="シードカラー (和の伝統色)">
          <TweakColor
            label="アクセント"
            value={ACCENT_PRESETS[tw.accent].light}
            options={Object.values(ACCENT_PRESETS).map(p => p.light)}
            onChange={(v) => {
              const key = Object.keys(ACCENT_PRESETS).find(k => ACCENT_PRESETS[k].light === v) || 'shu';
              setTweak('accent', key);
            }}
          />
          <div style={{ fontSize: 11, color: '#5A5246', padding: '4px 8px', lineHeight: 1.5 }}>
            朱・抹茶・藍・墨・朽葉
          </div>
        </TweakSection>
      </TweaksPanel>
    </>
  );
}

function SystemSummary({ t }) {
  return (
    <div style={{ padding: 32, height: '100%', boxSizing: 'border-box', display: 'flex', gap: 32, fontFamily: '"Noto Sans JP"' }}>
      {/* Left — copy */}
      <div style={{ flex: 1.2, display: 'flex', flexDirection: 'column', gap: 18 }}>
        <div>
          <div className="mono" style={{ fontSize: 11, color: t.accent, fontWeight: 600, letterSpacing: 0.6, textTransform: 'uppercase' }}>
            DESIGN PRINCIPLES
          </div>
          <h1 className="serif" style={{ fontSize: 38, fontWeight: 800, letterSpacing: -0.02, color: t.ink, margin: '6px 0 0', lineHeight: 1.15 }}>
            買い物中の「見る・<br/>追加する・チェック」を<br/>最短に。
          </h1>
        </div>
        <p style={{ fontSize: 14, color: t.ink2, lineHeight: 1.8, maxWidth: 460, textWrap: 'pretty', margin: 0 }}>
          リスト行そのものが TextField。タップで即編集、return で次の空行へ移動しながら連続入力でき、空行で delete を押すとその行が消えます。1件ずつの追加に FAB から毎回モーダルを開かせない、軽い道具のような体験を目指しました。
        </p>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: 10, maxWidth: 460 }}>
          {[
            ['片手・親指で届く', 'AppBar下のチップ + 末尾FAB'],
            ['共有はあるが監視しない', '通知は手動 / 自動を選べる'],
            ['AIは「写真・URL」のみ', 'テキスト貼り付けはAIにしない'],
            ['暮らしの色 · 朱', 'プレミアムで10色から選べる'],
          ].map((r, i) => (
            <div key={i} style={{ background: t.surface2, border: `1px solid ${t.divider}`, borderRadius: 10, padding: '10px 12px' }}>
              <div style={{ fontSize: 12, color: t.ink, fontWeight: 700 }}>{r[0]}</div>
              <div style={{ fontSize: 11, color: t.ink3, marginTop: 2 }}>{r[1]}</div>
            </div>
          ))}
        </div>
      </div>
      {/* Right — tokens */}
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 18 }}>
        {/* Color */}
        <div style={{ background: t.card, borderRadius: 14, padding: 18, border: `1px solid ${t.divider}` }}>
          <div className="mono" style={{ fontSize: 10, color: t.ink3, letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 10 }}>Palette · 暖色ニュートラル</div>
          <div style={{ display: 'flex', gap: 8, marginBottom: 10 }}>
            {[t.paper, t.surface, t.surface2, t.card, t.ink, t.ink2, t.ink3].map((c, i) => (
              <div key={i} style={{ flex: 1 }}>
                <div style={{ height: 56, borderRadius: 8, background: c, border: `1px solid ${t.divider}` }}/>
                <div className="mono" style={{ fontSize: 9, color: t.ink3, marginTop: 4, textAlign: 'center' }}>{c}</div>
              </div>
            ))}
          </div>
          <div className="mono" style={{ fontSize: 10, color: t.ink3, letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 8 }}>Accent · 朱（和の伝統色）</div>
          <div style={{ display: 'flex', gap: 8 }}>
            {Object.values(ACCENT_PRESETS).map((p, i) => (
              <div key={i} style={{ flex: 1 }}>
                <div style={{ height: 36, borderRadius: 8, background: p.light, border: '1px solid rgba(0,0,0,0.06)' }}/>
                <div className="serif" style={{ fontSize: 11, color: t.ink2, marginTop: 4, textAlign: 'center', fontWeight: 600 }}>{p.name}</div>
              </div>
            ))}
          </div>
        </div>
        {/* Type */}
        <div style={{ background: t.card, borderRadius: 14, padding: 18, border: `1px solid ${t.divider}` }}>
          <div className="mono" style={{ fontSize: 10, color: t.ink3, letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 10 }}>Type</div>
          <div style={{ fontSize: 28, fontWeight: 800, color: t.ink, letterSpacing: -0.02, lineHeight: 1.15 }}>家族と作る、買い物リスト</div>
          <div style={{ fontSize: 12, color: t.ink3, marginTop: 4 }}>Noto Sans JP — 800 Display / 600 UI / 500 Body</div>
          <div className="mono" style={{ fontSize: 14, color: t.ink2, marginTop: 10, fontWeight: 500 }}>
            6/8 · X9KP-2H4M · ¥3,800/年
          </div>
          <div style={{ fontSize: 11, color: t.ink3 }}>IBM Plex Mono — 数値・コード</div>
        </div>
      </div>
    </div>
  );
}

function WidgetShowcase({ t, accent }) {
  return (
    <div style={{
      padding: 32, height: '100%', boxSizing: 'border-box',
      display: 'flex', gap: 24, alignItems: 'center', justifyContent: 'center',
      background: t.paper,
    }}>
      <IOSWidget size="small" t={t} accent={accent}/>
      <IOSWidget size="medium" t={t} accent={accent}/>
      <IOSWidget size="large" t={t} accent={accent}/>
      <AndroidWidget accent={accent}/>
    </div>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App/>);
