// screens-list.jsx — ShoppingListPage (final design)
// Layout: NavBar (status + title row) on paper · GroupChips + Filter + Progress + List on white · TabBar on paper

const ITEMS_FEW = [
  { id: 1, name: '牛乳 1L', cat: 'dairy', checked: false, note: '低脂肪じゃないやつ' },
  { id: 2, name: '卵 10個入り', cat: 'dairy', checked: true },
  { id: 3, name: 'トマト 4個', cat: 'veg', checked: false, photo: true },
  { id: 4, name: '玉ねぎ 大1袋', cat: 'veg', checked: false },
  { id: 5, name: '豚バラ 300g', cat: 'meat', checked: false },
  { id: 6, name: '食パン 6枚切', cat: 'bake', checked: true },
  { id: 7, name: 'コーヒー豆', cat: 'drink', checked: false, note: '中煎り、エチオピア' },
  { id: 8, name: '猫砂', cat: 'misc', checked: false },
];

const CATS = {
  dairy: { name: '乳製品・卵', color: '#E8B547', icon: '🥚' },
  veg:   { name: '野菜・果物', color: '#6BAA5E', icon: '🥕' },
  meat:  { name: '肉・魚', color: '#C05757', icon: '🐟' },
  bake:  { name: 'パン・米', color: '#B98A4C', icon: '🍞' },
  drink: { name: '飲み物', color: '#5A8AB5', icon: '☕' },
  misc:  { name: 'その他', color: '#8A8275', icon: '📦' },
};

// NavBar (paper colored) — status bar inset + title row
function ListNavBar({ t, name = 'うちの買い物' }) {
  return (
    <div style={{ background: t.surface, borderBottom: `0.5px solid ${t.divider}` }}>
      <div style={{ paddingTop: 44 }}/>
      <div style={{ height: 48, display: 'flex', alignItems: 'center', padding: '0 8px 8px 16px', gap: 4 }}>
        <button style={{
          display: 'flex', alignItems: 'center', gap: 4, background: 'transparent', border: 'none',
          padding: 0, color: t.ink, fontFamily: 'inherit', cursor: 'pointer',
        }}>
          <span style={{ fontWeight: 700, fontSize: 17, letterSpacing: -0.01 }}>{name}</span>
          <Icon name="chev-d" size={16} stroke={t.ink2}/>
        </button>
        <div style={{ flex: 1 }}/>
        <RoundBtn name="filter" t={t}/>
        <RoundBtn name="more-h" t={t}/>
      </div>
    </div>
  );
}

// Group chips — lives inside white content area
function GroupChipsRow({ t }) {
  return (
    <div className="no-scrollbar" style={{ display: 'flex', gap: 6, padding: '12px 16px 6px', overflowX: 'auto' }}>
      <Chip t={t} active soft icon="people">家族</Chip>
      <Chip t={t} icon="person">じぶん用</Chip>
      <Chip t={t} icon="people">ルームシェア</Chip>
      <Chip t={t} icon="plus">追加</Chip>
    </div>
  );
}

function ProgressBlock({ t, done, total }) {
  const pct = total === 0 ? 0 : (done / total) * 100;
  const allDone = done === total && total > 0;
  return (
    <div style={{ padding: '8px 20px 14px' }}>
      <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginBottom: 8 }}>
        <div style={{ display: 'flex', alignItems: 'baseline', gap: 8 }}>
          <span className="mono" style={{ fontSize: 24, fontWeight: 600, color: t.ink, letterSpacing: -0.02 }}>
            {done}<span style={{ color: t.ink3, fontWeight: 400 }}>/{total}</span>
          </span>
          <span style={{ fontSize: 12, color: t.ink2 }}>{allDone ? '完了!' : 'チェック済み'}</span>
        </div>
        {allDone && <span style={{ fontSize: 12, color: t.ok, fontWeight: 600 }}>✓ おつかれさま</span>}
      </div>
      <div style={{ height: 4, background: t.divider2, borderRadius: 4, overflow: 'hidden' }}>
        <div style={{
          height: '100%', width: `${pct}%`,
          background: allDone ? t.ok : t.accent, borderRadius: 4,
          transition: 'width 240ms',
        }}/>
      </div>
    </div>
  );
}

