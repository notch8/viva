import React, { useState, useRef } from 'react'
import Bowtie from './Bowtie'
import Essay from './Essay'
import QuestionTypeDropdown from './QuestionTypeDropdown'

const CreateQuestionForm = () => {
  const [questionText, setQuestionText] = useState('')
  const [questionType, setQuestionType] = useState('')
  const [images, setImages] = useState([])
  const [keywords, setKeywords] = useState([])
  const [newKeyword, setNewKeyword] = useState('')
  const [imageErrors, setImageErrors] = useState([]) // Track errors for specific files
  const fileInputRef = useRef(null)

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
          isValid: true, // Mark valid files
        })
      } else {
        newImages.push({
          file,
          preview: URL.createObjectURL(file),
          isValid: false, // Mark invalid files
        })
        newErrors.push(`"${file.name}" is not a valid file type. Only JPG, JPEG, and PNG are allowed.`)
      }
    })

    setImages((prevImages) => [...prevImages, ...newImages])
    setImageErrors(newErrors)
  }

  const handleRemoveImage = (index) => {
    setImages((prevImages) => {
      URL.revokeObjectURL(prevImages[index].preview)
      return prevImages.filter((_, i) => i !== index)
    })
    setImageErrors((prevErrors) => prevErrors.filter((_, i) => i !== index))
    if (images.length === 1) {
      fileInputRef.current.value = null
    }
  }

  const handleAddKeyword = () => {
    if (newKeyword.trim() && !keywords.includes(newKeyword)) {
      setKeywords([...keywords, newKeyword.trim()])
      setNewKeyword('') // Clear input after adding
    }
  }

  const handleRemoveKeyword = (keywordToRemove) => {
    setKeywords(keywords.filter((keyword) => keyword !== keywordToRemove))
  }

  const formatTextToParagraph = (text) => {
    return text.split('\n').map((line, index) => `<p key=${index}>${line}</p>`).join('')
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    const formattedText = formatTextToParagraph(questionText)

    const formData = new FormData()
    formData.append('question[type]', `Question::${questionType}`)
    formData.append('question[text]', questionText)
    formData.append('question[data][html]', formattedText)

    images
      .filter((image) => image.isValid) // Only send valid images
      .forEach(({ file }, index) => {
        formData.append(`question[images][]`, file)
      })

    keywords.forEach((keyword, index) => {
      formData.append(`question[keywords][]`, keyword)
    })

    try {
      const response = await fetch('/api/questions', {
        method: 'POST',
        body: formData,
      })

      if (response.ok) {
        alert('Question saved successfully!')
        setQuestionText('')
        setImages([])
        setKeywords([])
        fileInputRef.current.value = null
      } else {
        const errorData = await response.json()
        alert(`Failed to save the question: ${errorData.errors.join(', ')}`)
      }
    } catch (error) {
      console.error('Error saving the question:', error)
      alert('An error occurred while saving the question.')
    }
  }

  const isSubmitDisabled = !questionText || images.some(image => !image.isValid)

  return (
    <>
      <h2 className='h5 fw-bold mt-5'>Create a Question</h2>
      <QuestionTypeDropdown handleQuestionTypeSelection={handleQuestionTypeSelection} />
      {QuestionComponent && (
        <form className='bg-white mt-4 p-4' onSubmit={handleSubmit}>
          <QuestionComponent
            questionText={questionText}
            handleTextChange={handleTextChange}
          />
          <div className="mt-3">
            <label htmlFor="file-upload" className="form-label">Upload Images</label>
            <input
              type="file"
              id="file-upload"
              className="form-control"
              multiple
              accept="image/*"
              onChange={handleImageChange}
              ref={fileInputRef}
            />
            {imageErrors.length > 0 && (
              <div className="mt-2">
                {imageErrors.map((error, index) => (
                  <p key={index} className="text-danger">
                    {error}
                  </p>
                ))}
              </div>
            )}
            <div className="mt-3">
              {images.map((image, index) => (
                <div key={index} className="d-flex align-items-center mt-2">
                  <img
                    src={image.preview}
                    alt="Preview"
                    style={{ width: '50px', height: '50px', objectFit: 'cover', marginRight: '10px' }}
                  />
                  <span className={`me-3 ${!image.isValid ? 'text-danger' : ''}`}>
                    {image.file.name} {!image.isValid && '(Invalid)'}
                  </span>
                  <button
                    type="button"
                    className="btn btn-danger btn-sm ms-3"
                    onClick={() => handleRemoveImage(index)}
                  >
                    Remove
                  </button>
                </div>
              ))}
            </div>
          </div>

          {/* Keywords Block */}
          <div className="mt-4">
            <label className="form-label">Keywords</label>
            <div className="d-flex flex-wrap mb-2">
              {keywords.map((keyword, index) => (
                <span key={index} className="badge bg-secondary me-2">
                  {keyword}
                  <button
                    type="button"
                    className="btn-close ms-2"
                    aria-label="Remove"
                    onClick={() => handleRemoveKeyword(keyword)}
                  />
                </span>
              ))}
            </div>
            <div className="input-group">
              <input
                type="text"
                className="form-control"
                placeholder="Add a keyword"
                value={newKeyword}
                onChange={(e) => setNewKeyword(e.target.value)}
              />
              <button
                type="button"
                className="btn btn-primary"
                onClick={handleAddKeyword}
              >
                Add
              </button>
            </div>
          </div>

          <button
            type="submit"
            className="btn btn-primary mt-3"
            disabled={isSubmitDisabled}
          >
            Submit
          </button>
        </form>
      )}
    </>
  )
}

export default CreateQuestionForm
