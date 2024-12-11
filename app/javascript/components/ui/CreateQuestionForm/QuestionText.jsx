import React from 'react'
import { Form } from 'react-bootstrap'

const QuestionText = ({ questionText, handleTextChange }) => {

  return (
    <Form.Group controlId='questionText'>
      <Form.Label>Enter Question Text</Form.Label>
      <Form.Control
        as='textarea'
        rows={5}
        value={questionText}
        onChange={handleTextChange}
        placeholder='Enter your question text here'
        className='p-2'
      />
    </Form.Group>
  )
}

export default QuestionText
