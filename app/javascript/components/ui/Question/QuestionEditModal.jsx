import React from 'react'
import { Modal } from 'react-bootstrap'
import { Inertia } from '@inertiajs/inertia'
import CreateQuestionForm from '../CreateQuestionForm'

const QuestionEditModal = ({ show, onClose, question, subjects }) => {
  const handleSuccess = () => {
    onClose()
    // Reload the page to show the updated question
    Inertia.reload()
  }

  return (
    <Modal show={show} onHide={onClose} size='xl'>
      <Modal.Header closeButton>
        <Modal.Title>Edit Question</Modal.Title>
      </Modal.Header>
      <Modal.Body>
        <CreateQuestionForm
          question={question}
          subjectOptions={subjects || []}
          onSuccess={handleSuccess}
          onCancel={onClose}
        />
      </Modal.Body>
    </Modal>
  )
}

export default QuestionEditModal
