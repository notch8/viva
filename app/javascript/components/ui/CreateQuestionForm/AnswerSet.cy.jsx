import React from 'react'
import AnswerSet from './AnswerSet'

describe('AnswerSet Component', () => {
  describe('with single correct answer (radio buttons)', () => {
    beforeEach(() => {
      // Create a stub for the getAnswerSet callback
      const getAnswerSet = cy.stub().as('getAnswerSet')

      // Mount the component with default props
      cy.mount(
        <AnswerSet
          resetFields={false}
          getAnswerSet={getAnswerSet}
          title='Test Answers'
          multipleCorrectAnswers={false}
          numberOfDisplayedAnswers={3}
        />
      )
    })

    it('renders the AnswerField component with the correct title', () => {
      cy.contains('Test Answers').should('be.visible')
    })

    it('renders the initial number of answer fields', () => {
      // Should have 3 text inputs as specified in numberOfDisplayedAnswers
      cy.get('input[type="text"]').should('have.length', 3)
    })

    it('renders the Add Answer button', () => {
      cy.get('button.btn-secondary').contains('Add Answer').should('be.visible')
    })

    it('adds a new answer field when clicking Add Answer', () => {
      // Initially there should be 3 answer fields
      cy.get('input[type="text"]').should('have.length', 3)

      // Click the Add Answer button
      cy.get('button.btn-secondary').contains('Add Answer').click()

      // Now there should be 4 answer fields
      cy.get('input[type="text"]').should('have.length', 4)
    })

    it('shows validation message when no correct answer is selected', () => {
      // Type something in the first answer field to trigger validation
      cy.get('input[type="text"]').first().type('Test answer')
      cy.contains('Please mark exactly one answer as correct').should('be.visible')
    })
  })

  describe('with multiple correct answers (checkboxes)', () => {
    beforeEach(() => {
      // Create a stub for the getAnswerSet callback
      const getAnswerSet = cy.stub().as('getAnswerSet')

      // Mount the component with multipleCorrectAnswers=true
      cy.mount(
        <AnswerSet
          resetFields={false}
          getAnswerSet={getAnswerSet}
          title='Multiple Correct Answers'
          multipleCorrectAnswers={true}
          numberOfDisplayedAnswers={3}
        />
      )
    })

    it('renders checkbox buttons instead of radio buttons', () => {
      cy.get('input[type="checkbox"]').should('have.length', 3)
    })

    it('shows validation message when no correct answer is selected', () => {
      // Type something in the first answer field to trigger validation
      cy.get('input[type="text"]').first().type('Test answer')

      // The validation message should be visible
      cy.contains('Please mark at least one non-empty answer as correct').should('be.visible')
    })
  })

  describe('reset functionality', () => {
    it('resets fields when resetFields prop changes', () => {
      // Create a stub for the getAnswerSet callback
      const getAnswerSet = cy.stub().as('getAnswerSet')

      // Mount the component with resetFields=false
      cy.mount(
        <AnswerSet
          resetFields={false}
          getAnswerSet={getAnswerSet}
          title='Test Answers'
          multipleCorrectAnswers={false}
          numberOfDisplayedAnswers={2}
        />
      )

      // Add an additional answer field
      cy.get('button.btn-secondary').contains('Add Answer').click()

      // Now there should be 3 answer fields
      cy.get('input[type="text"]').should('have.length', 3)

      // Type something in the first answer field
      cy.get('input[type="text"]').first().type('Test answer')

      // Remount the component with resetFields=true
      cy.mount(
        <AnswerSet
          resetFields={true}
          getAnswerSet={getAnswerSet}
          title='Test Answers'
          multipleCorrectAnswers={false}
          numberOfDisplayedAnswers={2}
        />
      )

      // Should be back to 2 empty answer fields
      cy.get('input[type="text"]').should('have.length', 2)
      cy.get('input[type="text"]').first().should('have.value', '')
    })
  })
})
