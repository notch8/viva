import React from 'react'
import { Form, Button } from 'react-bootstrap'

const AnswerField = ({ answers, updateAnswer, removeAnswer, title, buttonType = 'checkbox' }) => {
  return (
    <Form.Group className='my-3'>
      <Form.Label className='h6'>{title}</Form.Label>
      {answers.map((answer, index) => (
        <div key={index} className='d-flex align-items-center my-2'>
          <Form.Control
            type='text'
            value={answer.answer}
            onChange={(e) => updateAnswer(index, 'answer', e.target.value)}
            placeholder={`Answer ${index + 1}`}
            className='me-2'
          />
          <Form.Check
            type={buttonType}
            checked={answer.correct}
            onChange={(e) => {
              if (buttonType === 'radio') {
                // Toggle behavior for radio buttons
                updateAnswer(index, 'correct', !answer.correct)
              } else {
                // Standard checkbox behavior
                updateAnswer(index, 'correct', e.target.checked)
              }
            }}
            label='Correct'
          />
          {buttonType === 'radio' && answer.correct && (
            <Button
              variant='link'
              size='sm'
              className='text-danger ms-2 p-0'
              onClick={() => updateAnswer(index, 'correct', false)}
            >
              Unset
            </Button>
          )}
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
