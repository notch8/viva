import React from 'react'
import MultipleChoice from './MultipleChoice'

describe('MultipleChoice Component', () => {
  beforeEach(() => {
    // Create a stub for functions passed as props
    const handleTextChange = cy.stub().as('handleTextChange')
    const onDataChange = cy.stub().as('onDataChange')

    // Mount the component with initial props
    cy.mount(
      <MultipleChoice
        questionText=''
        handleTextChange={handleTextChange}
        onDataChange={onDataChange}
        resetFields={false}
      />
    )
  })

  it('renders the QuestionText component', () => {
    cy.get('label').contains('Enter Question Text').should('be.visible')
    cy.get('textarea').should('exist')
  })

  it('renders the AnswerSet component with correct title', () => {
    cy.contains('Answers').should('be.visible')
  })

  it('renders the initial number of answer fields (4)', () => {
    cy.get('input[type="text"][placeholder^="Answer"]').should('have.length', 4)
  })

  it('allows typing in the question text field', () => {
    const testInput = 'What is the capital of France?'
    cy.get('textarea').first().type(testInput)
    cy.get('@handleTextChange').should('have.been.called')
  })

  it('allows typing in answer fields', () => {
    const testAnswer = 'Paris'
    cy.get('input[type="text"][placeholder="Answer 1"]').type(testAnswer)
    cy.get('@onDataChange').should('have.been.called')
  })

  it('allows selecting a correct answer', () => {
    cy.get('.form-check').first().within(() => {
      // Find and click the input inside the first form-check
      cy.get('input').click({ force: true })
    })
    cy.get('@onDataChange').should('have.been.called')
  })

  it('allows adding a new answer field', () => {
    // Initially there should be 4 answer fields
    cy.get('input[type="text"][placeholder^="Answer"]').should('have.length', 4)
    // Add an additional answer field
    cy.contains('button', 'Add Answer').click({ force: true })
    // Now there should be 5 answer fields
    cy.get('input[type="text"][placeholder^="Answer"]').should('have.length', 5)
  })

  it('resets fields when resetFields prop changes', () => {
    // First, add some data to the fields
    const testQuestion = 'Test question'
    const testAnswer = 'Test answer'

    cy.get('textarea').first().type(testQuestion)
    cy.get('input[type="text"][placeholder="Answer 1"]').type(testAnswer)

    // Use the same approach as in the "allows selecting a correct answer" test
    cy.get('.form-check').first().within(() => {
      cy.get('input').click({ force: true })
    })

    // Remount the component with resetFields=true
    const handleTextChange = cy.stub().as('handleTextChangeReset')
    const onDataChange = cy.stub().as('onDataChangeReset')

    cy.mount(
      <MultipleChoice
        questionText=''
        handleTextChange={handleTextChange}
        onDataChange={onDataChange}
        resetFields={true}
      />
    )

    // Check that the fields are reset
    cy.get('input[type="text"][placeholder="Answer 1"]').should('have.value', '')
  })
})
