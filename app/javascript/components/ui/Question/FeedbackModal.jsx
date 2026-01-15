import React, { useState } from 'react'
import { Form, Modal, Alert } from 'react-bootstrap'

const FeedbackModal = ({ show, onClose, question }) => {
  const [feedbackText, setFeedbackText] = useState('')
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')
  const [isSubmitting, setIsSubmitting] = useState(false)

  const handleSubmit = async (e) => {
    e.preventDefault()

    // Validate that feedback text is provided
    if (!feedbackText.trim()) {
      setError('Please describe the issue before submitting.')
      return
    }

    setIsSubmitting(true)
    setError('')
    setSuccess('')

    try {
      const response = await fetch('/api/feedbacks', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          feedback: {
            content: feedbackText,
            question_id: question.id
          }
        })
      })

      const data = await response.json()

      if (!response.ok) {
        // Handle validation errors from Rails
        const errorMessage = data.errors ? data.errors.join(', ') : 'Something went wrong. Please try again.'
        setError(errorMessage)
        return
      }

      // Show success message
      setSuccess(data.message || 'Thank you for the feedback!')
      setFeedbackText('')

      // Close modal after a short delay to show success message
      setTimeout(() => {
        onClose()
        setSuccess('')
      }, 1500)
    } catch (err) {
      setError('Something went wrong. Please try again.')
    } finally {
      setIsSubmitting(false)
    }
  }

  const handleClose = () => {
    setFeedbackText('')
    setError('')
    setSuccess('')
    onClose()
  }

  return (
    <Modal show={show} onHide={handleClose} size='lg'>
      <Modal.Header closeButton>
        <Modal.Title>Provide Feedback for Question ID: {question.hashid}</Modal.Title>
      </Modal.Header>
      <Form onSubmit={handleSubmit}>
        <Modal.Body>
          {error && <Alert variant='danger'>{error}</Alert>}
          {success && <Alert variant='success'>{success}</Alert>}
          <Form.Group controlId='feedbackText' className='pr-4'>
            <Form.Label className='h6 fw-bold'>Describe the issue with this question:</Form.Label>
            <p className=''>*Required Field</p>
            <Form.Control
              as='textarea'
              rows={5}
              className='mr-4 p-2 mb-4'
              value={feedbackText}
              onChange={(e) => setFeedbackText(e.target.value)}
              required
              disabled={isSubmitting}
            />
          </Form.Group>
        </Modal.Body>
        <Modal.Footer>
          <button
            type='button'
            className='btn btn-light'
            onClick={handleClose}
            disabled={isSubmitting}
          >
            Cancel
          </button>
          <button
            type='submit'
            className='btn btn-secondary'
            disabled={isSubmitting}
          >
            {isSubmitting ? 'Submitting...' : 'Submit'}
          </button>
        </Modal.Footer>
      </Form>
    </Modal>
  )
}

export default FeedbackModal
