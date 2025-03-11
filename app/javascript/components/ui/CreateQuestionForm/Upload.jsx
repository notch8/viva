import React from 'react'
import { Form } from 'react-bootstrap'

const Upload = ({ questionText, handleTextChange }) => {
  return (
    <Form.Group className='mb-3'>
      <Form.Label>Question Text</Form.Label>
      <Form.Control
        as='textarea'
        rows={3}
        value={questionText}
        onChange={handleTextChange}
        placeholder='Enter your question text here...'
      />
    </Form.Group>
  )
}

export default Upload
