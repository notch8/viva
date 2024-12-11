import React, { useState } from 'react'
import { Form, Button } from 'react-bootstrap'
import Bowtie from './Bowtie'
import Essay from './Essay'
import QuestionTypeDropdown from './QuestionTypeDropdown'
import LevelDropdown from './LevelDropdown'
import Keyword from './Keyword'

const CreateQuestionForm = () => {
  const [questionText, setQuestionText] = useState('')
  const [questionType, setQuestionType] = useState('')
  const [selectedFiles, setSelectedFiles] = useState([])
  const [isValidFile, setIsValidFile] = useState(true)
  const [level, setLevel] = useState('')

  const COMPONENT_MAP = {
    'Essay': Essay,
    'Bow Tie': Bowtie
  }
  const QuestionComponent = COMPONENT_MAP[questionType] || null

  const handleTextChange = (e) => {
    setQuestionText(e.target.value)
  }

  const handleQuestionTypeSelection = (type) => {
    setQuestionType(type)
  }

  const handleLevelSelection = (level) => { 
    
    setLevel(level)
  }

  const allowedTypes = ['image/jpg', 'image/jpeg', 'image/png']

  const handleFileChange = (e) => {
    const file = e.target.files[0]
    if (file) {
      if (allowedTypes.includes(file.type)) {
        setSelectedFiles([file])
        setIsValidFile(true)
      } else {
        alert('Please select a valid image file (jpg, jpeg, png)')
        setSelectedFiles([])
        setIsValidFile(false)
      }
    } else {
      setSelectedFiles([])
      setIsValidFile(true)
    }
  }

  const formatTextToParagraph = (text) => {
    return text.split('\n').map((line, index) => `<p key=${index}>${line}</p>`).join('')
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    if (!isValidFile) { 
      alert('Please select a valid image file (jpg, jpeg, png)')
      return
    }

    const formattedText = formatTextToParagraph(questionText)

    const formData = new FormData()
    formData.append('question[type]', `Question::${questionType}`)
    formData.append('question[level]', level)
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
    <>
      <h2 className='h5 fw-bold mt-5'>Create a Question</h2>
      <QuestionTypeDropdown handleQuestionTypeSelection={ handleQuestionTypeSelection } />
      { QuestionComponent && (
        <Form onSubmit={handleSubmit}>
          <div className='bg-white mt-4 p-4'>
            <QuestionComponent
              questionText={ questionText }
              handleTextChange={ handleTextChange }
            />
          { !isValidFile && <p className='text-danger'>Please select a valid image file (jpg, jpeg, png)</p> }
          <Form.Group controlId='questionImages'>
            <Form.Label>Upload Images</Form.Label>
            <Form.Control 
              type='file'
              multiple={false}
              accept='.jpg, .jpeg, .png'
              onChange={handleFileChange}
            />
          </Form.Group>
          <div className='mt-4'>
            <LevelDropdown handleLevelSelection={ handleLevelSelection } />
          </div>
          <Button 
            variant='primary'
            type='submit'
            disabled={!isValidFile}
            className='mt-4'>
            Submit
          </Button>
          </div>
        </Form>
      )}
      <Keyword />
    </>
  )
}

export default CreateQuestionForm
