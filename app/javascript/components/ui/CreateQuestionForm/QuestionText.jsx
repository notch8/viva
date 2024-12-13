import React from 'react'
import { Form } from 'react-bootstrap'

const QuestionText = ({ questionText, handleTextChange }) => {

  return (
    <Form.Group controlId='questionText' className='pr-4'>
      <Form.Label className='h6 fw-bold'>Enter Question Text</Form.Label>
      <p className=''>*Required Field</p>
      <Form.Control
        as='textarea'
        rows={5}
        value={questionText}
        onChange={handleTextChange}
        placeholder='Enter your question text here'
        className='mr-4 p-2'
      />
    </Form.Group>
  )
}

export default QuestionText
