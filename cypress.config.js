const { defineConfig } = require('cypress');

module.exports = defineConfig({
  projectId: "ftsfzy",
  component: {
    devServer: {
      framework: 'react',
      bundler: 'vite',
    },
  },
});
