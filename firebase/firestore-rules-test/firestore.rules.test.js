const fs = require('fs');
const path = require('path');
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');
const { doc, getDoc, setDoc, updateDoc, deleteDoc } = require('firebase/firestore');

// demo- 接頭辞により Emulator が demo モード (実プロジェクト不要) で動作する。
// package.json の `firebase emulators:exec --project demo-shoppinglist` と一致させる。
const PROJECT_ID = 'demo-shoppinglist';
const RULES_PATH = path.resolve(__dirname, '..', 'firestore.rules');

// emulators:exec が子プロセスに設定する FIRESTORE_EMULATOR_HOST ("host:port") から接続先を得る。
const [EMULATOR_HOST, EMULATOR_PORT] = (
  process.env.FIRESTORE_EMULATOR_HOST ?? '127.0.0.1:8080'
).split(':');

let testEnv;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: fs.readFileSync(RULES_PATH, 'utf8'),
      host: EMULATOR_HOST,
      port: Number(EMULATOR_PORT),
    },
  });
});

afterAll(async () => {
  await testEnv.cleanup();
});

// 認証コンテキストの Firestore を返す。request.auth.uid が引数の uid になる。
function db(uid) {
  return testEnv.authenticatedContext(uid).firestore();
}

// 未認証コンテキストの Firestore を返す。request.auth == null になる。
function unauthDb() {
  return testEnv.unauthenticatedContext().firestore();
}

// rules を無効化してテスト用データを seed する。
// (既存 axis / receipt 等に対する read/update/delete を検証するため)
async function seed(pathStr, data) {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), pathStr), data);
  });
}

// 各テストごとにデータをクリアし、rules を無効化した状態で groups/{id} 本体を seed する。
// (isMember / isGroupMember は groups/{id} の memberUserIDs を参照するため本体が必須)
beforeEach(async () => {
  await testEnv.clearFirestore();
  await seed('groups/g1', {
    id: 'g1',
    memberUserIDs: ['alice', 'bob'],
    name: 'テストグループ',
  });
});

// 1. users ツリー（本人のみ）
describe('users ツリー（本人のみ read/write 可）', () => {
  test('本人 alice は users/alice を read/write できる', async () => {
    const d = db('alice');
    await assertSucceeds(setDoc(doc(d, 'users/alice'), { id: 'alice' }));
    await assertSucceeds(getDoc(doc(d, 'users/alice')));
  });

  test('本人 alice は users/alice/privates/x を read/write できる', async () => {
    const d = db('alice');
    await assertSucceeds(setDoc(doc(d, 'users/alice/privates/x'), { value: 1 }));
    await assertSucceeds(getDoc(doc(d, 'users/alice/privates/x')));
  });

  test('本人 alice は users/alice/aiUsage/2026-07 を read/write できる', async () => {
    const d = db('alice');
    await assertSucceeds(setDoc(doc(d, 'users/alice/aiUsage/2026-07'), { count: 1 }));
    await assertSucceeds(getDoc(doc(d, 'users/alice/aiUsage/2026-07')));
  });

  test('他人 bob は users/alice ツリーを read/write できない', async () => {
    const d = db('bob');
    await assertFails(getDoc(doc(d, 'users/alice')));
    await assertFails(setDoc(doc(d, 'users/alice'), { id: 'alice' }));
    await assertFails(getDoc(doc(d, 'users/alice/privates/x')));
    await assertFails(setDoc(doc(d, 'users/alice/privates/x'), { value: 1 }));
    await assertFails(getDoc(doc(d, 'users/alice/aiUsage/2026-07')));
    await assertFails(setDoc(doc(d, 'users/alice/aiUsage/2026-07'), { count: 1 }));
  });

  test('未認証は users/alice ツリーを read/write できない', async () => {
    const d = unauthDb();
    await assertFails(getDoc(doc(d, 'users/alice')));
    await assertFails(setDoc(doc(d, 'users/alice'), { id: 'alice' }));
    await assertFails(getDoc(doc(d, 'users/alice/privates/x')));
    await assertFails(setDoc(doc(d, 'users/alice/aiUsage/2026-07'), { count: 1 }));
  });
});

// 2. デバッグユーザーパターン（{uid}_debug_{n}）
describe('デバッグユーザーパターン（{uid}_debug_{n}）', () => {
  test('alice は users/alice_debug_1（+ privates/aiUsage）を read/write できる', async () => {
    const d = db('alice');
    await assertSucceeds(setDoc(doc(d, 'users/alice_debug_1'), { id: 'alice_debug_1' }));
    await assertSucceeds(getDoc(doc(d, 'users/alice_debug_1')));
    await assertSucceeds(setDoc(doc(d, 'users/alice_debug_1/privates/x'), { value: 1 }));
    await assertSucceeds(setDoc(doc(d, 'users/alice_debug_1/aiUsage/2026-07'), { count: 1 }));
  });

  test('alice は他人のデバッグユーザー users/bob_debug_1 を操作できない', async () => {
    const d = db('alice');
    await assertFails(getDoc(doc(d, 'users/bob_debug_1')));
    await assertFails(setDoc(doc(d, 'users/bob_debug_1'), { id: 'bob_debug_1' }));
  });

  test('数字でない users/alice_debug_x は拒否される', async () => {
    const d = db('alice');
    await assertFails(getDoc(doc(d, 'users/alice_debug_x')));
    await assertFails(setDoc(doc(d, 'users/alice_debug_x'), { id: 'alice_debug_x' }));
  });
});

