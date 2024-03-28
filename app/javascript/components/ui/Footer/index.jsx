import React from 'react'
import { Container, Nav, Navbar } from 'react-bootstrap'

const Footer = () => {
  return (
    <Navbar expand='lg' className='bg-light-2 py-1 mt-auto'>
      <Container fluid>
        <Nav className='me-auto'>
          <Nav.Link href='/'>Home</Nav.Link>
          <Nav.Link href='/uploads'>Upload Questions</Nav.Link>
          <Nav.Link href='/settings'>Settings</Nav.Link>
        </Nav>
        <Nav className=''>
          © 2023 VIVA
        </Nav>
      </Container>
    </Navbar>
  )
}

export default Footer
