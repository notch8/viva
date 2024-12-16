import React from 'react'
import { Form, Button } from 'react-bootstrap'

const AnswerField = ({ answers, updateAnswer, removeAnswer }) => {

  return (
    <Form.Group className='mb-3'>
      <Form.Label className='h6'>Answers</Form.Label>
      {answers.map((answer, index) => (
        <div key={index} className='d-flex align-items-center mb-2'>
          <Form.Control
            type='text'
            value={answer.answer}
            onChange={(e) => updateAnswer(index, 'answer', e.target.value)}
            placeholder={`Answer ${index + 1}`}
            className='me-2'
          />
          <Form.Check
            type='checkbox'
            checked={answer.correct}
            onChange={(e) => updateAnswer(index, 'correct', e.target.checked)}
            label='Correct'
          />
          <Button
            variant='danger'
            size='sm'
            className='ms-2'
            onClick={() => removeAnswer(index)}
            disabled={answers.length === 1}
          >
            Remove
          </Button>
        </div>
      ))}
    </Form.Group>
  )
}

export default AnswerField
