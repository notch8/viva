import React from 'react'
import QuestionTypeDropdown from './QuestionTypeDropdown'

describe('QuestionTypeDropdown Component', () => {
  const mockQuestionTypes = [
    { key: 'essay', value: 'Essay' },
    { key: 'multiple_choice', value: 'Multiple Choice' },
    { key: 'true_false', value: 'True/False' }
  ]

  beforeEach(() => {
    // Create a stub for functions passed as props
    const handleQuestionTypeSelection = cy.stub().as('handleQuestionTypeSelection')

    // Mount the component with initial props
    cy.mount(
      <QuestionTypeDropdown
        handleQuestionTypeSelection={handleQuestionTypeSelection}
        QUESTION_TYPE_NAMES={mockQuestionTypes}
      />
    )
  })

  it('renders the dropdown with the default text', () => {
    cy.get('.dropdown-toggle').should('contain', 'Select Question Type')
  })

  it('renders the form label correctly', () => {
    cy.get('label').should('contain', 'Select Question Type')
  })

  it('displays all question type options when clicked', () => {
    cy.get('.dropdown-toggle').click()

    mockQuestionTypes.forEach(type => {
      cy.get('.dropdown-menu').should('contain', type.value)
    })
  })

  it('selects a question type when clicked', () => {
    const selectedType = mockQuestionTypes[1].value // 'Multiple Choice'

    cy.get('.dropdown-toggle').click()
    cy.get('.dropdown-item').contains(selectedType).click()

    // Check that the dropdown button now shows the selected type
    cy.get('.dropdown-toggle').should('contain', selectedType)

    // Check that the selection handler was called with the correct value
    cy.get('@handleQuestionTypeSelection').should('have.been.calledWith', selectedType)
  })
})
