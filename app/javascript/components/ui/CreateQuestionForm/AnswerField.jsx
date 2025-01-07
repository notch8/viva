import React from 'react'
import { Form, Button } from 'react-bootstrap'

const AnswerField = ({ answers, updateAnswer, removeAnswer, title, buttonType = 'radio' }) => {
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
            onClick={() => {
              if (buttonType === 'radio') {
                if (answer.correct) {
                  // Deselect the current radio button
                  updateAnswer(index, 'correct', false)
                } else {
                  // Ensure no other radio button is selected before selecting this one
                  if (!answers.some(a => a.correct)) {
                    updateAnswer(index, 'correct', true)
                  }
                }
              } else if (buttonType === 'checkbox') {
                // Toggle the checkbox state
                updateAnswer(index, 'correct', !answer.correct)
              }
            }}
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
