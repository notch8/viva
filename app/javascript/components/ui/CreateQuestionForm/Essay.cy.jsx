import React from 'react'
import Essay from './Essay'

describe('Essay Component', () => {
  beforeEach(() => {
    // Create a stub for functions passed as props
    const handleTextChange = cy.stub().as('handleTextChange')
    const handleSubmit = cy.stub().as('handleSubmit')

    // Mount the component with initial props
    cy.mount(
      <Essay
        questionText=''
        handleTextChange={handleTextChange}
        handleSubmit={handleSubmit}
      />
    )
  })

  it('renders the QuestionText component with correct label', () => {
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
    const handleSubmit = cy.stub().as('handleSubmitWithText')

    cy.mount(
      <Essay
        questionText={testText}
        handleTextChange={handleTextChange}
        handleSubmit={handleSubmit}
      />
    )
    cy.get('textarea').should('have.value', testText)
  })

  it('calls handleTextChange when text is entered', () => {
    const testInput = 'New question text'
    cy.get('textarea').type(testInput)
    cy.get('@handleTextChange').should('have.been.called')
  })

  it('has the correct styling classes', () => {
    cy.get('textarea')
      .should('have.class', 'mr-4')
      .should('have.class', 'p-2')
      .should('have.class', 'mb-4')

    cy.get('.fw-bold').should('exist')
  })
})
