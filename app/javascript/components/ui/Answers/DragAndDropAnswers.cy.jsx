import React from 'react'
import BowTieAnswers from '.'

describe('<BowTieAnswers />', () => {
  it('renders', () => {
    // see: https://on.cypress.io/mounting-react
    cy.mount(<BowTieAnswers />)
  })
})
