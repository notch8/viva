import React from 'react'
import IncorrectAnswers from '.'

describe('<IncorrectAnswers />', () => {
  it('renders', () => {
    // see: https://on.cypress.io/mounting-react
    cy.mount(<IncorrectAnswers />)
  })
})
