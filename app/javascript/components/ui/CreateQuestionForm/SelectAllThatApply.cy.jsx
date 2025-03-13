import React from 'react'
import SelectAllThatApply from './SelectAllThatApply'

describe('SelectAllThatApply Component', () => {
  beforeEach(() => {
    // Create stubs for the callback functions
    const handleTextChange = cy.stub().as('handleTextChange')
    const onDataChange = cy.stub().as('onDataChange')

    // Mount the component with default props
    cy.mount(
      <SelectAllThatApply
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

  it('renders the initial answer fields', () => {
    // SelectAllThatApply should start with 4 answer fields
    cy.get('input[type="text"]').should('have.length', 4)
    cy.get('input[type="checkbox"]').should('have.length', 4)
  })

  it('allows typing in the question text field', () => {
    const testInput = 'Select all options that apply:'
    cy.get('textarea').type(testInput)
    cy.get('@handleTextChange').should('have.been.called')
  })

  it('allows typing in the answer fields', () => {
    // Type in the first answer field
    const testAnswer = 'Option A'
    cy.get('input[type="text"]').first().type(testAnswer)
    cy.get('@onDataChange').should('have.been.called')
  })

  it('allows marking answers as correct', () => {
    // First type something in the answer field
    cy.get('input[type="text"]').first().type('Option A')
    // Reset the onDataChange stub to check if it's called after clicking the checkbox
    cy.get('@onDataChange').invoke('resetHistory')

    // Click the checkbox to mark it as correct
    cy.get('input[type="checkbox"]').first().click()
    cy.get('@onDataChange').should('have.been.called')
  })

  it('allows adding a new answer field', () => {
    // Get the initial count of text inputs (should be 4)
    cy.get('input[type="text"]').then($inputs => {
      const initialCount = $inputs.length

      // Find and click the Add Answer button
      cy.get('button').contains(/Add Answer|Add/).click()

      // Verify that a new answer field was added
      cy.get('input[type="text"]').should('have.length', initialCount + 1)

      // Reset the onDataChange stub to check if it's called after typing
      cy.get('@onDataChange').invoke('resetHistory')

      // Type something in the new field to ensure onDataChange is triggered
      cy.get('input[type="text"]').eq(initialCount).type('New answer')
      cy.get('@onDataChange').should('have.been.called')
    })
  })

  it('disables remove button when only one answer field remains', () => {
    // Initially there should be 4 answer fields, so Remove buttons should be enabled
    cy.get('button').contains('Remove').first().should('not.be.disabled')

    // Remove answer fields until only one remains
    cy.get('button').contains('Remove').first().click()
    cy.get('button').contains('Remove').first().click()
    cy.get('button').contains('Remove').first().click()

    // Now the last Remove button should be disabled
    cy.get('button').contains('Remove').should('be.disabled')
  })

  it('allows removing an answer field', () => {
    // Get the initial count of text inputs
    cy.get('input[type="text"]').then($inputs => {
      const initialCount = $inputs.length

      // Type something in the first field to ensure onDataChange is triggered
      cy.get('input[type="text"]').first().clear().type('First answer')

      // Wait for the debounce timeout
      cy.wait(500)

      // Reset the onDataChange stub to check if it's called after removing
      cy.get('@onDataChange').invoke('resetHistory')

      // Find and click a Remove button
      cy.get('button').contains('Remove').first().click()

      // Verify that an answer field was removed
      cy.get('input[type="text"]').should('have.length', initialCount - 1)
      cy.get('@onDataChange').should('have.been.called')
    })
  })

  it('allows multiple answers to be marked as correct', () => {
    // Type in multiple answer fields
    cy.get('input[type="text"]').eq(0).type('Option A')
    cy.get('input[type="text"]').eq(1).type('Option B')
    cy.get('input[type="text"]').eq(2).type('Option C')

    // Reset the onDataChange stub to check if it's called after clicking checkboxes
    cy.get('@onDataChange').invoke('resetHistory')

    // Mark multiple answers as correct
    cy.get('input[type="checkbox"]').eq(0).click()
    cy.get('input[type="checkbox"]').eq(2).click()

    // Verify checkboxes are checked
    cy.get('input[type="checkbox"]').eq(0).should('be.checked')
    cy.get('input[type="checkbox"]').eq(1).should('not.be.checked')
    cy.get('input[type="checkbox"]').eq(2).should('be.checked')
    cy.get('@onDataChange').should('have.been.called')
  })

  it('shows validation message when no correct answer is selected', () => {
    // Type in the answer fields without marking any as correct
    cy.get('input[type="text"]').eq(0).type('Option A')
    cy.get('input[type="text"]').eq(1).type('Option B')

    // Validation message should be visible
    cy.contains('Please mark at least one non-empty answer as correct').should('be.visible')
  })

  it('resets fields when resetFields prop changes', () => {
    // Type in answer fields and mark some as correct
    cy.get('input[type="text"]').eq(0).type('Option A')
    cy.get('input[type="text"]').eq(1).type('Option B')
    cy.get('input[type="checkbox"]').first().click()

    // Remount the component with resetFields=true
    const handleTextChange = cy.stub().as('handleTextChangeReset')
    const onDataChange = cy.stub().as('onDataChangeReset')

    cy.mount(
      <SelectAllThatApply
        questionText=''
        handleTextChange={handleTextChange}
        onDataChange={onDataChange}
        resetFields={true}
      />
    )

    // Verify that fields are reset to initial state (4 empty fields)
    cy.get('input[type="text"]').should('have.length', 4)

    // Verify that all fields are empty and checkboxes are unchecked
    cy.get('input[type="text"]').each($input => {
      cy.wrap($input).should('have.value', '')
    })

    cy.get('input[type="checkbox"]').each($checkbox => {
      cy.wrap($checkbox).should('not.be.checked')
    })
  })
})
