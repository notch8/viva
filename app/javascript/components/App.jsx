import React, { useState } from 'react'
import { Collapse, Button } from 'react-bootstrap'
import { CaretLeft, CaretRight } from "@phosphor-icons/react";
import Header from './ui/Header'
import Sidebar from './ui/Sidebar'

// NOTE: App should be imported as a layout to all other pages to maintain the sidebar and header
const App = ({ children }) => {
  const [open, setOpen] = useState(false)

  return (
    <>
      <Header />
      <div className='d-flex'>
        <Collapse in={open} dimension='width'>
          <div id='sidebar'>
            <Sidebar />
          </div>
        </Collapse>
        <div className='hidden-sidebar bg-light vh-100'/>
        <div id='page-content-wrapper' className='container-fluid px-0'>
          <Button
            onClick={() => setOpen(!open)}
            aria-controls='sidebar'
            aria-expanded={open}
            className='ms-n3 mt-n1 rounded-circle btn btn-secondary d-flex px-1 py-1'
            variant='secondary'
          >
            {open ? <CaretLeft weight='bold' alt='Close Sidebar'/> : <CaretRight weight='bold' alt='Open Sidebar'/>}
          </Button>
          {children}
        </div>
      </div>
    </>
  )
}

export default App
