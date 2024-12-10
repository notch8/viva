import React, { useState } from 'react'
import { Dropdown, Form, Button } from 'react-bootstrap'
import CustomDropdown from '../../../ui/CustomDropdown'
import { QUESTION_TYPE_NAMES } from '../../../../constants/questionTypes'

const CreateQuestion = ({ selectedType, onTypeSelect }) => {
  const [questionText, setQuestionText] = useState('')

  const handleTextChange = (e) => {
    setQuestionText(e.target.value)
  }

  const formatTextToParagraph = (text) => {
    return text.split('\n').map((line, index) => `<p key=${index}>${line}</p>`).join('')
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    const formattedText = formatTextToParagraph(questionText)

    try {
      const response = await fetch('/api/questions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          question: {
            type: 'Question::Essay',
            text: questionText,
            data: { html: formattedText },
          },
        }),
      })

      if (response.ok) {
        alert('Question saved successfully!')
        setQuestionText('')
      } else {
        const errorData = await response.json()
        alert(`Failed to save the question: ${errorData.errors.join(', ')}`)
      }
    } catch (error) {
      console.error('Error saving the question:', error)
      alert('An error occurred while saving the question.')
    }
  }

  return (
    <div>
      <h2 className='h5 fw-bold mt-5'>Create a Question</h2>
      <Form onSubmit={handleSubmit}>
        <Form.Group controlId='questionType'>
          <Form.Label>Select Question Type</Form.Label>
          <CustomDropdown dropdownSelector='.question-type-dropdown'>
            <Dropdown onSelect={onTypeSelect} className='question-type-dropdown'>
              <Dropdown.Toggle variant='secondary'>{selectedType}</Dropdown.Toggle>
              <Dropdown.Menu>
                {QUESTION_TYPE_NAMES.map(({ key, value }) => (
                  <Dropdown.Item key={key} eventKey={value}>
                    {value}
                  </Dropdown.Item>
                ))}
              </Dropdown.Menu>
            </Dropdown>
          </CustomDropdown>
        </Form.Group>
        <Form.Group controlId='questionText'>
          <Form.Label>Enter Question Text</Form.Label>
          <Form.Control
            as='textarea'
            rows={5}
            value={questionText}
            onChange={handleTextChange}
            placeholder='Enter your question text here...'
          />
        </Form.Group>
        <Button variant='primary' type='submit'>
          Submit
        </Button>
      </Form>
      <div>
        <h3>Formatted Text</h3>
        <div dangerouslySetInnerHTML={{ __html: formatTextToParagraph(questionText) }} />
      </div>
    </div>
  )
}

export default CreateQuestion
