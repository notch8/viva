import React from 'react'
import Subject from './Subject'

describe('<Subject />', () => {
  beforeEach(() => {
    // Create a stub for functions passed as props
    const handleAddSubject = cy.stub().as('handleAddSubject')

    // Mount the component with initial props
    cy.mount(
      <Subject
        subjectOptions={['Mathematics', 'Physics', 'Chemistry', 'Biology']}
        handleAddSubject={handleAddSubject}
      />
    )
  })

  it('renders correctly with the expected title', () => {
    cy.get('h6').should('contain', 'Subjects')
  })

  it('displays the typeahead input with placeholder text', () => {
    // Check that the typeahead input is rendered with the correct placeholder
    cy.get('.rbt-input-main').should('have.attr', 'placeholder', 'Select subjects')
  })

  it('shows options when typing in the typeahead', () => {
    // Type in the input to trigger the dropdown
    cy.get('.rbt-input-main').type('Math')

    // Check that the dropdown shows the matching option
    cy.get('.rbt-menu').should('be.visible')
    cy.get('.dropdown-item').contains('Mathematics').should('be.visible')
  })

  it('selects an option when clicked', () => {
    // Type in the input to trigger the dropdown
    cy.get('.rbt-input-main').type('Math')

    // Select the option
    cy.get('.dropdown-item').contains('Mathematics').click()

    // Verify that the option was selected and appears as a token
    cy.get('.rbt-token').contains('Mathematics').should('be.visible')

    // Verify the callback was called with the correct data
    cy.get('@handleAddSubject').should('have.been.calledOnce')

    // Use cy.get('@handleAddSubject').then() to inspect the actual arguments
    cy.get('@handleAddSubject').then((stub) => {

      // Assert that the first argument is an array with one item
      expect(stub.firstCall.args[0]).to.be.an('array').with.lengthOf(1)

      // Assert that the first item in the array is 'Mathematics'
      expect(stub.firstCall.args[0][0]).to.equal('Mathematics')
    })
  })

  it('supports multiple selections', () => {
    // Select first subject
    cy.get('.rbt-input-main').type('Math')
    cy.get('.dropdown-item').contains('Mathematics').click()

    // Select second subject
    cy.get('.rbt-input-main').type('Phys')
    cy.get('.dropdown-item').contains('Physics').click()

    // Verify both subjects are selected
    cy.get('.rbt-token').should('have.length', 2)
    cy.get('.rbt-token').contains('Mathematics').should('be.visible')
    cy.get('.rbt-token').contains('Physics').should('be.visible')

    // Verify the callback was called with the correct data
    cy.get('@handleAddSubject').should('have.been.called')

    // Use cy.get('@handleAddSubject').then() to inspect the actual arguments from the last call
    cy.get('@handleAddSubject').then((stub) => {
      // Get the last call's arguments (after adding both subjects)
      const lastCallArgs = stub.lastCall.args[0]

      // Assert that the argument is an array with two items
      expect(lastCallArgs).to.be.an('array').with.lengthOf(2)

      // Assert that the array contains 'Mathematics' and 'Physics'
      expect(lastCallArgs).to.include('Mathematics')
      expect(lastCallArgs).to.include('Physics')
    })
  })

  it('removes a selected option when the token is removed', () => {
    // Select a subject
    cy.get('.rbt-input-main').type('Math')
    cy.get('.dropdown-item').contains('Mathematics').click()

    // Verify the subject is selected
    cy.get('.rbt-token').contains('Mathematics').should('be.visible')

    // Remove the selected subject by clicking the X button
    cy.get('.rbt-token .rbt-token-remove-button').click()

    // Verify the subject was removed
    cy.get('.rbt-token').should('not.exist')

    // Verify the callback was called with an empty array
    cy.get('@handleAddSubject').then((stub) => {
      // Get the last call's arguments (after removing the subject)
      const lastCallArgs = stub.lastCall.args[0]

      // Assert that the argument is an empty array
      expect(lastCallArgs).to.be.an('array').that.is.empty
    })
  })
})
