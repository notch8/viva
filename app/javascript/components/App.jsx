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
        <div className='bg-light-2 vh-100 px-2'>
          <Button
            onClick={() => setOpen(!open)}
            aria-controls='sidebar'
            aria-expanded={open}
            className='mx-auto mt-2 rounded-circle btn btn-secondary d-flex px-1 py-1'
            variant='secondary'
          >
            {open ? <CaretLeft weight='bold' alt='Close Sidebar'/> : <CaretRight weight='bold' alt='Open Sidebar'/>}
          </Button>
        </div>
        <div id='page-content-wrapper' className='container-fluid px-0'>
          {children}
        </div>
      </div>
    </>
  )
}

export default App
