import React, { useState, useRef } from 'react'
import { Form, Button, InputGroup } from 'react-bootstrap'
import Bowtie from './Bowtie'
import Essay from './Essay'
import QuestionTypeDropdown from './QuestionTypeDropdown'
import LevelDropdown from './LevelDropdown'
import Keyword from './Keyword'
import Subject from './Subject'

const CreateQuestionForm = () => {
  const [questionType, setQuestionType] = useState('')
  const [questionText, setQuestionText] = useState('')
  const [images, setImages] = useState([])
  const [imageErrors, setImageErrors] = useState([]) // Track errors for each image
  const [level, setLevel] = useState('')
  const fileInputRef = useRef(null) // Ref for the file input field
  const [keywords, setKeywords] = useState([])
  const [subjects, setSubjects] = useState([])

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
  // Instantly flags invalid file types and shows an error
  const handleImageChange = (e) => {
    const validExtensions = ['jpg', 'jpeg', 'png']
    const files = Array.from(e.target.files)
    const newImages = []
    const newErrors = []

    files.forEach((file) => {
      const extension = file.name.split('.').pop().toLowerCase()
      if (validExtensions.includes(extension)) {
        newImages.push({
          file,
          preview: URL.createObjectURL(file),
          isValid: true,
        })
      } else {
        newImages.push({
          file,
          preview: URL.createObjectURL(file),
          isValid: false,
        })
        newErrors.push(`"${file.name}" is not a valid file type. Only JPG, JPEG, and PNG are allowed.`)
      }
    })

    setImages((prevImages) => [...prevImages, ...newImages])
    setImageErrors((prevErrors) => [...prevErrors, ...newErrors])
  }

  // Remove a selected image from the list and reset the file input field
  const handleRemoveImage = (index) => {
    setImages((prevImages) => {
      URL.revokeObjectURL(prevImages[index].preview)
      return prevImages.filter((_, i) => i !== index)
    })
    setImageErrors((prevErrors) => prevErrors.filter((_, i) => i !== index))
    if (images.length === 1) {
      fileInputRef.current.value = null // Reset file input
    }
  }

  // Add new keyword to the list of keywords
  const handleAddKeyword = (keyword) => {
    setKeywords([...keywords, keyword])
  }

  // Remove a keyword from the list of keywords
  const handleRemoveKeyword = (keywordToRemove) => {
    setKeywords(keywords.filter((keyword) => keyword !== keywordToRemove))
  }

  // Select the level (1-6) of the question
  const handleLevelSelection = (levelData) => {
    setLevel(levelData)
  }

  // Add new subject to the list of subjects
  const handleAddSubject = (subject) => {
    setSubjects([...subjects, subject])
  }

  // Remove a subject from the list of subjects
  const handleRemoveSubject = (subjectToRemove) => {
    setSubjects(subjects.filter((subject) => subject !== subjectToRemove))
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

    images
      .filter((image) => image.isValid) // Only include valid images
      .forEach(({ file }) => {
        formData.append('question[images][]', file)
      })

    keywords.forEach((keyword) => {
      formData.append('question[keywords][]', keyword)
    })

    subjects.forEach((subject) => {
      formData.append('question[subjects][]', subject)
    })

    try {
      const response = await fetch('/api/questions', {
        method: 'POST',
        body: formData,
      })
      console.log(response)
      if (response.ok) {
        alert('Question saved successfully!')
        setQuestionText('')
        setImages([])
        setLevel('')
        setKeywords([])
        setSubjects([])
        fileInputRef.current.value = null // Clear file input
      } else {
        const errorData = await response.json()
        alert(`Failed to save the question: ${errorData.errors.join(', ')}`)
      }
    } catch (error) {
      console.error('Error saving the question:', error)
      alert('An error occurred while saving the question.')
    }
  }

  // Disable submit button if question text is empty or there are invalid files
  const isSubmitDisabled = !questionText || images.some((image) => !image.isValid)

  return (
    <>
      <h2 className='h5 fw-bold mt-5'>Create a Question</h2>
      <QuestionTypeDropdown handleQuestionTypeSelection={handleQuestionTypeSelection} />

      { QuestionComponent && (
        <div className='bg-white mt-4 p-4 d-flex flex-wrap'>
          <Form onSubmit={handleSubmit} className='mx-4 flex-fill'>
            <QuestionComponent
              questionText={questionText}
              handleTextChange={handleTextChange}
            />
            <InputGroup className='my-4 text-uppercase csv-upload-form'>
              <InputGroup.Text className='strait py-3' htmlFor='file-upload'>
                Upload Image
              </InputGroup.Text>
              <Form.Group>
                <Form.Control
                  type='file'
                  id='file-upload'
                  aria-label='Upload an image here'
                  onChange={handleImageChange}
                  className='rounded-0 py-3'
                  ref={fileInputRef} // Attach ref for resetting
                />
              </Form.Group>
            </InputGroup>

            {imageErrors.length > 0 && (
              <div className='mt-2'>
                {imageErrors.map((error, index) => (
                  <p key={index} className='text-danger'>{error}</p>
                ))}
              </div>
            )}

            <div className='mt-3'>
              {images.map((image, index) => (
                <div key={index} className='d-flex align-items-center mt-2'>
                  <img
                    src={image.preview}
                    alt='Preview'
                    style={{ width: '50px', height: '50px', objectFit: 'cover', marginRight: '10px' }}
                  />
                  <span className={`me-3 ${!image.isValid ? 'text-danger' : ''}`}>
                    {image.file.name} {!image.isValid && '(Invalid)'}
                  </span>
                  <button
                    type='button'
                    className='btn btn-danger btn-sm ms-3'
                    onClick={() => handleRemoveImage(index)}
                  >
                    Remove
                  </button>
                </div>
              ))}
            </div>

            <Button
              type='submit'
              className='btn btn-primary mt-3'
              disabled={isSubmitDisabled}
            >
              Submit
            </Button>
          </Form>
          <div className='m-4'>
            <Keyword keywords={keywords} handleAddKeyword={handleAddKeyword} handleRemoveKeyword={handleRemoveKeyword} />
            <Subject subjects={subjects} handleAddSubject={handleAddSubject} handleRemoveSubject={handleRemoveSubject} />
            <LevelDropdown handleLevelSelection={handleLevelSelection} />
          </div>
        </div>
      )}
    </>
  )
}

export default CreateQuestionForm
