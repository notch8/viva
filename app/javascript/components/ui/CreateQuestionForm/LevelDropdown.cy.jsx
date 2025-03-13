import React from 'react'
import LevelDropdown from './LevelDropdown'
import { LEVELS } from '../../../constants/levels.js'

describe('LevelDropdown Component', () => {
  beforeEach(() => {
    // Create a stub for the handleLevelSelection function
    const handleLevelSelection = cy.stub().as('handleLevelSelection')

    // Mount the component with required props
    cy.mount(
      <LevelDropdown
        handleLevelSelection={handleLevelSelection}
      />
    )
  })

  it('renders the dropdown with the default text', () => {
    cy.get('.dropdown-toggle').should('contain', 'Level')
  })

  it('renders the form label correctly', () => {
    cy.get('label').should('contain', 'Select Level')
    cy.get('.fw-bold').should('exist')
  })

  it('displays all level options when clicked', () => {
    cy.get('.dropdown-toggle').click()

    LEVELS.forEach(level => {
      cy.get('.dropdown-menu').should('contain', level.key)
    })
  })

  it('selects a level when clicked', () => {
    const selectedLevel = LEVELS[2] // Level 2

    cy.get('.dropdown-toggle').click()
    cy.get('.dropdown-item').contains(selectedLevel.key).click()

    // Check that the dropdown button now shows the selected level
    cy.get('.dropdown-toggle').should('contain', selectedLevel.key)

    // Check that the selection handler was called with the correct value
    cy.get('@handleLevelSelection').should('have.been.calledWith', selectedLevel.value)
  })

  it('selects "No Level" when clicked', () => {
    const noLevel = LEVELS[0] // No Level

    cy.get('.dropdown-toggle').click()
    cy.get('.dropdown-item').contains(noLevel.key).click()

    // Check that the dropdown button now shows "No Level"
    cy.get('.dropdown-toggle').should('contain', noLevel.key)

    // Check that the selection handler was called with an empty string
    cy.get('@handleLevelSelection').should('have.been.calledWith', noLevel.value)
  })
})
