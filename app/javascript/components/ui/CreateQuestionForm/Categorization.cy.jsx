import React from 'react'
import Categorization from './Categorization'

describe('Categorization Component', () => {
  beforeEach(() => {
    // Create stubs for the callback functions
    const handleTextChange = cy.stub().as('handleTextChange')
    const onDataChange = cy.stub().as('onDataChange')

    // Mount the component with default props
    cy.mount(
      <Categorization
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

  it('renders the Categorization title', () => {
    cy.contains('Categorization').should('be.visible')
  })

  it('renders the initial category and correct value fields', () => {
    // Should have one category input
    cy.get('input[placeholder="Category"]').should('have.length', 1)

    // Should have one correct match input
    cy.get('input[placeholder="Correct Match"]').should('have.length', 1)
  })

  it('allows typing in the question text field', () => {
    const testInput = 'Categorize the following items:'
    cy.get('textarea').type(testInput)
    cy.get('@handleTextChange').should('have.been.called')
  })

  it('allows typing in category field', () => {
    const testCategory = 'Fruits'
    cy.get('input[placeholder="Category"]').type(testCategory)
    cy.get('@onDataChange').should('have.been.called')
  })

  it('allows typing in correct match field', () => {
    const testMatch = 'Apple'
    cy.get('input[placeholder="Correct Match"]').type(testMatch)
    cy.get('@onDataChange').should('have.been.called')
  })

  it('allows adding a new category', () => {
    // Initially there should be 1 category
    cy.get('input[placeholder="Category"]').should('have.length', 1)

    // Click the "Add Category" button
    cy.contains('button', 'Add Category').click()

    // Now there should be 2 categories
    cy.get('input[placeholder="Category"]').should('have.length', 2)

    // Verify onDataChange was called
    cy.get('@onDataChange').should('have.been.called')
  })

  it('allows adding a new correct value to a category', () => {
    // Initially there should be 1 correct match input
    cy.get('input[placeholder="Correct Match"]').should('have.length', 1)

    // Click the "Add Correct Value" button
    cy.contains('button', 'Add Correct Value').click()

    // Now there should be 2 correct match inputs
    cy.get('input[placeholder="Correct Match"]').should('have.length', 2)

    // Verify onDataChange was called
    cy.get('@onDataChange').should('have.been.called')
  })

  it('disables remove category button when only one category remains', () => {
    // The remove category button should be disabled when there's only one category
    cy.contains('button', 'Remove Category').should('be.disabled')

    // Add a new category
    cy.contains('button', 'Add Category').click()

    // Now the remove buttons should be enabled
    cy.contains('button', 'Remove Category').should('not.be.disabled')
  })

  it('disables remove correct value button when only one correct value remains', () => {
    cy.get('input[placeholder="Correct Match"]').parent().find('button').contains('Remove').should('be.disabled')

    // Add a new correct value
    cy.contains('button', 'Add Correct Value').click()

    // Now the remove button should be enabled
    cy.get('input[placeholder="Correct Match"]').first().parent().find('button').contains('Remove').should('not.be.disabled')
  })

  it('allows removing a category', () => {
    // Add a new category first
    cy.contains('button', 'Add Category').click()

    // Now there should be 2 categories
    cy.get('input[placeholder="Category"]').should('have.length', 2)

    // Click the first "Remove Category" button
    cy.contains('button', 'Remove Category').first().click()

    // Now there should be 1 category again
    cy.get('input[placeholder="Category"]').should('have.length', 1)

    // Verify onDataChange was called
    cy.get('@onDataChange').should('have.been.called')
  })

  it('allows removing a correct value', () => {
    // Add a new correct value first
    cy.contains('button', 'Add Correct Value').click()

    // Now there should be 2 correct match inputs
    cy.get('input[placeholder="Correct Match"]').should('have.length', 2)

    // Click the first "Remove" button for correct values using a more specific selector
    cy.get('input[placeholder="Correct Match"]').first().parent().find('button').contains('Remove').click()

    // Now there should be 1 correct match input again
    cy.get('input[placeholder="Correct Match"]').should('have.length', 1)

    // Verify onDataChange was called
    cy.get('@onDataChange').should('have.been.called')
  })

  it('resets fields when resetFields prop changes', () => {
    // Add a new category and correct value
    cy.contains('button', 'Add Category').click()
    cy.contains('button', 'Add Correct Value').click()

    // Type in some values
    cy.get('input[placeholder="Category"]').first().type('Fruits')
    cy.get('input[placeholder="Correct Match"]').first().type('Apple')

    // Remount the component with resetFields=true
    const handleTextChange = cy.stub().as('handleTextChangeReset')
    const onDataChange = cy.stub().as('onDataChangeReset')

    cy.mount(
      <Categorization
        questionText=''
        handleTextChange={handleTextChange}
        onDataChange={onDataChange}
        resetFields={true}
      />
    )

    // Verify that we're back to 1 category and 1 correct match
    cy.get('input[placeholder="Category"]').should('have.length', 1)
    cy.get('input[placeholder="Correct Match"]').should('have.length', 1)

    // Verify that the fields are empty
    cy.get('input[placeholder="Category"]').should('have.value', '')
    cy.get('input[placeholder="Correct Match"]').should('have.value', '')

    // Verify onDataChange was called during reset
    cy.get('@onDataChangeReset').should('have.been.called')
  })
})