// 3. groupInvitations（Functions Admin SDK 経由のみ）
describe('groupInvitations（クライアント直アクセス全拒否）', () => {
  test('認証済みでも read/write とも拒否', async () => {
    const d = db('alice');
    await assertFails(getDoc(doc(d, 'groupInvitations/inv1')));
    await assertFails(setDoc(doc(d, 'groupInvitations/inv1'), { value: 1 }));
  });
});

// 4. inquiries（submitInquiry Function の Admin SDK 経由のみ）
describe('inquiries（クライアント直アクセス全拒否）', () => {
  test('認証済みでも read/write とも拒否', async () => {
    const d = db('alice');
    await assertFails(getDoc(doc(d, 'inquiries/i1')));
    await assertFails(setDoc(doc(d, 'inquiries/i1'), { value: 1 }));
  });
});

// 5. groups 本体
describe('groups 本体', () => {
  test('メンバー alice は read/update/delete できる', async () => {
    const d = db('alice');
    await assertSucceeds(getDoc(doc(d, 'groups/g1')));
    await assertSucceeds(updateDoc(doc(d, 'groups/g1'), { name: '更新' }));
    await assertSucceeds(deleteDoc(doc(d, 'groups/g1')));
  });

  test('クライアントからの create は拒否（createGroup Function 経由のみ）', async () => {
    const d = db('alice');
    await assertFails(
      setDoc(doc(d, 'groups/g2'), { id: 'g2', memberUserIDs: ['alice'], name: '新規' })
    );
  });

  test('非メンバー charlie は read/update/delete 拒否', async () => {
    const d = db('charlie');
    await assertFails(getDoc(doc(d, 'groups/g1')));
    await assertFails(updateDoc(doc(d, 'groups/g1'), { name: '更新' }));
    await assertFails(deleteDoc(doc(d, 'groups/g1')));
  });

  test('未認証は read/update 拒否', async () => {
    const d = unauthDb();
    await assertFails(getDoc(doc(d, 'groups/g1')));
    await assertFails(updateDoc(doc(d, 'groups/g1'), { name: '更新' }));
  });
});

// 6. groups/{id}/userProfiles・shoppingLocations（メンバーのみ）
describe('groups/{id}/userProfiles・shoppingLocations（メンバーのみ）', () => {
  test('メンバー alice は read/write できる', async () => {
    const d = db('alice');
    await assertSucceeds(setDoc(doc(d, 'groups/g1/userProfiles/p1'), { name: 'A' }));
    await assertSucceeds(getDoc(doc(d, 'groups/g1/userProfiles/p1')));
    await assertSucceeds(setDoc(doc(d, 'groups/g1/shoppingLocations/loc1'), { name: 'スーパー' }));
    await assertSucceeds(getDoc(doc(d, 'groups/g1/shoppingLocations/loc1')));
  });

  test('非メンバー charlie は read/write 拒否', async () => {
    const d = db('charlie');
    await assertFails(getDoc(doc(d, 'groups/g1/userProfiles/p1')));
    await assertFails(setDoc(doc(d, 'groups/g1/userProfiles/p1'), { name: 'A' }));
    await assertFails(getDoc(doc(d, 'groups/g1/shoppingLocations/loc1')));
    await assertFails(setDoc(doc(d, 'groups/g1/shoppingLocations/loc1'), { name: 'x' }));
  });

  test('未認証は read/write 拒否', async () => {
    const d = unauthDb();
    await assertFails(getDoc(doc(d, 'groups/g1/userProfiles/p1')));
    await assertFails(setDoc(doc(d, 'groups/g1/shoppingLocations/loc1'), { name: 'x' }));
  });
});

// 7. groups/{id}/shoppingLists と shoppingLists/{id}/items（メンバーのみ）
describe('groups/{id}/shoppingLists と items（メンバーのみ）', () => {
  test('メンバー alice は shoppingList と item を read/write できる', async () => {
    const d = db('alice');
    await assertSucceeds(setDoc(doc(d, 'groups/g1/shoppingLists/sl1'), { name: 'リスト' }));
    await assertSucceeds(getDoc(doc(d, 'groups/g1/shoppingLists/sl1')));
    await assertSucceeds(setDoc(doc(d, 'groups/g1/shoppingLists/sl1/items/it1'), { name: '牛乳' }));
    await assertSucceeds(getDoc(doc(d, 'groups/g1/shoppingLists/sl1/items/it1')));
  });

  test('非メンバー charlie は read/write 拒否', async () => {
    const d = db('charlie');
    await assertFails(getDoc(doc(d, 'groups/g1/shoppingLists/sl1')));
    await assertFails(setDoc(doc(d, 'groups/g1/shoppingLists/sl1'), { name: 'x' }));
    await assertFails(getDoc(doc(d, 'groups/g1/shoppingLists/sl1/items/it1')));
    await assertFails(setDoc(doc(d, 'groups/g1/shoppingLists/sl1/items/it1'), { name: 'x' }));
  });
});

