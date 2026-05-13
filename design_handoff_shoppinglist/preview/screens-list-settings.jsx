// screens-list-settings.jsx — ShoppingListSettingPage(5), Filter(6)

function ShoppingListSettingPage({ t, state = 'idle' }) {
  return (
    <div style={{ background: t.paper, height: '100%', position: 'relative', overflow: 'auto' }}>
      <AppBar title="買い物リスト設定" t={t}
        leading={<RoundBtn name="x" t={t}/>}
        bg={t.paper}
      />
      <div style={{ padding: '14px 16px 100px', display: 'flex', flexDirection: 'column', gap: 14 }}>
        {/* List name */}
        <Section t={t} label="リスト名">
          <div style={{ padding: '12px 16px', background: t.card, borderRadius: 14 }}>
            <input defaultValue="うちの買い物" style={{
              width: '100%', border: 'none', background: 'transparent', outline: 'none',
              fontFamily: 'inherit', fontSize: 16, fontWeight: 500, color: t.ink, padding: 0,
            }}/>
          </div>
          <div style={{ fontSize: 11, color: t.ink3, padding: '4px 12px' }}>確定キーで保存されます</div>
        </Section>
        {/* Place */}
        <Section t={t} label="買い物する場所">
          <Cell t={t} title="イオン藤沢店" detail="変更" icon={{ name: 'pin-fill', color: t.accent }}/>
        </Section>
        {/* Storage */}
        <Section t={t} label="保存期間">
          <div style={{
            padding: '14px 16px', background: t.card, borderRadius: 14,
            display: 'flex', alignItems: 'center', gap: 12,
          }}>
            <div style={{
              width: 36, height: 36, borderRadius: 10, background: t.surface2,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <Icon name="doc" size={18} stroke={t.ink2}/>
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14, color: t.ink, fontWeight: 600 }}>作成から30日間</div>
              <div style={{ fontSize: 11.5, color: t.ink3, marginTop: 2 }}>プレミアムなら期限なしで残せます</div>
            </div>
            <Pill t={t} soft icon="crown">アップグレード</Pill>
          </div>
        </Section>
        {/* Invitation */}
        <Section t={t} label="共有">
          <div style={{ background: t.card, borderRadius: 14, overflow: 'hidden' }}>
            <Cell t={t} title="グループに招待コードを送る" icon={{ name: 'person-add', color: t.accent }}
              detail={state === 'generating' ? <Spinner t={t}/> : undefined}/>
            <Divider t={t}/>
            <Cell t={t} title="グループ設定" icon={{ name: 'people', color: t.ink2 }}/>
          </div>
        </Section>
        {/* Delete */}
        <Section t={t} label="">
          <button style={{
            width: '100%', padding: '14px 16px', background: t.dangerSoft, color: t.danger,
            borderRadius: 14, border: 'none', fontFamily: 'inherit', fontWeight: 600, fontSize: 15,
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8, cursor: 'pointer',
          }}>
            <Icon name="trash" size={16}/>このリストを削除
          </button>
        </Section>
      </div>
      {state === 'invite' && <InviteCodeDialog t={t}/>}
      {state === 'delete' && <DeleteConfirmDialog t={t}/>}
    </div>
  );
}

function Section({ t, label, children }) {
  return (
    <div>
      {label && <div style={{ fontSize: 11, fontWeight: 700, color: t.ink2, padding: '0 12px 6px', letterSpacing: 0.05, textTransform: 'uppercase' }}>{label}</div>}
      {children}
    </div>
  );
}

function Cell({ t, title, detail, sub, icon, switch: sw, swOn, danger, disabled }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 12,
      padding: '13px 16px', minHeight: 52, background: t.card,
      opacity: disabled ? 0.5 : 1,
    }}>
      {icon && (
        <div style={{
          width: 32, height: 32, borderRadius: 9, background: t.surface2,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <Icon name={icon.name} size={16} stroke={icon.color || t.ink2}/>
        </div>
      )}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 15, color: danger ? t.danger : t.ink, fontWeight: 500 }}>{title}</div>
        {sub && <div style={{ fontSize: 12, color: t.ink3, marginTop: 2 }}>{sub}</div>}
      </div>
      {sw && (
        <div style={{
          width: 44, height: 26, borderRadius: 26,
          background: swOn ? t.accent : t.divider, position: 'relative',
        }}>
          <div style={{
            position: 'absolute', top: 2, left: swOn ? 20 : 2, width: 22, height: 22, borderRadius: 22,
            background: '#fff', boxShadow: '0 1px 3px rgba(0,0,0,0.2)', transition: 'left 160ms',
          }}/>
        </div>
      )}
      {!sw && detail && <span style={{ fontSize: 13, color: t.ink3 }}>{detail}</span>}
      {!sw && <Icon name="chev-r" size={14} stroke={t.ink4}/>}
    </div>
  );
}

