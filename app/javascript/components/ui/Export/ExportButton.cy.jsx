import React from 'react'
import ExportButton from './ExportButton'

describe('<ExportButton />', () => {
  it('renders', () => {
    cy.mount(<ExportButton format='blackboard' label='Blackboard' questionTypes={[]} hasBookmarks={false} />)
  })

  it('displays "All Question Types Supported" for text formats', () => {
    // Test with markdown format
    cy.mount(<ExportButton format='md' label='Markdown' questionTypes={[]} hasBookmarks={false} />)
    cy.get('.supported-types').should('contain', 'All Question Types Supported')

    // Test with txt format
    cy.mount(<ExportButton format='txt' label='Text' questionTypes={[]} hasBookmarks={false} />)
    cy.get('.supported-types').should('contain', 'All Question Types Supported')
  })

  it('displays supported question types for non-text formats', () => {
    const questionTypes = ['Multiple Choice', 'Short Answer']
    cy.mount(<ExportButton format='blackboard' label='Blackboard' questionTypes={questionTypes} hasBookmarks={false} />)

    // Check that each question type is displayed
    questionTypes.forEach(type => {
      cy.get('.supported-types').should('contain', type)
    })
  })
})
