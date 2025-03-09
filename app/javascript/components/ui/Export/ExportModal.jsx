import React from 'react'
import {
  Modal, Button, Tabs, Tab
} from 'react-bootstrap'
import './Export.css'
import { usePage } from '@inertiajs/inertia-react'
import ExportButton from './ExportButton'

const ExportModal = ({ show, onHide, hasBookmarks }) => {
  const lms = usePage().props.lms

  return (
    <Modal show={show} onHide={onHide} size='lg' centered>
      <Modal.Header closeButton>
        <Modal.Title>Export Bookmarked Questions</Modal.Title>
      </Modal.Header>
      <Modal.Body>
        <Tabs defaultActiveKey='lms' className='mb-3'>
          <Tab eventKey='lms' title='Learning Management Systems'>
            <div className='d-flex flex-wrap justify-content-center'>
              <div className='row w-100'>
                <ExportButton format='blackboard' label='Blackboard' questionTypes={lms.blackboard} hasBookmarks={hasBookmarks} />
                <ExportButton format='d2l' label='Brightspace' questionTypes={lms.d2l} hasBookmarks={hasBookmarks} />
              </div>
              <div className='row w-100'>
                <ExportButton format='canvas' label='Canvas' questionTypes={lms.canvas} hasBookmarks={hasBookmarks} />
                <ExportButton format='moodle' label='Moodle' questionTypes={lms.moodle} hasBookmarks={hasBookmarks} />
              </div>
            </div>
          </Tab>

          <Tab eventKey='text' title='Text Formats'>
            <div className='d-flex justify-content-center'>
              <div className='row w-100'>
                <ExportButton format='md' label='Markdown' questionTypes={[]} hasBookmarks={hasBookmarks} />
                <ExportButton format='txt' label='Plain Text' questionTypes={[]} hasBookmarks={hasBookmarks} />
              </div>
            </div>
          </Tab>
        </Tabs>
      </Modal.Body>
      <Modal.Footer>
        <Button variant='secondary' onClick={onHide} className='px-4'>
          Close
        </Button>
      </Modal.Footer>
    </Modal>
  )
}

export default ExportModal