import React from 'react'
import Question from '.'

describe('<Question />', () => {
  it('renders', () => {
    // see: https://on.cypress.io/mounting-react
    cy.mount(<Question />)
  })
})
