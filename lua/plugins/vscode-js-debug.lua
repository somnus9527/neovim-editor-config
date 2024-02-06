return {
  'microsoft/vscode-js-debug',
  module = true,
  version = '1.x',
  build = 'npm i && npm run compile dapDebugServer:webpack-bundle && mv dist out',
}
