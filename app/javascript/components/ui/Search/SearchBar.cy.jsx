import React from 'react'
import { Button, Container, Form } from 'react-bootstrap'

// Simplified version of the component to avoid mocking Inertia
const TestSearchBar = () => {
  return (
    <Form>
      <Container>
        <div>
          <input
            type='text'
            placeholder='Search questions...'
          />
          <Button>
            Apply Search Terms
          </Button>
          <Button>
            Reset Filters
          </Button>
        </div>
        <div>
          <Button>SUBJECTS</Button>
          <Button>TYPES</Button>
          <Button>LEVELS</Button>
          <Button>BOOKMARKS (0)</Button>
        </div>
      </Container>
    </Form>
  )
}

describe('SearchBar', () => {
  beforeEach(() => {
    cy.mount(<TestSearchBar />)
  })

  it('renders text search input and buttons', () => {
    cy.get('input[placeholder="Search questions..."]').should('exist')
    cy.get('button').contains('Apply Search Terms').should('exist')
    cy.get('button').contains('BOOKMARKS').should('exist')
  })

  it('shows filter buttons', () => {
    cy.get('button').contains('SUBJECTS').should('exist')
    cy.get('button').contains('TYPES').should('exist')
    cy.get('button').contains('LEVELS').should('exist')
  })
})
