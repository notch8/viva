import React, { useState, useEffect } from 'react'
import { Form, Button } from 'react-bootstrap'
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
      <Form.Group className="mb-3">
        <Form.Label className="h6">Question</Form.Label>
        <Form.Control
          type="text"
          value={questionText}
          onChange={handleTextChange}
          placeholder="Enter your question"
        />
      </Form.Group>

      <Form.Group className="mb-3">
        <Form.Label className="h6">Answers</Form.Label>
        {answers.map((answer, index) => (
          <div key={index} className="d-flex align-items-center mb-2">
            <Form.Control
              type="text"
              value={answer.answer}
              onChange={(e) => updateAnswer(index, 'answer', e.target.value)}
              placeholder={`Answer ${index + 1}`}
              className="me-2"
            />
            <Form.Check
              type="checkbox"
              checked={answer.correct}
              onChange={(e) => updateAnswer(index, 'correct', e.target.checked)}
              label="Correct"
            />
            <Button
              variant="danger"
              size="sm"
              className="ms-2"
              onClick={() => removeAnswer(index)}
              disabled={answers.length === 1}
            >
              Remove
            </Button>
          </div>
        ))}
      </Form.Group>

      <Button
        variant="secondary"
        onClick={addAnswer}
        className="d-flex align-items-center"
      >
        <Plus className="me-2" /> Add Answer
      </Button>

      {!hasAtLeastOneCorrectAnswer && answers.some(answer => answer.answer.trim() !== '') && (
        <div className="text-danger mt-2">
          Please mark at least one non-empty answer as correct.
        </div>
      )}
    </div>
  )
}

export default DragAndDrop