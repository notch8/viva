import React from 'react'
import { Form } from 'react-bootstrap'

const QuestionText = ({ questionText, handleTextChange, formLabel='Enter Question Text', placeHolder='Enter your question text here', inputType='textarea', controlId='questionText' }) => {

  return (
    <Form.Group controlId={controlId} className='pr-4'>
      <Form.Label className='h6 fw-bold'>{formLabel}</Form.Label>
      <p className=''>*Required Field</p>
      <Form.Control
        as={inputType}
        rows={5}
        value={questionText}
        onChange={handleTextChange}
        placeholder={placeHolder}
        className='mr-4 p-2 mb-4'
      />
    </Form.Group>
  )
}

export default QuestionText
