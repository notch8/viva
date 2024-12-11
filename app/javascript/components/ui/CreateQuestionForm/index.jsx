import React, { useState } from 'react'
import Bowtie from './Bowtie'
import Essay from './Essay'
import QuestionTypeDropdown from './QuestionTypeDropdown'

const CreateQuestionForm = () => {
  const [questionText, setQuestionText] = useState('')
  const [questionType, setQuestionType] = useState('')

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
            type: `Question::${questionType}`,
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
    <>
      <h2 className='h5 fw-bold mt-5'>Create a Question</h2>
      <QuestionTypeDropdown handleQuestionTypeSelection={ handleQuestionTypeSelection } />
      { QuestionComponent && (
        <div className='bg-white mt-4 p-4'>
          <QuestionComponent
            handleSubmit={ handleSubmit }
            questionText={ questionText }
            handleTextChange={ handleTextChange }
          />
        </div>
      )}
    </>
  )
}

export default CreateQuestionForm
