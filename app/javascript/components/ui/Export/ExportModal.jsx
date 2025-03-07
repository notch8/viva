import React from 'react'
import {
  Modal, Button, Tabs, Tab, OverlayTrigger, Tooltip
} from 'react-bootstrap'
import './Export.css'

const ExportModal = ({ show, onHide, hasBookmarks }) => {
  // Define supported question types for each export format
  const supportedTypes = {
    canvas: {
      "Multiple Choice": true,
      "True/False": true,
      "Fill in the Blank": true,
      "Essay": true,
      "Short Answer": true
    },
    blackboard: {
      "Multiple Choice": true,
      "True/False": true,
      "Short Answer": true,
      "Essay": true
    },
    brightspace: {
      "Multiple Choice": true,
      "True/False": true,
      "Short Answer": true,
      "Essay": true
    },
    moodle: {
      "Multiple Choice": true,
      "True/False": true,
      "Short Answer": true,
      "Essay": true
    },
    txt: {
      "All question types": true
    },
    md: {
      "All question types": true
    }
  }

  // Helper function to generate tooltip text
  const getTooltipText = (format) => {
    const types = supportedTypes[format];
    if (types["All question types"]) {
      return "Supports all question types in plain text format";
    }
    
    const supportedList = Object.keys(types)
      .filter(type => types[type])
      .join(", ");
    
    return `Supports: ${supportedList}`;
  }

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
                <div className='col-md-6 d-flex justify-content-center'>
                  <OverlayTrigger
                    placement="top"
                    overlay={<Tooltip>{getTooltipText('canvas')}</Tooltip>}
                  >
                    <Button
                      variant='outline-primary'
                      className='export-button'
                      href='/bookmarks/export?format=canvas'
                      disabled={!hasBookmarks}
                    >
                      <i className='bi bi-grid-3x3-gap-fill fs-1 mb-3'></i>
                      <span className="text-uppercase">Canvas</span>
                    </Button>
                  </OverlayTrigger>
                </div>
                <div className='col-md-6 d-flex justify-content-center'>
                  <OverlayTrigger
                    placement="top"
                    overlay={<Tooltip>{getTooltipText('blackboard')}</Tooltip>}
                  >
                    <Button
                      variant='outline-primary'
                      className='export-button'
                      href='/bookmarks/export?format=blackboard'
                      disabled={!hasBookmarks}
                    >
                      <i className='bi bi-clipboard2-fill fs-1 mb-3'></i>
                      <span className="text-uppercase">Blackboard</span>
                    </Button>
                  </OverlayTrigger>
                </div>
              </div>
              <div className='row w-100'>
                <div className='col-md-6 d-flex justify-content-center'>
                  <OverlayTrigger
                    placement="top"
                    overlay={<Tooltip>{getTooltipText('brightspace')}</Tooltip>}
                  >
                    <Button
                      variant='outline-primary'
                      className='export-button'
                      href='/bookmarks/export?format=brightspace'
                      disabled={!hasBookmarks}
                    >
                      <i className='bi bi-brightness-high-fill fs-1 mb-3'></i>
                      <span className="text-uppercase">BrightSpace (D2L)</span>
                    </Button>
                  </OverlayTrigger>
                </div>
                <div className='col-md-6 d-flex justify-content-center'>
                  <OverlayTrigger
                    placement="top"
                    overlay={<Tooltip>{getTooltipText('moodle')}</Tooltip>}
                  >
                    <Button
                      variant='outline-primary'
                      className='export-button'
                      href='/bookmarks/export?format=moodle'
                      disabled={!hasBookmarks}
                    >
                      <i className='bi bi-mortarboard-fill fs-1 mb-3'></i>
                      <span className="text-uppercase">Moodle</span>
                    </Button>
                  </OverlayTrigger>
                </div>
              </div>
            </div>
          </Tab>

          <Tab eventKey='text' title='Text Formats'>
            <div className='d-flex justify-content-center'>
              <div className='row w-100'>
                <div className='col-md-6 d-flex justify-content-center'>
                  <OverlayTrigger
                    placement="top"
                    overlay={<Tooltip>{getTooltipText('txt')}</Tooltip>}
                  >
                    <Button
                      variant='outline-primary'
                      className='export-button'
                      href='/bookmarks/export?format=txt'
                      disabled={!hasBookmarks}
                    >
                      <i className='bi bi-file-text fs-1 mb-3'></i>
                      <span className="text-uppercase">Plain Text</span>
                    </Button>
                  </OverlayTrigger>
                </div>
                <div className='col-md-6 d-flex justify-content-center'>
                  <OverlayTrigger
                    placement="top"
                    overlay={<Tooltip>{getTooltipText('md')}</Tooltip>}
                  >
                    <Button
                      variant='outline-primary'
                      className='export-button'
                      href='/bookmarks/export?format=md'
                      disabled={!hasBookmarks}
                    >
                      <i className='bi bi-markdown fs-1 mb-3'></i>
                      <span className="text-uppercase">Markdown</span>
                    </Button>
                  </OverlayTrigger>
                </div>
              </div>
            </div>
          </Tab>
        </Tabs>
      </Modal.Body>
      <Modal.Footer>
        <Button variant='secondary' onClick={onHide} className="px-4">
          Close
        </Button>
      </Modal.Footer>
    </Modal>
  )
}

export default ExportModal