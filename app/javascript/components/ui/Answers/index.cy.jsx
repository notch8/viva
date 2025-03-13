import React from 'react'
import Answers from './index'

describe('Answers Component', () => {
  it('renders BowTieAnswers for Bow Tie question type', () => {
    const bowTieAnswers = {
      center: {
        label: 'Center Label',
        answers: [{ answer: 'Center Answer', correct: true }]
      },
      left: {
        label: 'Left Label',
        answers: [{ answer: 'Left Answer 1', correct: true }, { answer: 'Left Answer 2', correct: false }]
      },
      right: {
        label: 'Right Label',
        answers: [{ answer: 'Right Answer 1', correct: true }, { answer: 'Right Answer 2', correct: false }]
      }
    }

    cy.mount(<Answers question_type_name='Bow Tie' answers={bowTieAnswers} />)

    // Check if BowTieAnswers is rendered correctly
    cy.get('.bowtie-answers').should('exist')
    cy.get('.center-answer').should('contain', 'Center Answer')
    cy.get('.left-answer').should('contain', 'Left Answer 1')
    cy.get('.right-answer').should('contain', 'Right Answer 1')
  })

  it('renders DragAndDropAnswers for Drag and Drop question type', () => {
    const dragAndDropAnswers = [
      { answer: 'Correct Answer 1', correct: true },
      { answer: 'Correct Answer 2', correct: true },
      { answer: 'Incorrect Answer 1', correct: false },
      { answer: 'Incorrect Answer 2', correct: false }
    ]

    cy.mount(<Answers question_type_name='Drag and Drop' answers={dragAndDropAnswers} />)

    // Check if DragAndDropAnswers is rendered correctly
    cy.get('.DragAndDropAnswers').should('exist')
    cy.get('.correct-answer').should('have.length', 2)
    cy.get('.correct-answer').first().should('contain', 'Correct Answer 1')
    cy.get('.correct-answer').eq(1).should('contain', 'Correct Answer 2')
    cy.contains('Incorrect Answers').should('exist')
    cy.get('.incorrect-question-answers').should('exist')
    cy.get('.incorrect-question-answers').contains('Incorrect Answer 1').should('exist')
  })

  it('renders MatchingAnswers for Matching question type', () => {
    const matchingAnswers = [
      { answer: 'Category 1', correct: ['Match 1', 'Match 2'] },
      { answer: 'Category 2', correct: ['Match 3'] }
    ]

    cy.mount(<Answers question_type_name='Matching' answers={matchingAnswers} />)

    // Check if MatchingAnswers is rendered correctly
    cy.get('.matching-table-row').should('have.length', 2)
    cy.get('.matchee').first().should('contain', 'Category 1')
    cy.get('.matcher').first().should('contain', 'Match 1')
    cy.get('.matcher').first().should('contain', 'Match 2')
  })

  it('renders MatchingAnswers for Categorization question type', () => {
    const categorizationAnswers = [
      { answer: 'Category 1', correct: ['Item 1', 'Item 2'] },
      { answer: 'Category 2', correct: ['Item 3'] }
    ]

    cy.mount(<Answers question_type_name='Categorization' answers={categorizationAnswers} />)

    // Check if MatchingAnswers is rendered correctly for Categorization
    cy.get('.matching-table-row').should('have.length', 2)
    cy.get('.matchee').first().should('contain', 'Category 1')
    cy.get('.matcher').first().should('contain', 'Item 1')
  })

  it('renders TraditionalAnswers for Traditional question type', () => {
    const traditionalAnswers = [
      { answer: 'Answer 1', correct: true },
      { answer: 'Answer 2', correct: false },
      { answer: 'Answer 3', correct: false }
    ]

    cy.mount(<Answers question_type_name='Traditional' answers={traditionalAnswers} />)

    // Check if TraditionalAnswers is rendered correctly
    cy.contains('h3', 'Answers').should('exist')
    cy.contains('Answer 1').should('exist')
    cy.contains('CORRECT').should('exist')
  })

  it('renders TraditionalAnswers for Multiple Choice question type', () => {
    const multipleChoiceAnswers = [
      { answer: 'Option A', correct: true },
      { answer: 'Option B', correct: false },
      { answer: 'Option C', correct: false }
    ]

    cy.mount(<Answers question_type_name='Multiple Choice' answers={multipleChoiceAnswers} />)

    // Check if TraditionalAnswers is rendered correctly for Multiple Choice
    cy.contains('h3', 'Answers').should('exist')
    cy.contains('Option A').should('exist')
    cy.contains('CORRECT').should('exist')
  })

  it('renders TraditionalAnswers for Select All That Apply question type', () => {
    const sataAnswers = [
      { answer: 'Option A', correct: true },
      { answer: 'Option B', correct: true },
      { answer: 'Option C', correct: false }
    ]

    cy.mount(<Answers question_type_name='Select All That Apply' answers={sataAnswers} />)

    // Check if TraditionalAnswers is rendered correctly for SATA
    cy.contains('h3', 'Answers').should('exist')
    cy.contains('Option A').should('exist')
    cy.contains('Option B').should('exist')

    // Count the number of rows with the 'correct' class
    cy.get('.correct').should('have.length', 2)

    // Check that CORRECT badges exist
    cy.contains('CORRECT').should('exist')

    // Alternative approach: check that there are 2 rows with CORRECT badges
    cy.get('span').contains('Option A').parents('div.row').find('span').contains('CORRECT').should('exist')
    cy.get('span').contains('Option B').parents('div.row').find('span').contains('CORRECT').should('exist')
  })

  it('renders EssayAnswers for Essay question type', () => {
    const essayAnswers = {
      html: '<p>This is a sample essay answer.</p>'
    }

    cy.mount(<Answers question_type_name='Essay' answers={essayAnswers} />)

    // Check if EssayAnswers is rendered correctly
    cy.get('p').should('contain', 'This is a sample essay answer.')
    cy.contains('h3', 'Answers').should('not.exist')
  })

  it('renders EssayAnswers for Upload question type', () => {
    const uploadAnswers = {
      html: '<p>This is a sample upload answer.</p>'
    }

    cy.mount(<Answers question_type_name='Upload' answers={uploadAnswers} />)

    // Check if EssayAnswers is rendered correctly for Upload
    cy.get('p').should('contain', 'This is a sample upload answer.')
    cy.contains('h3', 'Answers').should('not.exist')
  })

  it('renders StimulusCaseStudyAnswers for Stimulus Case Study question type', () => {
    const stimulusCaseStudyAnswers = [
      {
        text: 'This is a case study scenario.',
        type_label: 'Subquestion 1',
        type_name: 'Multiple Choice',
        data: [
          { answer: 'Option A', correct: true },
          { answer: 'Option B', correct: false }
        ]
      }
    ]

    cy.mount(<Answers question_type_name='Stimulus Case Study' answers={stimulusCaseStudyAnswers} />)

    // Check if StimulusCaseStudyAnswers is rendered correctly
    cy.contains('This is a case study scenario.').should('exist')
    cy.contains('Subquestion 1').should('exist')
    cy.contains('Option A').should('exist')
  })

  it('handles unknown question types gracefully', () => {
    // For unknown question types, we'll just pass an empty array
    // since we're not expecting any specific component to render
    const unknownTypeAnswers = []

    cy.mount(<Answers question_type_name='Unknown Type' answers={unknownTypeAnswers} />)

    // Should render the default "Answers" heading but no specific answer component
    cy.contains('h3', 'Answers').should('exist')
  })
})
