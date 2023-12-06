import React from 'react'
import EssayAnswers from '.'

describe('<EssayAnswers />', () => {
  it('renders', () => {
    // see: https://on.cypress.io/mounting-react
    cy.mount(<EssayAnswers />)
  })
})
