import React from 'react'
import StimulusCaseStudy from './StimulusCaseStudy'

describe('StimulusCaseStudy Component', () => {
  beforeEach(() => {
    // Create stubs for the callback functions
    const handleTextChange = cy.stub().as('handleTextChange')
    const onDataChange = cy.stub().as('onDataChange')

    // Mount the component with default props
    cy.mount(
      <StimulusCaseStudy
        questionText=''
        handleTextChange={handleTextChange}
        onDataChange={onDataChange}
        resetFields={false}
      />
    )
  })

  it('renders the component with correct title', () => {
    cy.contains('Stimulus Case Study').should('be.visible')
    cy.contains('Subquestions').should('be.visible')
  })

  it('renders the QuestionText component', () => {
    cy.contains('Enter Question Text').should('be.visible')
    cy.get('textarea').should('exist')
  })

  it('allows typing in the question text field', () => {
    const testInput = 'This is a case study about...'
    cy.get('textarea').first().type(testInput)
    cy.get('@handleTextChange').should('have.been.called')
  })

  it('allows adding a subquestion', () => {
    // Click the Add Subquestion button
    cy.contains('button', 'Add Subquestion').click()

    // Verify the dropdown appears
    cy.contains('Select Question Type').should('be.visible')
    cy.get('.dropdown-toggle').should('be.visible')

    // Verify onDataChange was called
    cy.get('@onDataChange').should('have.been.called')
  })

  it('allows selecting a question type for a subquestion', () => {
    // Add a subquestion
    cy.contains('button', 'Add Subquestion').click()

    // Reset the onDataChange stub
    cy.get('@onDataChange').invoke('resetHistory')

    // Click the dropdown toggle and select Multiple Choice
    cy.get('.dropdown-toggle').click()
    cy.contains('.dropdown-item', 'Multiple Choice').click()

    // Verify onDataChange was called
    cy.get('@onDataChange').should('have.been.called')
  })

  it('allows removing a subquestion', () => {
    // Add a subquestion
    cy.contains('button', 'Add Subquestion').click()

    // Reset the onDataChange stub
    cy.get('@onDataChange').invoke('resetHistory')

    // Click the Remove Subquestion button
    cy.contains('button', 'Remove Subquestion').click()

    // Verify the dropdown is no longer present
    cy.contains('Select Question Type').should('not.exist')

    // Verify onDataChange was called
    cy.get('@onDataChange').should('have.been.called')
  })

  it('allows adding multiple subquestions', () => {
    // Add first subquestion
    cy.contains('button', 'Add Subquestion').click()

    // Add second subquestion
    cy.contains('button', 'Add Subquestion').click()

    // Verify there are multiple dropdown toggles
    cy.get('.dropdown-toggle').should('have.length.at.least', 2)
  })

  it('allows interacting with subquestion components', () => {
    // Add a subquestion and select Multiple Choice
    cy.contains('button', 'Add Subquestion').click()
    cy.get('.dropdown-toggle').click()
    cy.contains('.dropdown-item', 'Multiple Choice').click()

    // Reset the onDataChange stub
    cy.get('@onDataChange').invoke('resetHistory')

    // Type in an answer field
    cy.get('input[type="text"]').first().type('Option A')

    // Verify onDataChange was called
    cy.get('@onDataChange').should('have.been.called')
  })

  it('preserves data when adding multiple subquestions', () => {
    // Add first subquestion and configure it
    cy.contains('button', 'Add Subquestion').click()
    cy.get('.dropdown-toggle').click()
    cy.contains('.dropdown-item', 'Multiple Choice').click()
    cy.get('input[type="text"]').first().type('Option A')

    // Add second subquestion
    cy.contains('button', 'Add Subquestion').click()

    // Verify first subquestion still has its data
    cy.get('input[type="text"]').first().should('have.value', 'Option A')
  })
})
