return {
  'microsoft/vscode-js-debug',
  lazy = true,
  module = true,
  version = '1.77.x',
  opt = true,
  build = 'npm install --legacy-peer-deps && npx gulp vsDebugServerBundle',
}
