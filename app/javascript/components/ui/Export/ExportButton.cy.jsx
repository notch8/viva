import React from 'react'
import ExportButton from './ExportButton'

describe('<ExportButton />', () => {
  it('renders', () => {
    cy.mount(<ExportButton format='blackboard' label='Blackboard' questionTypes={[]} hasBookmarks={false} />)
  })

  it('displays correct tooltip text for empty questionTypes array', () => {
    cy.mount(<ExportButton format='blackboard' label='Blackboard' questionTypes={[]} hasBookmarks={false} />)
    cy.get('.export-button').trigger('mouseover')
    cy.get('.tooltip-inner').should('contain', 'Supports all question types in plain text format')
  })

  it('displays correct tooltip text for non-empty questionTypes array', () => {
    cy.mount(<ExportButton format='blackboard' label='Blackboard' questionTypes={['Type1', 'Type2']} hasBookmarks={false} />)
    cy.get('.export-button').trigger('mouseover')
    cy.get('.tooltip-inner').should('contain', 'Supports: Type1, Type2')
  })
})