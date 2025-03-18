import React from 'react'
import {
  Modal, Button, Tabs, Tab
} from 'react-bootstrap'
import './Export.css'
import { usePage } from '@inertiajs/inertia-react'
import ExportButton from './ExportButton'

const ExportModal = ({ show, onHide, hasBookmarks }) => {
  const lms = usePage().props.lms
  const canvas = lms.canvas.map(type => type === 'Categorization' ? 'Categorization (New only)' : type)

  return (
    <Modal show={show} onHide={onHide} size='lg' centered>
      <Modal.Header closeButton>
        <Modal.Title>Export Bookmarked Questions</Modal.Title>
      </Modal.Header>
      <Modal.Body>
        <Tabs defaultActiveKey='lms' className='mb-3'>
          <Tab eventKey='lms' title='Learning Management Systems'>
            <div className='d-flex justify-content-between flex-wrap'>
              <ExportButton format='canvas' label='Canvas (New & Classic)' questionTypes={canvas} hasBookmarks={hasBookmarks} />
              <ExportButton format='blackboard' label='Blackboard' questionTypes={lms.blackboard} hasBookmarks={hasBookmarks} />
              <ExportButton format='d2l' label='Brightspace (D2L)' questionTypes={lms.d2l} hasBookmarks={hasBookmarks} />
              <ExportButton format='moodle' label='Moodle' questionTypes={lms.moodle} hasBookmarks={hasBookmarks} />
            </div>
          </Tab>
          <Tab eventKey='text' title='Text Formats'>
            <div className='d-flex justify-content-center'>
              <ExportButton format='md' label='Markdown' questionTypes={[]} hasBookmarks={hasBookmarks} />
              <ExportButton format='txt' label='Plain Text' questionTypes={[]} hasBookmarks={hasBookmarks} />
            </div>
          </Tab>
        </Tabs>
      </Modal.Body>
      <Modal.Footer>
        <Button variant='secondary' onClick={onHide}>
          Close
        </Button>
      </Modal.Footer>
    </Modal>
  )
}

export default ExportModal