function FilterChips({ t, showChecked = true, byCategory = false }) {
  return (
    <div style={{ display: 'flex', gap: 6, padding: '0 16px 10px' }}>
      <Chip t={t} active={!showChecked} icon={showChecked ? undefined : 'check'} soft={!showChecked}>
        チェック済み {showChecked ? '表示' : '非表示'}
      </Chip>
      <Chip t={t} active={byCategory} icon={byCategory ? 'tag' : undefined} soft={byCategory}>
        {byCategory ? 'カテゴリ順' : 'リスト順'}
      </Chip>
    </div>
  );
}

// Single list row — TextField-as-row
function ItemRow({ item, t, focused, ghost, isEmpty, hint }) {
  if (ghost) {
    return (
      <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 20px', minHeight: 52, opacity: 0.5 }}>
        <Checkbox t={t} size={22}/>
        <span style={{ fontSize: 16, color: t.ink3, fontStyle: 'italic' }}>{hint || '新しいアイテム…'}</span>
      </div>
    );
  }
  if (isEmpty) {
    return (
      <div style={{
        display: 'flex', alignItems: 'center', gap: 12, padding: '12px 20px', minHeight: 52,
        background: focused ? t.accentSoft + '40' : 'transparent',
        borderLeft: focused ? `2px solid ${t.accent}` : '2px solid transparent',
      }}>
        <Checkbox t={t} size={22}/>
        <span style={{ fontSize: 16, color: t.ink3 }}>
          {focused ? '' : 'アイテムを入力…'}
          {focused && <span className="fake-caret"/>}
        </span>
      </div>
    );
  }
  const cat = CATS[item.cat];
  return (
    <div style={{
      display: 'flex', alignItems: 'flex-start', gap: 12, padding: '11px 20px', minHeight: 52,
      background: focused ? t.accentSoft + '60' : 'transparent',
      borderLeft: focused ? `2px solid ${t.accent}` : '2px solid transparent',
    }}>
      <div style={{ paddingTop: 1 }}>
        <Checkbox checked={item.checked} t={t} size={22} color={cat?.color}/>
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{
          fontSize: 16, color: item.checked ? t.checked : t.ink, fontWeight: 500,
          textDecoration: item.checked ? 'line-through' : 'none',
          textDecorationColor: t.ink4, letterSpacing: -0.01,
        }}>
          {item.name}{focused && <span className="fake-caret"/>}
        </div>
        {item.note && (
          <div style={{ fontSize: 12, color: t.ink3, marginTop: 2, opacity: item.checked ? 0.5 : 1 }}>
            {item.note}
          </div>
        )}
      </div>
      {item.photo && (
        <div style={{
          width: 40, height: 40, borderRadius: 10, flexShrink: 0,
          background: cat?.color + '30', border: `1px solid ${t.divider}`,
        }} className="stripe-ph"/>
      )}
      <button style={{
        background: 'transparent', border: 'none', color: t.ink3, padding: 4, cursor: 'pointer',
        marginTop: 2,
      }}>
        <Icon name="more-h" size={16}/>
      </button>
    </div>
  );
}

// FAB
function FAB({ t, label = '空行を追加', open = false }) {
  if (open) {
    return (
      <div style={{ position: 'absolute', right: 16, bottom: 90, zIndex: 25, display: 'flex', flexDirection: 'column', gap: 10, alignItems: 'flex-end' }}>
        {[
          { icon: 'image', label: '写真から追加', ai: true },
          { icon: 'link', label: 'URL から追加', ai: true },
          { icon: 'paste', label: 'テキスト貼り付け' },
          { icon: 'plus', label: '空行を追加', primary: true },
        ].map((a, i) => (
          <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <div style={{
              padding: '6px 12px', borderRadius: 999, background: t.ink, color: t.surface,
              fontSize: 12, fontWeight: 600, display: 'flex', gap: 6, alignItems: 'center',
            }}>
              {a.label}
              {a.ai && <span style={{ fontSize: 9, padding: '1px 6px', borderRadius: 999, background: t.accent, color: '#fff' }}>AI</span>}
            </div>
            <div style={{
              width: a.primary ? 56 : 44, height: a.primary ? 56 : 44, borderRadius: 999,
              background: a.primary ? t.accent : t.surface,
              border: a.primary ? 'none' : `1px solid ${t.divider}`,
              color: a.primary ? '#fff' : t.ink,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              boxShadow: '0 6px 14px rgba(27,24,19,0.12)',
            }}>
              <Icon name={a.icon} size={a.primary ? 24 : 18}/>
            </div>
          </div>
        ))}
      </div>
    );
  }
  return (
    <div style={{ position: 'absolute', right: 16, bottom: 90, zIndex: 25 }}>
      <button style={{
        width: 56, height: 56, borderRadius: 999, background: t.accent, color: '#fff', border: 'none',
        display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer',
        boxShadow: '0 6px 14px rgba(194,65,12,0.35), 0 1px 0 rgba(255,255,255,0.2) inset',
      }} title={label}>
        <Icon name="plus" size={26} sw={2.2}/>
      </button>
    </div>
  );
}

