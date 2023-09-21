import React from 'react'
import { Nav, Button } from 'react-bootstrap'
import { Link, usePage } from '@inertiajs/inertia-react'
import {
  MagnifyingGlass, Gear, SignOut, Upload, CaretLeft
} from '@phosphor-icons/react'

const Sidebar = ({ open, setOpen }) => {
  const { url } = usePage()
  return (
    <Nav className='d-flex flex-column text-nowrap' activeKey='/'>
      <Nav.Item>
        <div className='bg-light-1'>
          <Button
            onClick={() => setOpen(!open)}
            aria-controls='sidebar'
            aria-expanded={open}
            className='ms-auto my-2 me-2 rounded-circle btn btn-secondary d-flex px-1 py-1'
            variant='secondary'
          >
            <CaretLeft weight='bold' alt='Open Sidebar'/>
          </Button>
        </div>
      </Nav.Item>
      <Nav.Item className='mt-1 bg-light-2'>
        <Link href='/' className={`${url === '/' ? 'active' : ''} nav-link d-flex align-items-center link-dark`}>
          <MagnifyingGlass weight='bold' alt='Search All Questions' size={18} className='me-2'/>
          Search All Questions
        </Link>
      </Nav.Item>
      <Nav.Item className='mt-1 bg-light-2'>
        <Link href='/uploads' className={`${url === '/uploads' ? 'active' : ''} nav-link d-flex align-items-center link-dark`}>
          <Upload weight='bold' alt='Upload Questions' size={18} className='me-2'/>
          Upload Questions
        </Link>
      </Nav.Item>
      <Nav.Item className='mt-1 bg-light-2'>
        <Link href='/settings' className={`${url === '/settings' ? 'active' : ''} nav-link d-flex align-items-center link-dark`} preserveState>
          <Gear weight='bold' alt='Settings' size={18} className='me-2'/>
          Settings
        </Link>
      </Nav.Item>
      <Nav.Item className='mt-1 bg-light-2'>
        <Nav.Link href='/logout' className={`${url === '/logout' ? 'active' : ''} nav-link d-flex align-items-center link-dark`}>
          <SignOut weight='bold' alt='Sign Out' size={18} className='me-2'/>
          Sign Out
        </Nav.Link>
      </Nav.Item>
    </Nav>
  )
}

export default Sidebar