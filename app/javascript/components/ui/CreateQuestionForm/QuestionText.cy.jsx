import React from 'react'
import QuestionText from './QuestionText'

describe('QuestionText Component', () => {
  beforeEach(() => {
    // Create a stub for functions passed as props
    const handleTextChange = cy.stub().as('handleTextChange')

    // Mount the component with initial props
    cy.mount(
      <QuestionText
        questionText=''
        handleTextChange={handleTextChange}
      />
    )
  })

  it('renders the component with correct label', () => {
    cy.get('label').contains('Enter Question Text').should('be.visible')
    cy.contains('*Required Field').should('be.visible')
  })

  it('renders the textarea with correct placeholder', () => {
    cy.get('textarea')
      .should('have.attr', 'placeholder', 'Enter your question text here')
      .should('have.attr', 'rows', '5')
  })

  it('displays the provided question text', () => {
    const testText = 'Test question text'
    const handleTextChange = cy.stub().as('handleTextChangeWithText')

    cy.mount(
      <QuestionText
        questionText={testText}
        handleTextChange={handleTextChange}
      />
    )
    cy.get('textarea').should('have.value', testText)
  })

  it('calls handleTextChange when text is entered', () => {
    const testInput = 'New question text'
    cy.get('textarea').type(testInput)
    cy.get('@handleTextChange').should('have.been.called')
  })
})
