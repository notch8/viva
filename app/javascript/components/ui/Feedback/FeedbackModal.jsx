import React, { useState } from 'react'
import { Modal, Button, Form, Alert } from 'react-bootstrap'

const FeedbackModal = ({ show, onHide, questionId }) => {
  const [content, setContent] = useState('')
  const [submitting, setSubmitting] = useState(false)
  const [showSuccess, setShowSuccess] = useState(false)

  const handleSubmit = async (e) => {
    e.preventDefault()
    if (!content.trim()) {
      return
    }

    setSubmitting(true)

    try {
      const response = await fetch('/api/feedbacks', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '',
          'X-Requested-With': 'XMLHttpRequest'
        },
        credentials: 'same-origin',
        body: JSON.stringify({
          feedback: {
            question_id: questionId,
            content: content.trim()
          }
        })
      })

      const data = await response.json()

      if (response.ok) {
        setContent('')
        setShowSuccess(true)
        // Close modal after 2 seconds to let user see the success message
        setTimeout(() => {
          setShowSuccess(false)
          onHide()
        }, 2000)
      } else {
        const errorMessage = data.errors?.join(', ') || 'Error submitting feedback. Please try again.'
        alert(errorMessage)
      }
    } catch (error) {
      console.error('Error submitting feedback:', error)
      alert('Error submitting feedback. Please try again.')
    } finally {
      setSubmitting(false)
    }
  }

  const handleClose = () => {
    setContent('')
    setShowSuccess(false)
    onHide()
  }

  return (
    <Modal
      show={show}
      onHide={handleClose}
      size='md'
      centered
      backdrop='static'
      className='feedback-modal'
    >
      <Modal.Header closeButton>
        <Modal.Title>Submit Feedback</Modal.Title>
      </Modal.Header>
      <Form onSubmit={handleSubmit}>
        <Modal.Body>
          {showSuccess ? (
            <Alert variant='success' className='mb-3'>
              <Alert.Heading>Thank you for your feedback!</Alert.Heading>
              <p className='mb-0'>Your feedback has been successfully submitted and will be reviewed by administrators.</p>
            </Alert>
          ) : (
            <Form.Group className='mb-3'>
              <Form.Label>Feedback</Form.Label>
              <Form.Control
                as='textarea'
                rows={5}
                value={content}
                onChange={(e) => setContent(e.target.value)}
                placeholder='Please provide your feedback about this question...'
                required
                disabled={submitting}
              />
              <Form.Text className='text-muted'>
                Your feedback will be reviewed by administrators.
              </Form.Text>
            </Form.Group>
          )}
        </Modal.Body>
        <Modal.Footer>
          {showSuccess ? (
            <Button variant='primary' onClick={handleClose}>
              Close
            </Button>
          ) : (
            <>
              <Button variant='secondary' onClick={handleClose} disabled={submitting}>
                Cancel
              </Button>
              <Button variant='primary' type='submit' disabled={submitting || !content.trim()}>
                {submitting ? 'Submitting...' : 'Submit Feedback'}
              </Button>
            </>
          )}
        </Modal.Footer>
      </Form>
    </Modal>
  )
}

export default FeedbackModal

