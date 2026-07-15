/** @type {import('jest').Config} */
module.exports = {
  testEnvironment: 'node',
  // Emulator の起動待ち・多数のケースを 1 プロセスで実行するため余裕を持たせる。
  testTimeout: 20000,
};
