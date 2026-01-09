import React from 'react'
import { SearchBar } from './SearchBar'

describe('SearchBar', () => {
  const defaultProps = {
    subjects: ['Math', 'Science'],
    types: ['Multiple Choice', 'True/False'],
    levels: ['Easy', 'Medium', 'Hard'],
    processing: false,
    query: '',
    onQueryChange: () => {},
    onSubmit: (e) => e.preventDefault(),
    onReset: () => {},
    onFilterChange: () => {},
    filterState: {
      selectedSubjects: [],
      selectedTypes: [],
      selectedLevels: []
    },
    bookmarkedQuestionIds: [],
    hasBookmarks: false,
    showExportModal: false,
    onDeleteAllBookmarks: () => {},
    onShowExportModal: () => {},
    onHideExportModal: () => {},
    lms: {
      canvas: ['Multiple Choice', 'Essay'],
      blackboard: ['Multiple Choice'],
      d2l: ['Multiple Choice'],
      moodle: ['Multiple Choice']
    }
  }

  it('renders the search bar component', () => {
    cy.mount(<SearchBar {...defaultProps} />)
    cy.get('form').should('exist')
  })

  it('renders search input', () => {
    cy.mount(<SearchBar {...defaultProps} />)
    cy.get('input[name="search"]').should('exist')
  })

  it('displays the query value', () => {
    cy.mount(<SearchBar {...defaultProps} query='test query' />)
    cy.get('input[name="search"]').should('have.value', 'test query')
  })

  it('renders search button', () => {
    cy.mount(<SearchBar {...defaultProps} />)
    cy.get('button[type="submit"]').should('contain', 'Apply Search Terms')
  })

  it('disables submit button when processing', () => {
    cy.mount(<SearchBar {...defaultProps} processing={true} />)
    cy.get('button[type="submit"]').should('be.disabled')
  })

  it('shows reset button when query exists', () => {
    cy.mount(<SearchBar {...defaultProps} query='test' />)
    cy.contains('Reset All Filters').should('exist')
  })

  it('hides reset button when no query or filters', () => {
    cy.mount(<SearchBar {...defaultProps} />)
    cy.contains('Reset All Filters').should('not.exist')
  })

  it('renders filter buttons', () => {
    cy.mount(<SearchBar {...defaultProps} />)
    cy.contains('SUBJECTS').should('exist')
    cy.contains('TYPES').should('exist')
    cy.contains('LEVELS').should('exist')
  })

  it('displays bookmark count', () => {
    cy.mount(<SearchBar {...defaultProps} bookmarkedQuestionIds={[1, 2, 3]} />)
    cy.contains('BOOKMARKS (3)').should('exist')
  })

  it('does not show modal when closed', () => {
    cy.mount(<SearchBar {...defaultProps} showExportModal={false} />)
    cy.get('.modal').should('not.exist')
  })
})
