import React from 'react'
import DragAndDrop from './DragAndDrop'

describe('DragAndDrop Component', () => {
  beforeEach(() => {
    // Create stubs for the callback functions
    const handleTextChange = cy.stub().as('handleTextChange')
    const onDataChange = cy.stub().as('onDataChange')

    // Mount the component with default props
    cy.mount(
      <DragAndDrop
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

  it('renders the initial answer field', () => {
    cy.get('input[type="text"]').should('have.length.at.least', 1)
    cy.get('input[type="checkbox"]').should('have.length.at.least', 1)
  })

  it('allows typing in the question text field', () => {
    const testInput = 'Drag and drop the following items:'
    cy.get('textarea').type(testInput)
    cy.get('@handleTextChange').should('have.been.called')
  })

  it('allows typing in the answer field', () => {
    const testAnswer = 'Option A'
    cy.get('input[type="text"]').first().type(testAnswer)
    cy.get('@onDataChange').should('have.been.called')
  })

  it('allows marking an answer as correct', () => {
    // First type something in the answer field
    cy.get('input[type="text"]').first().type('Option A')

    // Click the checkbox to mark it as correct
    cy.get('input[type="checkbox"]').first().click()
    cy.get('@onDataChange').should('have.been.called')
  })

  it('allows adding a new answer field', () => {
    // Get the initial count of text inputs
    cy.get('input[type="text"]').then($inputs => {
      const initialCount = $inputs.length

      // Find and click the Add Answer button
      cy.get('button').contains(/Add Answer|Add/).click()

      // Verify that a new answer field was added
      cy.get('input[type="text"]').should('have.length.at.least', initialCount + 1)

      // Type something in the new field to ensure onDataChange is triggered
      cy.get('input[type="text"]').eq(initialCount).type('New answer')
      cy.get('@onDataChange').should('have.been.called')
    })
  })

  it('disables remove button when only one answer field remains', () => {
    // Find all Remove buttons
    cy.get('button').contains('Remove').should('be.disabled')

    // Add a new answer field
    cy.get('button').contains(/Add Answer|Add/).click()

    // Now at least one Remove button should be enabled
    cy.get('button').contains('Remove').should('not.be.disabled')
  })

  it('allows removing an answer field', () => {
    // Add a new answer field first
    cy.get('button').contains(/Add Answer|Add/).click()

    // Type something in the fields to ensure onDataChange is triggered
    cy.get('input[type="text"]').first().clear().type('First answer')
    cy.get('input[type="text"]').last().type('Second answer')
    cy.get('@onDataChange').invoke('resetHistory')

    // Get the count of text inputs after adding
    cy.get('input[type="text"]').then($inputs => {
      const countAfterAdding = $inputs.length

      // Find and click a Remove button
      cy.get('button').contains('Remove').first().click()

      // Verify that an answer field was removed
      cy.get('input[type="text"]').should('have.length', countAfterAdding - 1)
      cy.get('@onDataChange').should('have.been.called')
    })
  })

  it('allows multiple answers to be marked as correct', () => {
    // Add a new answer field
    cy.get('button').contains(/Add Answer|Add/).click()

    // Type in both answer fields
    cy.get('input[type="text"]').first().type('Option A')
    cy.get('input[type="text"]').last().type('Option B')

    // Mark both answers as correct
    cy.get('input[type="checkbox"]').first().click()
    cy.get('input[type="checkbox"]').last().click()

    // Both checkboxes should be checked
    cy.get('input[type="checkbox"]').first().should('be.checked')
    cy.get('input[type="checkbox"]').last().should('be.checked')
    cy.get('@onDataChange').should('have.been.called')
  })

  it('shows validation message when no correct answer is selected', () => {
    // Type in the answer field without marking it as correct
    cy.get('input[type="text"]').first().type('Option A')

    // Validation message should be visible
    cy.contains('Please mark at least one non-empty answer as correct').should('be.visible')
  })

  it('resets fields when resetFields prop changes', () => {
    // Add a new answer field and type in values
    cy.get('button').contains(/Add Answer|Add/).click()
    cy.get('input[type="text"]').first().type('Option A')
    cy.get('input[type="text"]').last().type('Option B')
    cy.get('input[type="checkbox"]').first().click()

    // Remount the component with resetFields=true
    const handleTextChange = cy.stub().as('handleTextChangeReset')
    const onDataChange = cy.stub().as('onDataChangeReset')

    cy.mount(
      <DragAndDrop
        questionText=''
        handleTextChange={handleTextChange}
        onDataChange={onDataChange}
        resetFields={true}
      />
    )

    // Verify that we're back to the initial state
    cy.get('input[type="text"]').should('have.length', 1)

    // Verify that the field is empty and checkbox is unchecked
    cy.get('input[type="text"]').first().should('have.value', '')
    cy.get('input[type="checkbox"]').first().should('not.be.checked')
  })
})
