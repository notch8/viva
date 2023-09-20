import React from 'react'
import Search from '.'

describe('<Search />', () => {
  before(() => {
    const props = {
      filteredQuestions: [],
      selectedCategories: [],
      selectedKeywords: [],
      selectedTypes: [],
      selectedLevels: [],
      categories: [],
      keywords: [],
      types: [],
      levels: []
    }

    cy.mount(<Search {...props} />)
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

// yarn cy:comp --spec app/javascript/components/pages/Search/index.cy.jsx
