import React from 'react'
import { Modal } from 'react-bootstrap'
import CreateQuestionForm from '../CreateQuestionForm'

const QuestionEditModal = ({ show, onClose, question }) => {
  // Baby step handlers - just log for now
  const handleTextChange = (e) => {
    console.log('Text changed:', e.target.value)
  }

  const handleDataChange = (value) => {
    console.log('Data changed:', value)
  }

  return (
    <Modal show={show} onHide={onClose} size="xl">
      <Modal.Header closeButton>
        <Modal.Title>Edit Question</Modal.Title>
      </Modal.Header>
      <Modal.Body>
        <CreateQuestionForm
          question={question}
          handleTextChange={handleTextChange}
          onDataChange={handleDataChange}
        />
      </Modal.Body>
      <Modal.Footer>
        <button
          className="btn btn-secondary"
          onClick={onClose}
        >
          Close
        </button>
      </Modal.Footer>
    </Modal>
  )
}

export default QuestionEditModal
