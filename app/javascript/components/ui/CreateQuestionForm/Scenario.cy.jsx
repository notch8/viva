import React from 'react'
import Scenario from './Scenario'

describe('Scenario Component', () => {
  beforeEach(() => {
    // Create a stub for functions passed as props
    const handleTextChange = cy.stub().as('handleTextChange')

    // Mount the component with initial props
    cy.mount(
      <Scenario
        scenarioText=''
        handleTextChange={handleTextChange}
      />
    )
  })

  it('renders the component with correct labels', () => {
    cy.get('label').contains('Enter Scenario Text').should('be.visible')
    cy.contains('*Required Field').should('be.visible')
  })

  it('renders the textarea with correct placeholder', () => {
    cy.get('textarea')
      .should('have.attr', 'placeholder', 'Enter your scenario text here')
      .should('have.attr', 'rows', '5')
  })

  it('displays the provided scenario text', () => {
    const testText = 'Test scenario text'
    const handleTextChange = cy.stub().as('handleTextChangeWithText')

    cy.mount(
      <Scenario
        scenarioText={testText}
        handleTextChange={handleTextChange}
      />
    )
    cy.get('textarea').should('have.value', testText)
  })

  it('calls handleTextChange when text is entered', () => {
    const testInput = 'New scenario text'
    cy.get('textarea').type(testInput)
    cy.get('@handleTextChange').should('have.been.called')
  })
})
