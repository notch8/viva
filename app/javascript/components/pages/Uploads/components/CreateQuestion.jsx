import React, { useState } from 'react'
import { Dropdown, Form, Button } from 'react-bootstrap'
import CustomDropdown from '../../../ui/CustomDropdown'
import { QUESTION_TYPE_NAMES } from '../../../../constants/questionTypes'

const CreateQuestion = ({ selectedType, onTypeSelect }) => {
  const [questionText, setQuestionText] = useState('')
  const [selectedFiles, setSelectedFiles] = useState([])

  const handleTextChange = (e) => {
    setQuestionText(e.target.value)
  }

  const handleFileChange = (e) => {
    setSelectedFiles(e.target.files)
  }

  const formatTextToParagraph = (text) => {
    return text.split('\n').map((line, index) => `<p key=${index}>${line}</p>`).join('')
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    const formattedText = formatTextToParagraph(questionText)

    const formData = new FormData()
    formData.append('question[type]', 'Question::Essay')
    formData.append('question[text]', questionText)
    formData.append('question[data][html]', formattedText)
    for (let i = 0; i < selectedFiles.length; i++) {
      formData.append('question[images][]', selectedFiles[i])
    }

    try {
      const response = await fetch('/api/questions', {
        method: 'POST',
        body: formData,
      })

      if (response.ok) {
        alert('Question saved successfully!')
        setQuestionText('')
        setSelectedFiles([])
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
        <Form.Group controlId='questionImages'>
          <Form.Label>Upload Images</Form.Label>
          <Form.Control type='file' multiple onChange={handleFileChange} />
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
