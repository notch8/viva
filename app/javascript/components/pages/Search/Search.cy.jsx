import React from 'react'
import Search from '.'

describe('<Search />', () => {
  before(() => {
    cy.mount(<Search filteredQuestions={[]} />)
  })

  context('question list', () => {
    it('should display a list of questions', () => {
      // TODO: set this up
    })

    it('should be filterable', () => {
      // TODO: set this up
    })
  })
})

