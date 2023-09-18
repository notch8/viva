import React from 'react'
import MatchingAnswers from '.'

describe('<MatchingAnswers />', () => {
  it('renders', () => {
    // see: https://on.cypress.io/mounting-react
    cy.mount(<MatchingAnswers />)
  })
})
