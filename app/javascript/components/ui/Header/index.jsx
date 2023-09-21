import React from 'react'
import { Container, Image, Navbar } from 'react-bootstrap'
import Logo from '../../../../assets/images/logotransparent.png'

const Header = () => {
  return (
    <Container fluid className='bg-light-4 py-1'>
      <Navbar.Brand href='/'>
        <Image src={Logo} height='60'/>
      </Navbar.Brand>
    </Container>
  )
}

export default Header