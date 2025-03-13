import React from 'react'
import Upload from './Upload'

describe('<Upload />', () => {
  beforeEach(() => {
    // Create a stub for functions passed as props
    const handleTextChange = cy.stub().as('handleTextChange')

    // Mount the component with initial props
    cy.mount(
      <Upload
        questionText=''
        handleTextChange={handleTextChange}
      />
    )
  })

  it('renders correctly with the expected label', () => {
    cy.get('label').should('contain', 'Question Text')
  })

  it('displays the textarea with correct placeholder text', () => {
    cy.get('textarea').should('have.attr', 'placeholder', 'Enter your question text here...')
  })

  it('displays the initial question text value', () => {
    // Remount with a non-empty initial value
    const handleTextChange = cy.stub().as('handleTextChange')
    cy.mount(
      <Upload
        questionText='What is the capital of France?'
        handleTextChange={handleTextChange}
      />
    )

    // Check that the textarea displays the initial value
    cy.get('textarea').should('have.value', 'What is the capital of France?')
  })

  it('calls handleTextChange when text is entered', () => {
    // Type text in the textarea
    cy.get('textarea').clear().type('What is the capital of France?')

    // Verify the callback was called
    cy.get('@handleTextChange').should('have.been.called')

    // Inspect the event object passed to the callback
    cy.get('@handleTextChange').then((stub) => {
      // Check that the event object has the expected structure
      expect(stub.firstCall.args[0]).to.have.property('target')
      expect(stub.firstCall.args[0].target).to.have.property('value')
      // Just check that the callback was called with some value
      expect(stub.firstCall.args[0].target.value).to.be.a('string')
    })
  })

  it('updates when new props are received', () => {
    // Remount with new props to simulate an update
    const handleTextChange = cy.stub().as('handleTextChange')
    cy.mount(
      <Upload
        questionText='Updated question text'
        handleTextChange={handleTextChange}
      />
    )

    // Check that the textarea displays the updated value
    cy.get('textarea').should('have.value', 'Updated question text')
  })

  it('has the correct number of rows', () => {
    // Check that the textarea has 3 rows as specified in the component
    cy.get('textarea').should('have.attr', 'rows', '3')
  })
})