// 8. groups/{id}/shoppingLists/{id}/receipts（delete のみ不可）
describe('groups/{id}/shoppingLists/{id}/receipts（delete のみ不可）', () => {
  const receiptPath = 'groups/g1/shoppingLists/sl1/receipts/r1';

  test('メンバー alice は read/create/update できる', async () => {
    const d = db('alice');
    await assertSucceeds(setDoc(doc(d, receiptPath), { amount: 100 })); // create
    await assertSucceeds(getDoc(doc(d, receiptPath))); // read
    await assertSucceeds(updateDoc(doc(d, receiptPath), { amount: 200 })); // update
  });

  test('メンバーでも delete は拒否', async () => {
    await seed(receiptPath, { amount: 100 });
    const d = db('alice');
    await assertFails(deleteDoc(doc(d, receiptPath)));
  });

  test('非メンバー charlie は read/create 拒否', async () => {
    const d = db('charlie');
    await assertFails(getDoc(doc(d, receiptPath)));
    await assertFails(setDoc(doc(d, receiptPath), { amount: 100 }));
  });
});

// 9. groups/{id}/userCategoryAxes（所有者判定付き）
describe('groups/{id}/userCategoryAxes（所有者判定付き）', () => {
  const axisPath = 'groups/g1/userCategoryAxes/axis_alice';

  test('メンバーかつ所有者 alice は read/create/update/delete できる', async () => {
    const d = db('alice');
    // create は request.resource.data.userID が自分であることが条件
    await assertSucceeds(setDoc(doc(d, axisPath), { userID: 'alice', name: '軸' }));
    // read / update / delete は resource.data.userID が自分であることが条件
    await assertSucceeds(getDoc(doc(d, axisPath)));
    await assertSucceeds(updateDoc(doc(d, axisPath), { name: '軸2' }));
    await assertSucceeds(deleteDoc(doc(d, axisPath)));
  });

  test('alice が userID:bob で create すると拒否', async () => {
    const d = db('alice');
    await assertFails(
      setDoc(doc(d, 'groups/g1/userCategoryAxes/axis_bob'), { userID: 'bob', name: '軸' })
    );
  });

  test('メンバーだが非所有者 bob は alice の axis を read/update/delete できない', async () => {
    await seed(axisPath, { userID: 'alice', name: '軸' });
    const d = db('bob');
    await assertFails(getDoc(doc(d, axisPath)));
    await assertFails(updateDoc(doc(d, axisPath), { name: 'x' }));
    await assertFails(deleteDoc(doc(d, axisPath)));
  });

  test('非メンバー charlie は所有者情報に関わらず拒否', async () => {
    await seed(axisPath, { userID: 'alice', name: '軸' });
    const d = db('charlie');
    await assertFails(getDoc(doc(d, axisPath)));
    await assertFails(
      setDoc(doc(d, 'groups/g1/userCategoryAxes/axis_charlie'), { userID: 'charlie', name: '軸' })
    );
  });
});

// 10. userCategoryAxes/{id}/categories（axis と同じ所有者判定）
describe('userCategoryAxes/{id}/categories（axis と同じ所有者判定）', () => {
  const axisPath = 'groups/g1/userCategoryAxes/axis_alice';
  const categoryPath = `${axisPath}/categories/cat1`;

  test('メンバーかつ所有者 alice は read/create/update/delete できる', async () => {
    const d = db('alice');
    await assertSucceeds(setDoc(doc(d, categoryPath), { userID: 'alice', name: 'カテゴリ' }));
    await assertSucceeds(getDoc(doc(d, categoryPath)));
    await assertSucceeds(updateDoc(doc(d, categoryPath), { name: 'カテゴリ2' }));
    await assertSucceeds(deleteDoc(doc(d, categoryPath)));
  });

  test('alice が userID:bob で create すると拒否', async () => {
    const d = db('alice');
    await assertFails(
      setDoc(doc(d, `${axisPath}/categories/cat_bob`), { userID: 'bob', name: 'x' })
    );
  });

  test('メンバーだが非所有者 bob は read/update/delete できない', async () => {
    await seed(categoryPath, { userID: 'alice', name: 'カテゴリ' });
    const d = db('bob');
    await assertFails(getDoc(doc(d, categoryPath)));
    await assertFails(updateDoc(doc(d, categoryPath), { name: 'x' }));
    await assertFails(deleteDoc(doc(d, categoryPath)));
  });

  test('非メンバー charlie は拒否', async () => {
    await seed(categoryPath, { userID: 'alice', name: 'カテゴリ' });
    const d = db('charlie');
    await assertFails(getDoc(doc(d, categoryPath)));
  });
});
