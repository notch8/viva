/**
 * Rules: https://eslint.org/docs/latest/rules/
 */
module.exports = { // eslint-disable-line no-undef
  'env': {
    'browser': true,
    'es2021': true
  },
  'extends': [
    'eslint:recommended',
    'plugin:react/recommended'
  ],
  'ignorePatterns': [
    'public/*',
    'app/assets/builds'
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
    ]
  },
  'settings': {
    'react': {
      'version': 'detect'
    }
  }
}
