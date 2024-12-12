import React, { useState } from 'react'
import { Form, Button, InputGroup } from 'react-bootstrap'
import Bowtie from './Bowtie'
import Essay from './Essay'
import QuestionTypeDropdown from './QuestionTypeDropdown'
import LevelDropdown from './LevelDropdown'
import Keyword from './Keyword'

const CreateQuestionForm = () => {
  const [questionType, setQuestionType] = useState('')
  const [questionText, setQuestionText] = useState('')
  const [images, setImages] = useState([])
  const [level, setLevel] = useState('')
  const [keywords, setKeywords] = useState([]) 

  // Conditional form rendering based on question type
  const COMPONENT_MAP = {
    'Essay': Essay,
    'Bow Tie': Bowtie
  }
  const QuestionComponent = COMPONENT_MAP[questionType] || null

  // Select the question type to render the appropriate form
  const handleQuestionTypeSelection = (type) => {
    setQuestionType(type)
  }

  // Enter the text content for the question
  const handleTextChange = (e) => {
    setQuestionText(e.target.value)
  }

  // Upload images associated with the question (jpg, jpeg, png)
  // ******TO DO: can we upload multiple images at once?
  const handleImageChange = (e) => {
    const files = Array.from(e.target.files)
    const newImages = files.map((file) => ({
      file,
      preview: URL.createObjectURL(file),
    }))
    setImages((prevImages) => [...prevImages, ...newImages])
  }

  // Select the level (1-6) of the question
  const handleLevelSelection = (levelData) => { 
    setLevel(levelData)
  }

  // Add new keyword to the list of keywords
  const handleAddKeyword = (keyword) => {
    setKeywords([...keywords, keyword])
  }

  // Remove a keyword from the list of keywords
  const handleRemoveKeyword = (keywordToRemove) => {
    setKeywords(keywords.filter((keyword) => keyword !== keywordToRemove))
  }

  // Submits the form data to the Rails API
  const handleSubmit = async (e) => {
    e.preventDefault()
    const formattedText = questionText.split('\n').map((line, index) => `<p key=${index}>${line}</p>`).join('')
   
    // Prepare the form data
    const formData = new FormData()
    formData.append('question[type]', `Question::${questionType}`)
    formData.append('question[level]', level)
    formData.append('question[text]', questionText)
    formData.append('question[data][html]', formattedText)

    images.forEach(({ file }, index) => {
      formData.append(`question[images][]`, file)
    })

    keywords.forEach((keyword, index) => {
      formData.append(`question[keywords][]`, keyword)
    })

    try {
      const response = await fetch('/api/questions', {
        method: 'POST',
        body: formData, // Send as multipart form data
      })
      if (response.ok) {
        alert('Question saved successfully!')
        setQuestionText('')
        setImages([])
        setKeywords([])
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

      <QuestionTypeDropdown handleQuestionTypeSelection={handleQuestionTypeSelection} />
      
      { QuestionComponent && (
        <div className='bg-white mt-4 p-4 d-flex'>
          <Form onSubmit={handleSubmit} className='mx-4 flex-fill'>
            <QuestionComponent
              questionText={questionText}
              handleTextChange={handleTextChange}
            />
            <InputGroup className='my-4 text-uppercase csv-upload-form'>
              <InputGroup.Text className='strait py-3' htmlFor="file-upload">
                Upload Image
              </InputGroup.Text>
              <Form.Group>
                <Form.Control
                  type='file'
                  id='file-upload'
                  aria-label='Upload an image here'
                  onChange={handleImageChange}
                  className='rounded-0 py-3'
                />
              </Form.Group>
            </InputGroup>

            <Button
              type="submit"
              className="btn btn-primary mt-3"
            >
              Submit
            </Button>
          </Form>
          <div className='m-4'>
            <Keyword keywords={keywords} handleAddKeyword={handleAddKeyword} handleRemoveKeyword={handleRemoveKeyword} />
            <LevelDropdown handleLevelSelection={handleLevelSelection} />
          </div>
        </div>
      )}
    </>
  )
}

export default CreateQuestionForm
