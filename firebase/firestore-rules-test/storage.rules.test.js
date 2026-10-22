const fs = require('fs');
const path = require('path');
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');
const { doc, setDoc } = require('firebase/firestore');

// firestore.rules.test.js と同じ demo プロジェクト。storage.rules の firestore.get() は
// 同じプロジェクトの Firestore Emulator を参照する。
const PROJECT_ID = 'demo-shoppinglist';
const STORAGE_RULES_PATH = path.resolve(__dirname, '..', 'storage.rules');
const FIRESTORE_RULES_PATH = path.resolve(__dirname, '..', 'firestore.rules');

// emulators:exec が子プロセスに設定する "host:port" から接続先を得る。
function emulatorHostAndPort(hostEnv, fallback) {
  const [host, port] = (hostEnv ?? fallback).split(':');
  return { host, port: Number(port) };
}

let testEnv;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: fs.readFileSync(FIRESTORE_RULES_PATH, 'utf8'),
      ...emulatorHostAndPort(process.env.FIRESTORE_EMULATOR_HOST, '127.0.0.1:8080'),
    },
    storage: {
      rules: fs.readFileSync(STORAGE_RULES_PATH, 'utf8'),
      ...emulatorHostAndPort(process.env.FIREBASE_STORAGE_EMULATOR_HOST, '127.0.0.1:9199'),
    },
  });
});

afterAll(async () => {
  await testEnv.cleanup();
});

// 認証コンテキストの Storage を返す。request.auth.uid が引数の uid になる。
function storage(uid) {
  return testEnv.authenticatedContext(uid).storage();
}

// 未認証コンテキストの Storage を返す。request.auth == null になる。
function unauthStorage() {
  return testEnv.unauthenticatedContext().storage();
}

// rules を無効化して groups/g1 本体を seed する。storage.rules は memberUserIDs を参照する。
async function seedGroup(memberUserIDs) {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), 'groups/g1'), {
      id: 'g1',
      memberUserIDs,
      name: 'テストグループ',
    });
  });
}

// rules を無効化して Storage にファイルを置く (書き込みは Admin SDK 経由のみで rules が拒否するため)。
async function seedFile(storagePath) {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await ctx
      .storage()
      .ref(storagePath)
      .put(new Uint8Array([0xff, 0xd8, 0xff]), { contentType: 'image/jpeg' });
  });
}

const RECEIPTS_DIR = 'groups/g1/shoppingLists/l1/receipts';
const SOURCE_IMAGES_DIR = 'groups/g1/shoppingLists/l1/sourceImages';
const ITEMS_DIR = 'groups/g1/shoppingLists/l1/items/i1';

beforeEach(async () => {
  await testEnv.clearFirestore();
  await testEnv.clearStorage();
  await seedGroup(['alice', 'bob']);
  await seedFile(`${RECEIPTS_DIR}/r1.jpg`);
  await seedFile(`${SOURCE_IMAGES_DIR}/s1.jpg`);
  await seedFile(`${ITEMS_DIR}/p1.jpg`);
});

describe.each([
  ['receipts', RECEIPTS_DIR, 'r1.jpg'],
  ['sourceImages', SOURCE_IMAGES_DIR, 's1.jpg'],
])('%s（read はグループの現メンバーのみ）', (_, dir, fileName) => {
  test('メンバー alice は get (getDownloadURL / getMetadata) と list ができる', async () => {
    const s = storage('alice');
    await assertSucceeds(s.ref(`${dir}/${fileName}`).getDownloadURL());
    await assertSucceeds(s.ref(`${dir}/${fileName}`).getMetadata());
    await assertSucceeds(s.ref(dir).listAll());
  });

  test('非メンバー carol は get と list ができない', async () => {
    const s = storage('carol');
    await assertFails(s.ref(`${dir}/${fileName}`).getDownloadURL());
    await assertFails(s.ref(`${dir}/${fileName}`).getMetadata());
    await assertFails(s.ref(dir).listAll());
  });

  test('グループから外された bob は get と list ができない', async () => {
    await seedGroup(['alice']);
    const s = storage('bob');
    await assertFails(s.ref(`${dir}/${fileName}`).getDownloadURL());
    await assertFails(s.ref(dir).listAll());
  });

  test('存在しないグループのパスは get と list ができない', async () => {
    const s = storage('alice');
    await assertFails(s.ref(dir.replace('groups/g1', 'groups/unknown')).listAll());
  });

  test('未認証は get と list ができない', async () => {
    const s = unauthStorage();
    await assertFails(s.ref(`${dir}/${fileName}`).getDownloadURL());
    await assertFails(s.ref(dir).listAll());
  });

  test('メンバーでも write はできない', async () => {
    const s = storage('alice');
    await assertFails(s.ref(`${dir}/new.jpg`).put(new Uint8Array([0xff])));
    await assertFails(s.ref(`${dir}/${fileName}`).delete());
  });
});

describe('items（Admin SDK 経由のみ）', () => {
  test('メンバーでも read/write できない', async () => {
    const s = storage('alice');
    await assertFails(s.ref(`${ITEMS_DIR}/p1.jpg`).getDownloadURL());
    await assertFails(s.ref(ITEMS_DIR).listAll());
    await assertFails(s.ref(`${ITEMS_DIR}/new.jpg`).put(new Uint8Array([0xff])));
  });
});
