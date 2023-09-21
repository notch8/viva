import React, { useState } from 'react'
import { Collapse, Button } from 'react-bootstrap'
import { CaretRight } from '@phosphor-icons/react'
import Footer from './ui/Footer'
import Header from './ui/Header'
import Sidebar from './ui/Sidebar'

// NOTE: App should be imported as a layout to all other pages to maintain the sidebar and header
const App = ({ children }) => {
  const [open, setOpen] = useState(false)

  return (
    <>
      <Header />
      <div className='d-flex h-100 overflow-auto'>
        <Collapse in={open} dimension='width'>
          <div id='sidebar' className='bg-light-1'>
            <Sidebar open={open} setOpen={setOpen}/>
          </div>
        </Collapse>
        {!open &&
          <div className='bg-light-1'>
            <Button
              onClick={() => setOpen(!open)}
              aria-controls='sidebar'
              aria-expanded={open}
              className='mx-2 mt-2 rounded-circle btn btn-secondary d-flex px-1 py-1'
              variant='secondary'
            >
              <CaretRight weight='bold' alt='Open Sidebar'/>
            </Button>
          </div>
        }
        <div id='page-content-wrapper' className='container-fluid py-2 overflow-auto'>
          {children}
        </div>
      </div>
      <Footer />
    </>
  )
}

export default App
