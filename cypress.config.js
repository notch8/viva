const { defineConfig } = require('cypress');

module.exports = defineConfig({
  projectId: "ftsfzy",
  component: {
    devServer: {
      framework: 'react',
      bundler: 'vite',
      viteConfig: './vite.config.ts',
    },
  },

  e2e: {
    baseUrl: 'http://viva.test',
    setupNodeEvents(on, config) {
      // implement node event listeners here
    },
  },
});