// Notify SnackBar
function NotifySnack({ t, members = ['M', 'K'], message = '「トマト」を追加' }) {
  return (
    <div style={{
      position: 'absolute', left: 16, right: 16, bottom: 156, zIndex: 24,
      background: t.ink, color: t.surface, borderRadius: 14,
      padding: '10px 12px', display: 'flex', alignItems: 'center', gap: 10,
      boxShadow: '0 10px 30px rgba(27,24,19,0.18)',
    }}>
      <Icon name="bell" size={16} stroke={t.surface}/>
      <div style={{ flex: 1, fontSize: 13, fontWeight: 500 }}>
        <div>{message}</div>
        <div style={{ fontSize: 11, opacity: 0.7 }}>グループに通知しますか?</div>
      </div>
      <div style={{ display: 'flex', gap: -6 }}>
        {members.map((m, i) => (
          <div key={i} style={{
            width: 26, height: 26, borderRadius: 999, background: ['#C2410C','#1F6B4E','#0F4C81'][i] || t.accent,
            color: '#fff', fontSize: 11, fontWeight: 700, display: 'flex', alignItems: 'center', justifyContent: 'center',
            border: `1.5px solid ${t.ink}`, marginLeft: i ? -6 : 0,
          }}>{m}</div>
        ))}
      </div>
      <button style={{
        background: t.accent, color: '#fff', border: 'none', borderRadius: 999,
        padding: '6px 12px', fontWeight: 700, fontSize: 12, cursor: 'pointer',
      }}>全員に通知</button>
    </div>
  );
}

// Shared shell wrapper: paper NavBar + white content + paper TabBar
function ListShell({ t, snack, children }) {
  return (
    <div style={{ background: t.surface, height: '100%', position: 'relative', overflow: 'hidden' }}>
      <ListNavBar t={t}/>
      <div style={{ background: t.card, minHeight: 'calc(100% - 200px)' }}>
        {children}
      </div>
      {snack && <NotifySnack t={t}/>}
      <TabBar t={t} active="list"/>
    </div>
  );
}

// SHOPPING LIST PAGE — flat with focused empty row at end
function ShoppingListFlat({ t, items = ITEMS_FEW, focusedIdx = items.length, snack = false }) {
  const total = items.length, done = items.filter(i => i.checked).length;
  return (
    <ListShell t={t} snack={snack}>
      <GroupChipsRow t={t}/>
      <FilterChips t={t}/>
      <ProgressBlock t={t} done={done} total={total}/>
      <div style={{ borderTop: `0.5px solid ${t.divider}`, paddingBottom: 100 }}>
        {items.map((it, i) => <ItemRow key={it.id} item={it} t={t} focused={i === focusedIdx}/>)}
        <ItemRow t={t} isEmpty focused={focusedIdx === items.length}/>
        <ItemRow t={t} ghost/>
      </div>
      <FAB t={t}/>
    </ListShell>
  );
}

