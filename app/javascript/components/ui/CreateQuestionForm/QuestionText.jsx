import React from 'react'
import { Form, Button } from 'react-bootstrap'

const QuestionText = ({ handleSubmit, questionText, handleTextChange }) => {

  return (
    <Form onSubmit={handleSubmit}>
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
      <Button variant='primary' type='submit' className='mt-4'>
        Submit
      </Button>
    </Form>
  )
}

export default QuestionText
