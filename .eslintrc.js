/**
 * Rules: https://eslint.org/docs/latest/rules/
 */
module.exports = { // eslint-disable-line no-undef
  'env': {
    'browser': true,
    'es2021': true,
    'node': true, // Add Node.js environment
    'jquery': true // Add jQuery global environment
  },
  'extends': [
    'eslint:recommended',
    'plugin:react/recommended'
  ],
  'ignorePatterns': [
    'public/*',
    'app/assets/builds',
    'coverage/*' // Exclude coverage files from linting
  ],
  'overrides': [
    {
      'files': ['*.cy.jsx'],
      'rules': {
        'no-undef': 'off'
      }
    }
  ],
  'parserOptions': {
    'ecmaVersion': 'latest',
    'sourceType': 'module'
  },
  'plugins': [
    'react',
  ],
  'rules': {
    'indent': [
      'error',
      2
    ],
    'jsx-quotes': [
      'error',
      'prefer-single'
    ],
    'linebreak-style': [
      'error',
      'unix'
    ],
    'no-trailing-spaces': 'error',
    'object-curly-newline': ['error', {
      'ExportDeclaration': {
        'multiline': true,
        'minProperties': 4
      },
      'ImportDeclaration': {
        'multiline': true,
        'minProperties': 4
      }
    }],
    'quotes': [
      'error',
      'single'
    ],
    'react/prop-types': 'off',
    'semi': [
      'error',
      'never'
    ],
    'no-cond-assign': [
      'error',
      'except-parens' // Allow assignments in conditionals if wrapped in parentheses
    ],
    'no-empty': [
      'error',
      { 'allowEmptyCatch': true } // Allow empty catch blocks
    ],
    'no-control-regex': 'off', // Disable control regex rule for specific use cases
    'no-useless-escape': 'warn' // Change from error to warn to review unnecessary escapes
  },
  'globals': {
    'module': 'readonly',
    'require': 'readonly',
    'define': 'readonly',
    '$': 'readonly', // Add jQuery global
    'jQuery': 'readonly'
  },
  'settings': {
    'react': {
      'version': 'detect'
    }
  }
}