// SHOPPING LIST PAGE — grouped by category
function ShoppingListByCategory({ t, items = ITEMS_FEW }) {
  const total = items.length, done = items.filter(i => i.checked).length;
  const groups = {};
  for (const it of items) (groups[it.cat] ||= []).push(it);
  const order = ['veg', 'meat', 'dairy', 'bake', 'drink', 'misc'];
  return (
    <ListShell t={t}>
      <GroupChipsRow t={t}/>
      <FilterChips t={t} byCategory/>
      <ProgressBlock t={t} done={done} total={total}/>
      <div style={{ borderTop: `0.5px solid ${t.divider}`, paddingBottom: 100 }}>
        {order.filter(k => groups[k]).map(k => (
          <div key={k}>
            <div style={{
              display: 'flex', alignItems: 'center', gap: 8,
              padding: '10px 20px 6px', background: t.card,
              fontSize: 11, fontWeight: 700, color: t.ink2, letterSpacing: 0.06, textTransform: 'uppercase',
            }}>
              <span style={{ width: 8, height: 8, borderRadius: 8, background: CATS[k].color }}/>
              <span>{CATS[k].name}</span>
              <span className="mono" style={{ color: t.ink3, fontWeight: 400, marginLeft: 'auto' }}>
                {groups[k].filter(i => i.checked).length}/{groups[k].length}
              </span>
            </div>
            {groups[k].map(it => <ItemRow key={it.id} item={it} t={t}/>)}
          </div>
        ))}
        <div style={{ marginTop: 12 }}>
          <ItemRow t={t} isEmpty focused/>
        </div>
      </div>
      <FAB t={t}/>
    </ListShell>
  );
}

// ALL DONE STATE
function ShoppingListAllDone({ t }) {
  const items = ITEMS_FEW.map(i => ({ ...i, checked: true }));
  const total = items.length, done = total;
  return (
    <ListShell t={t}>
      <GroupChipsRow t={t}/>
      <FilterChips t={t}/>
      <ProgressBlock t={t} done={done} total={total}/>
      <div style={{
        margin: '0 20px', padding: '14px 16px', borderRadius: 14,
        background: t.okSoft, color: t.ok, fontSize: 13, fontWeight: 600,
        display: 'flex', alignItems: 'center', gap: 10,
      }}>
        <span style={{ fontSize: 22 }}>🌿</span>
        <div>
          <div>全部チェック完了!</div>
          <div style={{ fontSize: 11, fontWeight: 400, opacity: 0.85, marginTop: 2 }}>
            お会計のあと、リストをアーカイブしますか?
          </div>
        </div>
      </div>
      <div style={{ borderTop: `0.5px solid ${t.divider}`, marginTop: 14, paddingBottom: 100 }}>
        {items.map(it => <ItemRow key={it.id} item={it} t={t}/>)}
      </div>
      <FAB t={t}/>
    </ListShell>
  );
}

// EMPTY STATE — list has no items
function ShoppingListEmpty({ t }) {
  return (
    <ListShell t={t}>
      <GroupChipsRow t={t}/>
      <FilterChips t={t}/>
      <ProgressBlock t={t} done={0} total={0}/>
      <div style={{ borderTop: `0.5px solid ${t.divider}`, paddingTop: 6, paddingBottom: 200 }}>
        <ItemRow t={t} isEmpty focused/>
        {[0,1,2,3,4].map(i => <ItemRow key={i} t={t} ghost hint={i === 0 ? '例: 牛乳 1L' : undefined}/>)}
      </div>
      <div style={{
        position: 'absolute', left: 20, right: 20, bottom: 170,
        padding: 14, borderRadius: 14,
        background: t.surface2, border: `1px dashed ${t.divider}`,
        fontSize: 12, color: t.ink2, lineHeight: 1.6,
      }}>
        <div style={{ fontWeight: 600, color: t.ink, marginBottom: 4, fontSize: 13 }}>そのまま入力できます</div>
        空行をタップして名前を打ち、<span className="mono" style={{ background: t.surface, padding: '1px 6px', borderRadius: 4, border: `1px solid ${t.divider}` }}>return</span> で次の行へ。空行で <span className="mono" style={{ background: t.surface, padding: '1px 6px', borderRadius: 4, border: `1px solid ${t.divider}` }}>delete</span> で行を消せます。
      </div>
      <FAB t={t}/>
    </ListShell>
  );
}

