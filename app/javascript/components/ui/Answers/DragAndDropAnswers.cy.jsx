import React from 'react'
import DragAndDropAnswers from '.'

describe('<DragAndDropAnswers />', () => {
  it('renders', () => {
    // see: https://on.cypress.io/mounting-react
    cy.mount(<DragAndDropAnswers />)
  })
})