function Divider({ t, inset = 60 }) {
  return <div style={{ height: 0.5, background: t.divider, marginLeft: inset }}/>;
}

function Spinner({ t, size = 16 }) {
  return <div style={{
    width: size, height: size, border: `2px solid ${t.divider}`,
    borderTopColor: t.accent, borderRadius: 999, animation: 'spin 0.8s linear infinite', display: 'inline-block',
  }}/>;
}

function InviteCodeDialog({ t }) {
  return (
    <DialogShell t={t}>
      <div style={{ textAlign: 'center', padding: '24px 24px 8px' }}>
        <div style={{ fontSize: 13, color: t.ink2, marginBottom: 8, fontWeight: 600 }}>招待コード</div>
        <div className="mono" style={{
          fontSize: 36, fontWeight: 600, letterSpacing: 8, color: t.ink,
          background: t.surface2, padding: '14px 12px', borderRadius: 14, border: `1px dashed ${t.divider}`,
        }}>X9KP-2H4M</div>
        <div style={{ fontSize: 12, color: t.ink3, marginTop: 10 }}>有効期限: 7日間 ・ 残り 6日23時間</div>
      </div>
      <div style={{ display: 'flex', gap: 8, padding: 16 }}>
        <Pill t={t} ghost lg style={{ flex: 1 }} icon="copy">コピー</Pill>
        <Pill t={t} accent lg style={{ flex: 1 }} icon="send">共有</Pill>
      </div>
    </DialogShell>
  );
}

function DeleteConfirmDialog({ t }) {
  return (
    <DialogShell t={t}>
      <div style={{ padding: '24px 24px 8px', textAlign: 'center' }}>
        <div style={{ fontSize: 17, fontWeight: 700, color: t.ink, marginBottom: 6 }}>このリストを削除しますか?</div>
        <div style={{ fontSize: 13, color: t.ink2, lineHeight: 1.6 }}>
          「うちの買い物」とその中の <span className="mono">{8}件</span> のアイテムが削除されます。元に戻せません。
        </div>
      </div>
      <div style={{ display: 'flex', gap: 8, padding: 16 }}>
        <Pill t={t} ghost lg style={{ flex: 1 }}>キャンセル</Pill>
        <Pill t={t} lg style={{ flex: 1, background: t.danger, color: '#fff' }}>削除</Pill>
      </div>
    </DialogShell>
  );
}

function DialogShell({ t, children }) {
  return (
    <>
      <div style={{ position: 'absolute', inset: 0, background: 'rgba(15,12,8,0.4)', zIndex: 60, backdropFilter: 'blur(2px)' }}/>
      <div style={{
        position: 'absolute', left: 24, right: 24, top: '32%', zIndex: 61,
        background: t.card, borderRadius: 20, overflow: 'hidden',
        boxShadow: '0 30px 60px rgba(0,0,0,0.25)',
      }}>
        {children}
      </div>
    </>
  );
}

// FILTER PAGE (6)
function FilterPage({ t, hasCategory = true }) {
  return (
    <div style={{ background: t.paper, height: '100%', position: 'relative', overflow: 'auto' }}>
      <AppBar title="フィルター" t={t} leading={<RoundBtn name="x" t={t}/>} bg={t.paper}/>
      <div style={{ padding: '14px 16px', display: 'flex', flexDirection: 'column', gap: 14 }}>
        <div style={{ background: t.card, borderRadius: 14, overflow: 'hidden' }}>
          <Cell t={t} title="チェック済みを表示" sub="買い終わったアイテムも一覧に残します"
            switch swOn icon={{ name: 'check', color: t.ok }}/>
          <Divider t={t}/>
          <Cell t={t} title="カテゴリ順で表示" sub={hasCategory ? '店舗の並び順で見やすく' : 'カテゴリが登録されていません'}
            switch swOn={hasCategory} icon={{ name: 'tag', color: hasCategory ? t.accent : t.ink3 }} disabled={!hasCategory}/>
        </div>
        <div style={{
          padding: 14, background: t.surface2, borderRadius: 14,
          fontSize: 12, color: t.ink2, lineHeight: 1.6, border: `1px solid ${t.divider}`,
        }}>
          <div style={{ fontWeight: 700, color: t.ink, marginBottom: 4, fontSize: 13 }}>ヒント</div>
          リスト画面のチップからも素早く切り替えられます。
        </div>
      </div>
    </div>
  );
}

Object.assign(window, {
  ShoppingListSettingPage, FilterPage, Section, Cell, Divider, Spinner,
  InviteCodeDialog, DeleteConfirmDialog, DialogShell,
});
