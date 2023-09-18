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
    'linebreak-style': [
      'error',
      'unix'
    ],
    'quotes': [
      'error',
      'single'
    ],
    'react/prop-types': 'off',
    'semi': [
      'error',
      'never'
    ],
    'object-curly-newline': ['error', {
      'ImportDeclaration': {
        'multiline': true,
        'minProperties': 4
      },
      'ExportDeclaration': {
        'multiline': true,
        'minProperties': 4
      }
    }
    ]
  },
  'settings': {
    'react': {
      'version': 'detect'
    }
  }
}
