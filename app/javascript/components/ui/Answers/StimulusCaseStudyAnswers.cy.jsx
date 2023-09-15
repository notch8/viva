import React from 'react'
import StimulusCaseStudyAnswers from '.'

describe('<StimulusCaseStudyAnswers />', () => {
  it('renders', () => {
    // see: https://on.cypress.io/mounting-react
    cy.mount(<StimulusCaseStudyAnswers />)
  })
})
