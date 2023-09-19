import React from 'react'
import TraditionalAnswers from '.'

describe('<TraditionalAnswers />', () => {
  it('renders', () => {
    // see: https://on.cypress.io/mounting-react
    cy.mount(<TraditionalAnswers />)
  })
})
