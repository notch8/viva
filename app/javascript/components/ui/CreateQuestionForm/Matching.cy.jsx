import React from 'react'
import Matching from './Matching'

describe('Matching Component', () => {
  beforeEach(() => {
    // Create stubs for functions passed as props
    const handleTextChange = cy.stub().as('handleTextChange')
    const onDataChange = cy.stub().as('onDataChange')

    // Mount the component with initial props
    cy.mount(
      <Matching
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

  it('renders the matching pairs section with correct title', () => {
    cy.contains('Matching Pairs').should('be.visible')
  })

  it('renders the initial number of matching pairs (4)', () => {
    // Check for 4 match sets
    cy.contains('Match Set A').should('be.visible')
    cy.contains('Match Set B').should('be.visible')
    cy.contains('Match Set C').should('be.visible')
    cy.contains('Match Set D').should('be.visible')

    // Check for 8 input fields (2 per pair)
    cy.get('input[placeholder="Answer"]').should('have.length', 4)
    cy.get('input[placeholder="Correct Match"]').should('have.length', 4)
  })

  it('allows typing in the question text field', () => {
    const testInput = 'Match the following items:'
    cy.get('textarea').type(testInput)
    cy.get('@handleTextChange').should('have.been.called')
  })

  it('allows typing in answer fields', () => {
    const testAnswer = 'Paris'
    cy.get('input[placeholder="Answer"]').first().type(testAnswer)
    cy.get('@onDataChange').should('have.been.called')
  })

  it('allows typing in correct match fields', () => {
    const testMatch = 'France'
    cy.get('input[placeholder="Correct Match"]').first().type(testMatch)
    cy.get('@onDataChange').should('have.been.called')
  })

  it('allows adding a new match set', () => {
    // Initially there should be 4 match sets
    cy.get('input[placeholder="Answer"]').should('have.length', 4)

    // Add an additional match set
    cy.contains('button', 'Add Match Set').click()

    // Now there should be 5 match sets
    cy.get('input[placeholder="Answer"]').should('have.length', 5)
    cy.contains('Match Set E').should('be.visible')

    // The onDataChange should be called after adding a new match set
    cy.get('@onDataChange').should('have.been.called')
  })

  it('allows removing a match set', () => {
    // Initially there should be 4 match sets
    cy.get('input[placeholder="Answer"]').should('have.length', 4)

    // Remove the last match set
    cy.get('button').contains('Remove').last().click()

    // Now there should be 3 match sets
    cy.get('input[placeholder="Answer"]').should('have.length', 3)
    cy.contains('Match Set D').should('not.exist')

    // The onDataChange should be called after removing a match set
    cy.get('@onDataChange').should('have.been.called')
  })

  it('disables remove button when only one match set remains', () => {
    // Remove match sets until only one remains
    cy.get('button').contains('Remove').last().click()
    cy.get('button').contains('Remove').last().click()
    cy.get('button').contains('Remove').last().click()

    // Now there should be only 1 match set
    cy.get('input[placeholder="Answer"]').should('have.length', 1)

    // The remove button should be disabled
    cy.get('button').contains('Remove').should('be.disabled')
  })

  it('resets fields when resetFields prop changes', () => {
    // First, add some data to the fields
    cy.get('input[placeholder="Answer"]').first().type('Paris')
    cy.get('input[placeholder="Correct Match"]').first().type('France')

    // Add an additional match set
    cy.contains('button', 'Add Match Set').click()

    // Verify we now have 5 match sets
    cy.get('input[placeholder="Answer"]').should('have.length', 5)

    // Remount the component with resetFields=true
    const handleTextChange = cy.stub().as('handleTextChangeReset')
    const onDataChange = cy.stub().as('onDataChangeReset')

    cy.mount(
      <Matching
        questionText=''
        handleTextChange={handleTextChange}
        onDataChange={onDataChange}
        resetFields={true}
      />
    )

    // Check that the fields are reset to initial state
    cy.get('input[placeholder="Answer"]').should('have.length', 4)
    cy.get('input[placeholder="Answer"]').first().should('have.value', '')
    cy.get('input[placeholder="Correct Match"]').first().should('have.value', '')

    // The onDataChange should be called during reset
    cy.get('@onDataChangeReset').should('have.been.called')
  })
})
