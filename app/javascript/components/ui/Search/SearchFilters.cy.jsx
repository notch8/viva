import React from 'react'
import SearchFilters from './SearchFilters'

describe('SearchFilters', () => {
  const defaultProps = {
    selectedSubjects: ['Math'],
    selectedKeywords: [], // Keywords are not currently being used
    selectedTypes: ['Multiple Choice'],
    selectedLevels: ['1'],
    removeFilterAndSearch: () => {},
    onBookmarkBatch: () => {},
    errors: null
  }

  beforeEach(() => {
    cy.mount(<SearchFilters {...defaultProps} />)
  })

  it('renders selected filters', () => {
    cy.contains('Selected Filters').should('exist')
    cy.contains('Math').should('exist')
    cy.contains('Multiple Choice').should('exist')
    cy.contains('1').should('exist')
  })

  it('shows bookmark button', () => {
    cy.contains('Bookmark Filtered').should('exist')
  })
})
