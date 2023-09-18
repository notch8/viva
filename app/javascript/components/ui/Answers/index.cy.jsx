import React from 'react'
import Answers from '.'

describe('<Answers />', () => {
  it('renders', () => {
    // see: https://on.cypress.io/mounting-react
    cy.mount(<Answers />)
  })
})
