import React from 'react'
import { Modal, Button, Tabs, Tab } from 'react-bootstrap'

const ExportModal = ({ show, onHide, hasBookmarks }) => {
  return (
    <Modal show={show} onHide={onHide} size="lg" centered>
      <Modal.Header closeButton>
        <Modal.Title>Export Bookmarked Questions</Modal.Title>
      </Modal.Header>
      <Modal.Body>
        <Tabs defaultActiveKey="lms" className="mb-3">
          <Tab eventKey="lms" title="Learning Management Systems">
            <div className="d-flex flex-wrap justify-content-between">
              <Button 
                variant="outline-primary" 
                className="m-2 export-button"
                href="/bookmarks/export?format=canvas"
                disabled={!hasBookmarks}
              >
                <div className="d-flex align-items-center">
                  <i className="bi bi-grid-3x3-gap-fill fs-4 me-2"></i>
                  <span>Canvas</span>
                </div>
              </Button>
              
              <Button 
                variant="outline-primary" 
                className="m-2 export-button"
                href="/bookmarks/export?format=blackboard"
                disabled={!hasBookmarks}
              >
                <div className="d-flex align-items-center">
                  <i className="bi bi-clipboard2-fill fs-4 me-2"></i>
                  <span>Blackboard</span>
                </div>
              </Button>
              
              <Button 
                variant="outline-primary" 
                className="m-2 export-button"
                href="/bookmarks/export?format=brightspace"
                disabled={!hasBookmarks}
              >
                <div className="d-flex align-items-center">
                  <i className="bi bi-brightness-high-fill fs-4 me-2"></i>
                  <span>BrightSpace (D2L)</span>
                </div>
              </Button>
              
              <Button 
                variant="outline-primary" 
                className="m-2 export-button"
                href="/bookmarks/export?format=moodle"
                disabled={!hasBookmarks}
              >
                <div className="d-flex align-items-center">
                  <i className="bi bi-mortarboard-fill fs-4 me-2"></i>
                  <span>Moodle</span>
                </div>
              </Button>
            </div>
          </Tab>
          
          <Tab eventKey="text" title="Text Formats">
            <div className="d-flex flex-wrap justify-content-between">
              <Button 
                variant="outline-primary" 
                className="m-2 export-button"
                href="/bookmarks/export?format=txt"
                disabled={!hasBookmarks}
              >
                <div className="d-flex align-items-center">
                  <i className="bi bi-file-text fs-4 me-2"></i>
                  <span>Plain Text</span>
                </div>
              </Button>
              
              <Button 
                variant="outline-primary" 
                className="m-2 export-button"
                href="/bookmarks/export?format=md"
                disabled={!hasBookmarks}
              >
                <div className="d-flex align-items-center">
                  <i className="bi bi-markdown fs-4 me-2"></i>
                  <span>Markdown</span>
                </div>
              </Button>
              
              <Button 
                variant="outline-primary" 
                className="m-2 export-button"
                href="/bookmarks/export?format=xml"
                disabled={!hasBookmarks}
              >
                <div className="d-flex align-items-center">
                  <i className="bi bi-filetype-xml fs-4 me-2"></i>
                  <span>QTI XML</span>
                </div>
              </Button>
            </div>
          </Tab>
        </Tabs>
      </Modal.Body>
      <Modal.Footer>
        <Button variant="secondary" onClick={onHide}>
          Close
        </Button>
      </Modal.Footer>
    </Modal>
  )
}

export default ExportModal