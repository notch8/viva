import React from 'react'
import { Nav } from 'react-bootstrap'
import { Link } from '@inertiajs/inertia-react'
import { MagnifyingGlass, Gear, SignOut, Upload } from "@phosphor-icons/react";

const Sidebar = () => {

  return (
    <Nav className="d-flex flex-column bg-light-2 vh-100 text-nowrap" activeKey="/">
      <Nav.Item>
        <Link href="/" className='nav-link d-flex align-items-center link-dark'>
          <MagnifyingGlass weight='bold' alt='Search All Questions' size={18} className='me-2'/>
          Search All Questions
        </Link>
      </Nav.Item>
      <Nav.Item>
        <Link href="/uploads" className='nav-link d-flex align-items-center link-dark'>
          <Upload weight='bold' alt='Upload Questions' size={18} className='me-2'/>
          Upload Questions
        </Link>
      </Nav.Item>
      <Nav.Item>
        <Link href="/settings" className='nav-link d-flex align-items-center link-dark' preserveState>
          <Gear weight='bold' alt='Settings' size={18} className='me-2'/>
          Settings
        </Link>
      </Nav.Item>
      <Nav.Item>
        <Nav.Link href="/logout" className='nav-link d-flex align-items-center link-dark'>
          <SignOut weight='bold' alt='Sign Out' size={18} className='me-2'/>
          Sign Out
        </Nav.Link>
      </Nav.Item>
    </Nav>
  )
}

export default Sidebar