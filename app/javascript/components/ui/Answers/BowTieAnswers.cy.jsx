import React from 'react'
import BowTieAnswers from './BowTieAnswers'

describe('BowTieAnswers Component', () => {
  const mockAnswers = {
    center: {
      label: 'Central Theme',
      answers: [
        { answer: 'Climate Change', correct: true },
        { answer: 'Global Warming', correct: false },
        { answer: 'Environmental Issues', correct: false }
      ]
    },
    left: {
      label: 'Causes',
      answers: [
        { answer: 'Greenhouse Gas Emissions', correct: true },
        { answer: 'Deforestation', correct: true },
        { answer: 'Natural Climate Cycles', correct: false },
        { answer: 'Solar Activity', correct: false }
      ]
    },
    right: {
      label: 'Effects',
      answers: [
        { answer: 'Rising Sea Levels', correct: true },
        { answer: 'Extreme Weather Events', correct: true },
        { answer: 'Increased Biodiversity', correct: false },
        { answer: 'Cooler Temperatures', correct: false }
      ]
    }
  }

  beforeEach(() => {
    // Mount the component with mock data
    cy.mount(<BowTieAnswers answers={mockAnswers} />)
  })

  it('renders the bowtie diagram with correct answers', () => {
    // Check if the ArcherContainer is rendered
    cy.get('.bowtie-answers').should('exist')

    // Check if the center answer is rendered correctly
    cy.get('.center-answer')
      .should('have.length', 1)
      .and('contain', 'Climate Change')
      .and('have.class', 'bg-primary')
      .and('have.class', 'text-white')

    // Check if the left answers are rendered correctly
    cy.get('.left-answer')
      .should('have.length', 2)
      .and('contain', 'Greenhouse Gas Emissions')
      .and('contain', 'Deforestation')
      .and('have.class', 'bg-light-4')

    // Check if the right answers are rendered correctly
    cy.get('.right-answer')
      .should('have.length', 2)
      .and('contain', 'Rising Sea Levels')
      .and('contain', 'Extreme Weather Events')
      .and('have.class', 'bg-light-4')
  })

  it('renders the incorrect answers section', () => {
    // Check if the incorrect answers section is rendered
    cy.get('.incorrect-question-answers').should('exist')
    cy.contains('h4', 'Incorrect Answers').should('be.visible')

    // Check if the table headers are rendered correctly
    cy.get('th').should('have.length', 3)
    cy.get('th').eq(0).should('contain', 'Causes')
    cy.get('th').eq(1).should('contain', 'Central Theme')
    cy.get('th').eq(2).should('contain', 'Effects')

    // Check if the incorrect answers are rendered in the tables
    // Left column (Causes)
    cy.get('tbody').eq(0).within(() => {
      cy.get('tr').should('have.length', 2)
      cy.get('td').eq(0).should('contain', 'Natural Climate Cycles')
      cy.get('td').eq(1).should('contain', 'Solar Activity')
    })

    // Center column (Central Theme)
    cy.get('tbody').eq(1).within(() => {
      cy.get('tr').should('have.length', 2)
      cy.get('td').eq(0).should('contain', 'Global Warming')
      cy.get('td').eq(1).should('contain', 'Environmental Issues')
    })

    // Right column (Effects)
    cy.get('tbody').eq(2).within(() => {
      cy.get('tr').should('have.length', 2)
      cy.get('td').eq(0).should('contain', 'Increased Biodiversity')
      cy.get('td').eq(1).should('contain', 'Cooler Temperatures')
    })
  })

  it('handles empty answers gracefully', () => {
    const emptyAnswers = {
      center: { label: 'Central Theme', answers: [] },
      left: { label: 'Causes', answers: [] },
      right: { label: 'Effects', answers: [] }
    }

    cy.mount(<BowTieAnswers answers={emptyAnswers} />)

    // Check if the component renders without errors
    cy.get('.bowtie-answers').should('exist')

    // Check that no answers are rendered
    cy.get('.center-answer').should('not.exist')
    cy.get('.left-answer').should('not.exist')
    cy.get('.right-answer').should('not.exist')

    // Check if the incorrect answers section is still rendered
    cy.get('.incorrect-question-answers').should('exist')
  })

  it('handles answers with only center correct answer', () => {
    const centerOnlyAnswers = {
      center: {
        label: 'Central Theme',
        answers: [{ answer: 'Climate Change', correct: true }]
      },
      left: { label: 'Causes', answers: [] },
      right: { label: 'Effects', answers: [] }
    }

    cy.mount(<BowTieAnswers answers={centerOnlyAnswers} />)

    // Check if only the center answer is rendered
    cy.get('.center-answer').should('have.length', 1)
    cy.get('.left-answer').should('not.exist')
    cy.get('.right-answer').should('not.exist')
  })

  it('handles answers with multiple correct answers in each column', () => {
    const multipleCorrectAnswers = {
      center: {
        label: 'Central Theme',
        answers: [
          { answer: 'Climate Change', correct: true },
          { answer: 'Global Warming', correct: true }
        ]
      },
      left: {
        label: 'Causes',
        answers: [
          { answer: 'Greenhouse Gas Emissions', correct: true },
          { answer: 'Deforestation', correct: true },
          { answer: 'Industrial Pollution', correct: true }
        ]
      },
      right: {
        label: 'Effects',
        answers: [
          { answer: 'Rising Sea Levels', correct: true },
          { answer: 'Extreme Weather Events', correct: true },
          { answer: 'Biodiversity Loss', correct: true }
        ]
      }
    }

    cy.mount(<BowTieAnswers answers={multipleCorrectAnswers} />)

    // Check if all correct answers are rendered
    cy.get('.center-answer').should('have.length', 2)
    cy.get('.left-answer').should('have.length', 3)
    cy.get('.right-answer').should('have.length', 3)
  })

  it('verifies the layout structure of the bowtie diagram', () => {
    // Check the column structure
    cy.get('.bowtie-answers').children().should('have.length', 3)

    // Check that the columns have the correct Bootstrap classes
    cy.get('.bowtie-answers').children().each($col => {
      cy.wrap($col).should('have.class', 'col')
    })

    // Check that the center column has the correct alignment
    cy.get('.bowtie-answers').children().eq(1)
      .should('have.class', 'd-flex')
      .and('have.class', 'align-items-center')

    // Check that the left and right columns have the correct alignment
    cy.get('.bowtie-answers').children().eq(0)
      .should('have.class', 'd-flex')
      .and('have.class', 'flex-column')
      .and('have.class', 'justify-content-between')

    cy.get('.bowtie-answers').children().eq(2)
      .should('have.class', 'd-flex')
      .and('have.class', 'flex-column')
      .and('have.class', 'justify-content-between')
  })
})
