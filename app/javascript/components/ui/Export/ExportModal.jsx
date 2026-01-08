import React from 'react'
import { Modal, Button, Tabs, Tab } from 'react-bootstrap'
import './Export.css'
import { usePage } from '@inertiajs/inertia-react'
import ExportButton from './ExportButton'

export const ExportModal = ({ show, onHide, hasBookmarks, lms = {} }) => {
  // a fallback object for lms data to avoid errors
  const defaultLms = {
    canvas: [],
    blackboard: [],
    d2l: [],
    moodle: []
  }

  // merge the defaultLms with the lms data that arrives in the page props
  const lmsData = { ...defaultLms, ...lms }

  const canvas = lmsData.canvas.map((type) =>
    type === 'Categorization' ? 'Categorization (New only)' : type
  )

  return (
    <Modal show={show} onHide={onHide} size='lg' centered>
      <Modal.Header closeButton>
        <Modal.Title>Export Bookmarked Questions</Modal.Title>
      </Modal.Header>
      <Modal.Body>
        <Tabs defaultActiveKey='lms' className='mb-3'>
          <Tab eventKey='lms' title='Learning Management Systems'>
            <div className='d-flex justify-content-between flex-wrap'>
              <ExportButton
                format='canvas'
                label='Canvas (New & Classic)'
                questionTypes={canvas}
                hasBookmarks={hasBookmarks}
              />
              <ExportButton
                format='blackboard'
                label='Blackboard'
                questionTypes={lmsData.blackboard}
                hasBookmarks={hasBookmarks}
              />
              <ExportButton
                format='d2l'
                label='Brightspace (D2L)'
                questionTypes={lmsData.d2l}
                hasBookmarks={hasBookmarks}
              />
              <ExportButton
                format='moodle'
                label='Moodle'
                questionTypes={lmsData.moodle}
                hasBookmarks={hasBookmarks}
              />
            </div>
          </Tab>
          <Tab eventKey='text' title='Text Formats'>
            <div className='d-flex justify-content-center'>
              <ExportButton
                format='md'
                label='Markdown'
                questionTypes={[]}
                hasBookmarks={hasBookmarks}
              />
              <ExportButton
                format='txt'
                label='Plain Text'
                questionTypes={[]}
                hasBookmarks={hasBookmarks}
              />
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

// wrapper component that handles Inertia hook
const ExportModalWithInertia = (props) => {
  const { props: pageProps } = usePage()
  return <ExportModal {...props} lms={pageProps?.lms} />
}

export default ExportModalWithInertia
