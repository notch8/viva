// eslint-disable-next-line no-undef
const { defineConfig } = require('cypress')

// eslint-disable-next-line no-undef
module.exports = defineConfig({
  component: {
    devServer: {
      framework: 'react',
      bundler: 'vite',
      viteConfig: './vite.config.ts',
    },
  },
  reporter: 'junit',
  reporterOptions: {
    mochaFile: 'cypress/results/results-[hash].xml',
    toConsole: true,
  },
  e2e: {
    baseUrl: 'http://web:3000',
    // baseUrl: 'http://viva.test', // uncomment to run Cypress against the local Rails app (outside of Docker)
    chromeWebSecurity: false,
    setupNodeEvents(on, config) { // eslint-disable-line no-unused-vars
      // implement node event listeners here
    },
  },
})
