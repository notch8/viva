import React, { useState, useEffect } from 'react'
import QuestionText from './QuestionText'
import AnswerField from './AnswerField'
import { Button } from 'react-bootstrap'
import { Plus } from '@phosphor-icons/react'

const DragAndDrop = ({ questionText, handleTextChange, onDataChange, resetFields }) => {
  const [answers, setAnswers] = useState([{ answer: '', correct: false }])

  useEffect(() => {
    if (resetFields) {
      setAnswers([{ answer: '', correct: false }])
    }
  }, [resetFields])

  useEffect(() => {
    // Ensure data is properly formatted for the backend
    const formattedAnswers = answers.map(answer => ({
      answer: answer.answer,
      correct: answer.correct
    }))
    onDataChange(formattedAnswers)
  }, [answers, onDataChange])

  const addAnswer = () => {
    setAnswers([...answers, { answer: '', correct: false }])
  }

  const updateAnswer = (index, field, value) => {
    const updatedAnswers = answers.map((answer, i) => {
      if (i === index) {
        return { ...answer, [field]: value }
      }
      return answer
    })
    setAnswers(updatedAnswers)
  }

  const removeAnswer = (index) => {
    const updatedAnswers = answers.filter((_, i) => i !== index)
    setAnswers(updatedAnswers)
  }

  const hasAtLeastOneCorrectAnswer = answers.some(answer => answer.correct && answer.answer.trim() !== '')

  return (
    <div>
      <QuestionText questionText={questionText} handleTextChange={handleTextChange} />
      <AnswerField answers={answers} updateAnswer={updateAnswer} removeAnswer={removeAnswer} />

      <Button
        variant='secondary'
        onClick={addAnswer}
        className='d-flex align-items-center'
      >
        <Plus className='me-2' /> Add Answer
      </Button>

      {!hasAtLeastOneCorrectAnswer && answers.some(answer => answer.answer.trim() !== '') && (
        <div className='text-danger mt-2'>
          Please mark at least one non-empty answer as correct.
        </div>
      )}
    </div>
  )
}

export default DragAndDrop
