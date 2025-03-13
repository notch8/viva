import React from 'react'
import DragAndDropAnswers from './DragAndDropAnswers'

describe('DragAndDropAnswers Component', () => {
  const mockAnswers = [
    { answer: 'Paris', correct: true },
    { answer: 'London', correct: true },
    { answer: 'Berlin', correct: true },
    { answer: 'Madrid', correct: true },
    { answer: 'New York', correct: false },
    { answer: 'Tokyo', correct: false },
    { answer: 'Sydney', correct: false }
  ]

  beforeEach(() => {
    // Mount the component with mock data
    cy.mount(<DragAndDropAnswers answers={mockAnswers} />)
  })

  it('renders the correct answers section', () => {
    // Check if the container exists
    cy.get('.DragAndDropAnswers').should('exist')

    // Check if all correct answers are rendered
    cy.get('.correct-answer').should('have.length', 4)

    // Check the content of each correct answer
    cy.get('.correct-answer').eq(0).should('contain', 'Paris')
    cy.get('.correct-answer').eq(1).should('contain', 'London')
    cy.get('.correct-answer').eq(2).should('contain', 'Berlin')
    cy.get('.correct-answer').eq(3).should('contain', 'Madrid')
  })

  it('renders the incorrect answers section', () => {
    // Check if the incorrect answers section is rendered
    cy.get('.incorrect-question-answers').should('exist')
    cy.contains('h4', 'Incorrect Answers').should('be.visible')

    // Check if all incorrect answers are rendered
    cy.get('.incorrect-question-answers .col-md-6').should('have.length', 3)

    // Check the content of each incorrect answer
    cy.get('.incorrect-question-answers .col-md-6').eq(0).should('contain', 'New York')
    cy.get('.incorrect-question-answers .col-md-6').eq(1).should('contain', 'Tokyo')
    cy.get('.incorrect-question-answers .col-md-6').eq(2).should('contain', 'Sydney')

    // Check if each incorrect answer has a Square icon
    cy.get('.incorrect-question-answers .col-md-6 svg').should('have.length', 3)
  })

  it('handles empty answers array gracefully', () => {
    // Mount the component with an empty answers array
    cy.mount(<DragAndDropAnswers answers={[]} />)

    // Check if the component renders without errors
    cy.get('.DragAndDropAnswers').should('exist')

    // Check that no correct answers are rendered
    cy.get('.correct-answer').should('not.exist')

    // Check that the incorrect answers section is not rendered
    cy.get('.incorrect-question-answers').should('not.exist')
  })

  it('handles only correct answers', () => {
    const onlyCorrectAnswers = [
      { answer: 'Paris', correct: true },
      { answer: 'London', correct: true }
    ]

    // Mount the component with only correct answers
    cy.mount(<DragAndDropAnswers answers={onlyCorrectAnswers} />)

    // Check if the correct answers are rendered
    cy.get('.correct-answer').should('have.length', 2)

    // Check that the incorrect answers section is not rendered
    cy.get('.incorrect-question-answers').should('not.exist')
  })

  it('handles only incorrect answers', () => {
    const onlyIncorrectAnswers = [
      { answer: 'New York', correct: false },
      { answer: 'Tokyo', correct: false }
    ]

    // Mount the component with only incorrect answers
    cy.mount(<DragAndDropAnswers answers={onlyIncorrectAnswers} />)

    // Check that no correct answers are rendered
    cy.get('.correct-answer').should('not.exist')

    // Check if the incorrect answers section is rendered
    cy.get('.incorrect-question-answers').should('exist')
    cy.get('.incorrect-question-answers .col-md-6').should('have.length', 2)
  })

  it('applies the correct styling to answers', () => {
    // Check if the correct answers container has the right classes
    cy.get('.DragAndDropAnswers .row').should('have.class', 'bg-white').and('have.class', 'rounded')

    // Check if each correct answer has the right classes
    cy.get('.correct-answer').each($col => {
      cy.wrap($col)
        .should('have.class', 'border-end')
        .and('have.class', 'py-3')
    })

    // Check if the incorrect answers section has the right layout
    cy.get('.incorrect-question-answers > div').should('have.class', 'd-flex')
      .and('have.class', 'flex-wrap')
      .and('have.class', 'justify-content-between')

    // Check if each incorrect answer has the right column width
    cy.get('.incorrect-question-answers .col-md-6').each($col => {
      cy.wrap($col).should('have.class', 'py-2')
    })
  })

  it('renders a large number of answers correctly', () => {
    const manyAnswers = [
      { answer: 'Item 1', correct: true },
      { answer: 'Item 2', correct: true },
      { answer: 'Item 3', correct: true },
      { answer: 'Item 4', correct: true },
      { answer: 'Item 5', correct: true },
      { answer: 'Item 6', correct: true },
      { answer: 'Item 7', correct: false },
      { answer: 'Item 8', correct: false },
      { answer: 'Item 9', correct: false },
      { answer: 'Item 10', correct: false }
    ]

    // Mount the component with many answers
    cy.mount(<DragAndDropAnswers answers={manyAnswers} />)

    // Check if all correct answers are rendered
    cy.get('.correct-answer').should('have.length', 6)

    // Check if all incorrect answers are rendered
    cy.get('.incorrect-question-answers .col-md-6').should('have.length', 4)
  })

  it('handles answers with long text', () => {
    const longTextAnswers = [
      { answer: 'This is a very long answer that should still be displayed properly in the correct answers section without breaking the layout', correct: true },
      { answer: 'This is another very long answer that should be displayed in the incorrect answers section without any issues', correct: false }
    ]

    // Mount the component with long text answers
    cy.mount(<DragAndDropAnswers answers={longTextAnswers} />)

    // Check if the long correct answer is rendered
    cy.get('.correct-answer').should('have.length', 1)
    cy.get('.correct-answer').should('contain', 'This is a very long answer')

    // Check if the long incorrect answer is rendered
    cy.get('.incorrect-question-answers .col-md-6').should('have.length', 1)
    cy.get('.incorrect-question-answers .col-md-6').should('contain', 'This is another very long answer')
  })
})
