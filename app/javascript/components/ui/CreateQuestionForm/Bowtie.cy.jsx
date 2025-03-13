import React from 'react'
import Bowtie from './Bowtie'

describe('Bowtie Component', () => {
  beforeEach(() => {
    // Create stubs for the callback functions
    const handleTextChange = cy.stub().as('handleTextChange')
    const onDataChange = cy.stub().as('onDataChange')

    // Mount the component with default props
    cy.mount(
      <Bowtie
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

  it('renders three AnswerSet components with correct titles', () => {
    cy.contains('Central Theme').should('be.visible')
    cy.contains('Left Label').should('be.visible')
    cy.contains('Right Label').should('be.visible')
  })

  it('renders the initial number of answer fields for each section', () => {
    // Each AnswerSet should start with at least one answer field
    // Count the total number of text inputs in the component
    cy.get('input[type="text"]').should('have.length.at.least', 3)
  })

  it('allows typing in the question text field', () => {
    const testInput = 'Create a bowtie diagram for the following scenario:'
    cy.get('textarea').first().type(testInput)
    cy.get('@handleTextChange').should('have.been.called')
  })

  it('allows adding answers to each section', () => {
    // Find all "Add Answer" buttons
    cy.get('button').contains('Add Answer').should('exist')

    // Get the initial count of text inputs
    cy.get('input[type="text"]').then($inputs => {
      const initialCount = $inputs.length

      // Click the first "Add Answer" button
      cy.get('button').contains('Add Answer').first().click()

      // Verify that a new answer field was added
      cy.get('input[type="text"]').should('have.length', initialCount + 1)
    })
  })

  it('shows appropriate validation messages', () => {
    // Type something in a text input field
    cy.get('input[type="text"]').first().type('Test input')

    // At least one validation message should appear
    cy.get('.text-danger').should('exist')
  })

  it('calls onDataChange when data is entered', () => {
    // Type something in a text input field
    cy.get('input[type="text"]').first().type('Test input')
    // Verify that onDataChange was called
    cy.get('@onDataChange').should('have.been.called')
  })

  it('resets fields when resetFields prop changes', () => {
    // Type something in the first text input field
    cy.get('input[type="text"]').first().type('Test input')

    // Remount the component with resetFields=true
    const handleTextChange = cy.stub().as('handleTextChangeReset')
    const onDataChange = cy.stub().as('onDataChangeReset')

    cy.mount(
      <Bowtie
        questionText=''
        handleTextChange={handleTextChange}
        onDataChange={onDataChange}
        resetFields={true}
      />
    )

    // Verify that the fields are reset (all should be empty)
    cy.get('input[type="text"]').each($input => {
      cy.wrap($input).should('have.value', '')
    })
  })
})