// AI Processing state
function ShoppingListAIProcessing({ t }) {
  const total = ITEMS_FEW.length, done = ITEMS_FEW.filter(i => i.checked).length;
  return (
    <ListShell t={t}>
      <GroupChipsRow t={t}/>
      <FilterChips t={t}/>
      <ProgressBlock t={t} done={done} total={total}/>
      <div style={{
        margin: '0 16px 12px', padding: 14, borderRadius: 14,
        background: t.accentSoft, display: 'flex', alignItems: 'center', gap: 12,
      }}>
        <div style={{
          width: 44, height: 44, borderRadius: 12, background: '#fff',
          display: 'flex', alignItems: 'center', justifyContent: 'center', position: 'relative',
        }} className="stripe-ph">
          <div style={{
            position: 'absolute', inset: 0, borderRadius: 12,
            border: `2px solid ${t.accent}`, borderTopColor: 'transparent',
            animation: 'spin 1s linear infinite',
          }}/>
        </div>
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 13, fontWeight: 700, color: t.dark ? t.accentInk : t.accent, display: 'flex', alignItems: 'center', gap: 6 }}>
            <Icon name="wand" size={14}/>写真からアイテムを生成中
          </div>
          <div style={{ fontSize: 11, color: t.ink2, marginTop: 2 }}>レシート 1枚 ・ 候補を抽出しています…</div>
        </div>
        <button style={{ background: 'transparent', border: 'none', color: t.ink3, fontSize: 12, fontWeight: 600 }}>キャンセル</button>
      </div>
      <div style={{ borderTop: `0.5px solid ${t.divider}`, paddingBottom: 100 }}>
        {ITEMS_FEW.map(it => <ItemRow key={it.id} item={it} t={t}/>)}
        {[0,1,2].map(i => (
          <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 20px', opacity: 1 - i * 0.2 }}>
            <Checkbox t={t}/>
            <div className="stripe-ph" style={{ height: 14, width: `${65 - i * 12}%`, borderRadius: 4 }}/>
          </div>
        ))}
      </div>
    </ListShell>
  );
}

// ERROR STATE
function ShoppingListError({ t }) {
  return (
    <ListShell t={t}>
      <div style={{
        margin: '40px 24px', padding: '24px 18px', borderRadius: 18,
        background: t.dangerSoft, textAlign: 'center',
      }}>
        <div style={{ fontSize: 32, marginBottom: 8 }}>📡</div>
        <div style={{ fontSize: 15, fontWeight: 700, color: t.danger }}>リストを読み込めませんでした</div>
        <div style={{ fontSize: 12, color: t.ink2, marginTop: 4, lineHeight: 1.6 }}>
          通信状態を確認してください。<br/>もう一度お試しいただくか、しばらくしてから開き直してください。
        </div>
        <div style={{ display: 'flex', gap: 8, justifyContent: 'center', marginTop: 14 }}>
          <Pill t={t} ghost>サポートに連絡</Pill>
          <Pill t={t} accent>再試行</Pill>
        </div>
      </div>
    </ListShell>
  );
}

// FREE PLAN NOTICE BANNER variant
function ShoppingListFreeNotice({ t }) {
  const items = Array.from({ length: 12 }, (_, i) => ({
    id: i + 100,
    name: ['牛乳','卵','トマト','玉ねぎ','豚バラ','食パン','コーヒー豆','猫砂','洗剤','歯磨き粉','バナナ','ヨーグルト'][i],
    cat: ['dairy','dairy','veg','veg','meat','bake','drink','misc','misc','misc','veg','dairy'][i],
    checked: i < 4,
  }));
  const total = items.length, done = items.filter(i => i.checked).length;
  return (
    <ListShell t={t}>
      <GroupChipsRow t={t}/>
      <FilterChips t={t}/>
      <ProgressBlock t={t} done={done} total={total}/>
      <div style={{
        margin: '0 16px 10px', padding: '10px 12px', borderRadius: 12,
        background: t.surface2, border: `1px solid ${t.divider}`,
        fontSize: 11.5, color: t.ink2, display: 'flex', alignItems: 'center', gap: 10,
      }}>
        <Icon name="crown" size={14} stroke={t.accent}/>
        <div style={{ flex: 1 }}>無料プランは作成から30日でリストが整理されます</div>
        <span style={{ color: t.accent, fontWeight: 700, fontSize: 12 }}>詳しく</span>
      </div>
      <div style={{ borderTop: `0.5px solid ${t.divider}`, paddingBottom: 100 }}>
        {items.map(it => <ItemRow key={it.id} item={it} t={t}/>)}
      </div>
      <FAB t={t}/>
    </ListShell>
  );
}

Object.assign(window, {
  ShoppingListFlat, ShoppingListByCategory, ShoppingListAllDone,
  ShoppingListEmpty, ShoppingListAIProcessing, ShoppingListError,
  ShoppingListFreeNotice,
  ListNavBar, GroupChipsRow, ProgressBlock, FilterChips, ListShell,
  ItemRow, FAB, NotifySnack, CATS, ITEMS_FEW,
});
