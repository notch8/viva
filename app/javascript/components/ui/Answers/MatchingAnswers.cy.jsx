import React from 'react'
import MatchingAnswers from './MatchingAnswers'

describe('MatchingAnswers Component', () => {
  it('renders a table with matching categories and answers', () => {
    const matchingData = [
      { answer: 'Category 1', correct: ['Match 1', 'Match 2'] },
      { answer: 'Category 2', correct: ['Match 3'] }
    ]

    cy.mount(<MatchingAnswers answers={matchingData} />)

    // Check if the table is rendered
    cy.get('table').should('exist').and('have.class', 'bg-white')
    cy.get('table').should('have.class', 'table-bordered')

    // Check if the correct number of rows is rendered
    cy.get('tr.matching-table-row').should('have.length', 2)

    // Check the first category and its matches
    cy.get('tr.matching-table-row').eq(0).within(() => {
      cy.get('td.matchee').should('contain', 'Category 1')
      cy.get('td.matcher').within(() => {
        cy.get('span').should('have.length', 2)
        cy.get('span').eq(0).should('contain', 'Match 1')
        cy.get('span').eq(1).should('contain', 'Match 2')
      })
    })

    // Check the second category and its match
    cy.get('tr.matching-table-row').eq(1).within(() => {
      cy.get('td.matchee').should('contain', 'Category 2')
      cy.get('td.matcher').within(() => {
        cy.get('span').should('have.length', 1)
        cy.get('span').eq(0).should('contain', 'Match 3')
      })
    })
  })

  it('renders categories with proper styling', () => {
    const matchingData = [
      { answer: 'Test Category', correct: ['Test Match'] }
    ]

    cy.mount(<MatchingAnswers answers={matchingData} />)

    // Check category cell styling
    cy.get('td.matchee')
      .should('have.class', 'text-primary')
      .should('have.class', 'fw-semibold')
      .should('have.class', 'align-middle')
      .should('have.class', 'text-center')
  })

  it('renders matches with proper styling', () => {
    const matchingData = [
      { answer: 'Test Category', correct: ['Test Match'] }
    ]

    cy.mount(<MatchingAnswers answers={matchingData} />)

    // Check matcher cell styling
    cy.get('td.matcher')
      .should('have.class', 'd-flex')
      .should('have.class', 'flex-column')

    // Check match item styling
    cy.get('td.matcher span')
      .should('have.class', 'px-3')
      .should('have.class', 'py-2')
  })

  it('handles categories with no matches', () => {
    const matchingData = [
      { answer: 'Category with matches', correct: ['Match 1'] },
      { answer: 'Category without matches', correct: [] }
    ]

    cy.mount(<MatchingAnswers answers={matchingData} />)

    // Check if both categories are rendered
    cy.get('tr.matching-table-row').should('have.length', 2)

    // Check that the second category has no match items
    cy.get('tr.matching-table-row').eq(1).within(() => {
      cy.get('td.matchee').should('contain', 'Category without matches')
      cy.get('td.matcher span').should('not.exist')
    })
  })

  it('handles categories with undefined correct property', () => {
    const matchingData = [
      { answer: 'Normal Category', correct: ['Match 1'] },
      { answer: 'Category with undefined correct' }
    ]

    cy.mount(<MatchingAnswers answers={matchingData} />)

    // Check if both categories are rendered
    cy.get('tr.matching-table-row').should('have.length', 2)

    // Check that the second category has no match items
    cy.get('tr.matching-table-row').eq(1).within(() => {
      cy.get('td.matchee').should('contain', 'Category with undefined correct')
      cy.get('td.matcher span').should('not.exist')
    })
  })

  it('handles empty answers array', () => {
    cy.mount(<MatchingAnswers answers={[]} />)

    // Check that the table is rendered but has no rows
    cy.get('table').should('exist')
    cy.get('tr.matching-table-row').should('not.exist')
  })

  it('handles categories with long text', () => {
    const longText = 'This is a very long category name that should still be displayed properly in the table cell without breaking the layout'
    const matchingData = [
      { answer: longText, correct: ['Match 1'] }
    ]

    cy.mount(<MatchingAnswers answers={matchingData} />)

    // Check if the long text is rendered correctly
    cy.get('td.matchee').should('contain', longText)
  })

  it('handles matches with long text', () => {
    const longMatch = 'This is a very long match text that should still be displayed properly in the table cell without breaking the layout'
    const matchingData = [
      { answer: 'Category', correct: [longMatch] }
    ]

    cy.mount(<MatchingAnswers answers={matchingData} />)

    // Check if the long match text is rendered correctly
    cy.get('td.matcher span').should('contain', longMatch)
  })

  it('handles a large number of categories', () => {
    const largeDataSet = Array.from({ length: 10 }, (_, i) => ({
      answer: `Category ${i + 1}`,
      correct: [`Match ${i + 1}`]
    }))

    cy.mount(<MatchingAnswers answers={largeDataSet} />)

    // Check if all categories are rendered
    cy.get('tr.matching-table-row').should('have.length', 10)
  })

  it('handles a large number of matches for a single category', () => {
    const manyMatches = Array.from({ length: 10 }, (_, i) => `Match ${i + 1}`)
    const matchingData = [
      { answer: 'Category with many matches', correct: manyMatches }
    ]

    cy.mount(<MatchingAnswers answers={matchingData} />)

    // Check if all matches are rendered
    cy.get('td.matcher span').should('have.length', 10)
  })
})
