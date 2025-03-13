import React from 'react'
import AnswerField from './AnswerField'

describe('AnswerField Component', () => {
  describe('with radio buttons (default)', () => {
    beforeEach(() => {
      // Create stubs for the callback functions
      const updateAnswer = cy.stub().as('updateAnswer')
      const removeAnswer = cy.stub().as('removeAnswer')

      // Sample answers data
      const answers = [
        { answer: 'Paris', correct: false },
        { answer: 'London', correct: true },
        { answer: 'Berlin', correct: false }
      ]

      // Mount the component with required props
      cy.mount(
        <AnswerField
          answers={answers}
          updateAnswer={updateAnswer}
          removeAnswer={removeAnswer}
          title='Test Answers'
        />
      )
    })

    it('renders the title correctly', () => {
      cy.get('.h6').should('contain', 'Test Answers')
    })

    it('renders all answer fields with correct values', () => {
      cy.get('input[type="text"]').should('have.length', 3)
      cy.get('input[type="text"]').eq(0).should('have.value', 'Paris')
      cy.get('input[type="text"]').eq(1).should('have.value', 'London')
      cy.get('input[type="text"]').eq(2).should('have.value', 'Berlin')
    })

    it('renders radio buttons for correct answers', () => {
      cy.get('.form-check').should('have.length', 3)
      cy.get('input[type="radio"]').should('have.length', 3)

      // Check that the second radio button is checked (London is correct)
      cy.get('input[type="radio"]').eq(1).should('be.checked')
    })

    it.skip('calls updateAnswer when typing in an answer field', () => {
      const newText = ' is the capital of France'

      // Type in the first answer field and wait for the onChange event to trigger
      cy.get('input[type="text"]').first().type(newText, { delay: 100 })

      // Wait for the callback to be called
      cy.wait(100)

      // Verify the callback was called
      cy.get('@updateAnswer').should('have.been.called')
    })

    it.skip('calls updateAnswer when clicking a radio button', () => {
      // Click the first radio button (Paris)
      cy.get('.form-check-label').first().click({ force: true })

      // Wait for the callback to be called
      cy.wait(100)

      // Verify the callback was called
      cy.get('@updateAnswer').should('have.been.called')
    })

    it('calls removeAnswer when clicking a remove button', () => {
      // Click the remove button for the first answer
      cy.get('button').contains('Remove').first().click()
      cy.get('@removeAnswer').should('have.been.calledWith', 0)
    })

    it('disables remove buttons when only one answer remains', () => {
      // Mount with only one answer
      const updateAnswer = cy.stub().as('updateAnswerSingle')
      const removeAnswer = cy.stub().as('removeAnswerSingle')
      const singleAnswer = [{ answer: 'Paris', correct: true }]

      cy.mount(
        <AnswerField
          answers={singleAnswer}
          updateAnswer={updateAnswer}
          removeAnswer={removeAnswer}
          title='Test Answers'
        />
      )

      // The remove button should be disabled
      cy.get('button').contains('Remove').should('be.disabled')
    })
  })

  describe('with checkbox buttons', () => {
    beforeEach(() => {
      // Create stubs for the callback functions
      const updateAnswer = cy.stub().as('updateAnswer')
      const removeAnswer = cy.stub().as('removeAnswer')

      // Sample answers data for multiple correct answers
      const answers = [
        { answer: 'Paris', correct: true },
        { answer: 'London', correct: true },
        { answer: 'Berlin', correct: false }
      ]

      // Mount the component with checkbox buttonType
      cy.mount(
        <AnswerField
          answers={answers}
          updateAnswer={updateAnswer}
          removeAnswer={removeAnswer}
          title='Multiple Correct Answers'
          buttonType='checkbox'
        />
      )
    })

    it('renders checkbox buttons instead of radio buttons', () => {
      cy.get('input[type="checkbox"]').should('have.length', 3)

      // Check that the first two checkboxes are checked
      cy.get('input[type="checkbox"]').eq(0).should('be.checked')
      cy.get('input[type="checkbox"]').eq(1).should('be.checked')
      cy.get('input[type="checkbox"]').eq(2).should('not.be.checked')
    })
  })
})
