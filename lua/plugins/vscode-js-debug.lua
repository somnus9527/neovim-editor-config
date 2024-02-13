return {
  'microsoft/vscode-js-debug',
  module = true,
  version = '1.x',
  opt = true,
  build = 'npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out',
}
