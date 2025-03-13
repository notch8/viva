import React from 'react'
import StimulusCaseStudyAnswers from './StimulusCaseStudyAnswers'

describe('StimulusCaseStudyAnswers Component', () => {
  it('renders a single question with multiple choice answers', () => {
    const stimulusData = [
      {
        text: 'What is the capital of France?',
        type_label: 'Multiple Choice Question',
        type_name: 'Multiple Choice',
        data: [
          { answer: 'Paris', correct: true },
          { answer: 'London', correct: false },
          { answer: 'Berlin', correct: false }
        ]
      }
    ]

    cy.mount(<StimulusCaseStudyAnswers answers={stimulusData} />)

    // Check if the container is rendered
    cy.get('.StimulusCaseStudyAnswers').should('exist')

    // Check if the question is rendered correctly
    cy.get('.question').should('exist')
    cy.get('.question h2').should('contain', 'Multiple Choice Question')
    cy.get('.question p').should('contain', 'What is the capital of France?')

    // Check if the answers are rendered correctly
    cy.contains('Paris').should('exist')
    cy.contains('London').should('exist')
    cy.contains('Berlin').should('exist')
    cy.contains('CORRECT').should('exist')
  })

  it('renders multiple questions with different answer types', () => {
    const stimulusData = [
      {
        text: 'What is the capital of France?',
        type_label: 'Multiple Choice Question',
        type_name: 'Multiple Choice',
        data: [
          { answer: 'Paris', correct: true },
          { answer: 'London', correct: false }
        ]
      },
      {
        text: 'Select all European countries.',
        type_label: 'Select All That Apply',
        type_name: 'Select All That Apply',
        data: [
          { answer: 'France', correct: true },
          { answer: 'Germany', correct: true },
          { answer: 'Japan', correct: false }
        ]
      }
    ]

    cy.mount(<StimulusCaseStudyAnswers answers={stimulusData} />)

    // Check if both questions are rendered
    cy.get('.question').should('have.length', 2)

    // Check first question
    cy.get('.question').eq(0).within(() => {
      cy.get('h2').should('contain', 'Multiple Choice Question')
      cy.get('p').should('contain', 'What is the capital of France?')
    })

    // Check second question
    cy.get('.question').eq(1).within(() => {
      cy.get('h2').should('contain', 'Select All That Apply')
      cy.get('p').should('contain', 'Select all European countries.')
    })

    // Check that both sets of answers are rendered
    cy.contains('Paris').should('exist')
    cy.contains('France').should('exist')
    cy.contains('Germany').should('exist')
    cy.contains('Japan').should('exist')
  })

  it('renders questions with images', () => {
    const stimulusData = [
      {
        text: 'What is shown in this image?',
        type_label: 'Image Question',
        type_name: 'Multiple Choice',
        images: [
          { url: 'https://example.com/image.jpg', alt_text: 'Example image' }
        ],
        data: [
          { answer: 'A landscape', correct: true },
          { answer: 'A portrait', correct: false }
        ]
      }
    ]

    cy.mount(<StimulusCaseStudyAnswers answers={stimulusData} />)

    // Check if the image is rendered correctly
    cy.get('.question img')
      .should('have.attr', 'src', 'https://example.com/image.jpg')
      .should('have.attr', 'alt', 'Example image')
      .should('have.class', 'w-75')
  })

  it('renders questions with matching answers', () => {
    const stimulusData = [
      {
        text: 'Match the countries with their capitals.',
        type_label: 'Matching Question',
        type_name: 'Matching',
        data: [
          { answer: 'France', correct: ['Paris'] },
          { answer: 'Germany', correct: ['Berlin'] }
        ]
      }
    ]

    cy.mount(<StimulusCaseStudyAnswers answers={stimulusData} />)

    // Check if the matching table is rendered
    cy.get('.matching-table-row').should('have.length', 2)
    cy.get('.matchee').first().should('contain', 'France')
    cy.get('.matcher').first().should('contain', 'Paris')
  })

  it('renders questions with essay answers', () => {
    const stimulusData = [
      {
        text: 'Write an essay about climate change.',
        type_label: 'Essay Question',
        type_name: 'Essay',
        data: {
          html: '<p>This is a sample essay answer about climate change.</p>'
        }
      }
    ]

    cy.mount(<StimulusCaseStudyAnswers answers={stimulusData} />)

    // Check if the essay answer is rendered
    cy.get('.question p').should('contain', 'Write an essay about climate change.')
    cy.get('p').contains('This is a sample essay answer about climate change.').should('exist')
  })

  it('renders questions with drag and drop answers', () => {
    const stimulusData = [
      {
        text: 'Drag the correct items to the box.',
        type_label: 'Drag and Drop Question',
        type_name: 'Drag and Drop',
        data: [
          { answer: 'Correct Item 1', correct: true },
          { answer: 'Correct Item 2', correct: true },
          { answer: 'Incorrect Item', correct: false }
        ]
      }
    ]

    cy.mount(<StimulusCaseStudyAnswers answers={stimulusData} />)

    // Check if the drag and drop answers are rendered
    cy.get('.DragAndDropAnswers').should('exist')
    cy.get('.correct-answer').should('have.length', 2)
    cy.contains('Correct Item 1').should('exist')
    cy.contains('Incorrect Item').should('exist')
  })

  it('handles questions with no data property', () => {
    const stimulusData = [
      {
        text: 'Question with no answers',
        type_label: 'Empty Question',
        type_name: 'Multiple Choice'
        // No data property
      }
    ]

    cy.mount(<StimulusCaseStudyAnswers answers={stimulusData} />)

    // Check if the question is rendered without answers
    cy.get('.question').should('exist')
    cy.get('.question p').should('contain', 'Question with no answers')
    // No answers should be rendered
    cy.contains('CORRECT').should('not.exist')
  })

  it('handles empty answers array', () => {
    cy.mount(<StimulusCaseStudyAnswers answers={[]} />)

    // Check that the container is rendered but has no questions
    cy.get('.StimulusCaseStudyAnswers').should('exist')
    cy.get('.question').should('not.exist')
  })

  it('handles a large number of questions', () => {
    const largeDataSet = Array.from({ length: 5 }, (_, i) => ({
      text: `Question ${i + 1}`,
      type_label: `Question Type ${i + 1}`,
      type_name: 'Multiple Choice',
      data: [
        { answer: `Answer ${i + 1}`, correct: true },
        { answer: `Wrong Answer ${i + 1}`, correct: false }
      ]
    }))

    cy.mount(<StimulusCaseStudyAnswers answers={largeDataSet} />)

    // Check if all questions are rendered
    cy.get('.question').should('have.length', 5)
  })
})
