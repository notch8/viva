import React, { useState } from 'react'
import { Button, Form } from 'react-bootstrap'
import Bowtie from './Bowtie'
import Categorization from './Categorization'
import DragAndDrop from './DragAndDrop'
import Essay from './Essay'
import Matching from './Matching'
import MultipleChoice from './MultipleChoice'
import SelectAllThatApply from './SelectAllThatApply'
import QuestionTypeDropdown from './QuestionTypeDropdown'
import QuestionText from './QuestionText'

const StimulusCaseStudy = ({ questionText, handleTextChange, onDataChange, resetFields }) => {
  const [subQuestions, setSubQuestions] = useState([])
  const [caseStudyText, setCaseStudyText] = useState('')

  const COMPONENT_MAP = {
    'Bow Tie': Bowtie,
    'Categorization': Categorization,
    'Drag and Drop': DragAndDrop,
    'Essay': Essay,
    'Matching': Matching,
    'Multiple Choice': MultipleChoice,
    'Select All That Apply': SelectAllThatApply,
  }

  const addSubQuestion = () => {
    setSubQuestions([
      ...subQuestions,
      { id: Date.now(), type: '', text: '', data: null },
    ])
  }

  const handleSubQuestionTypeSelection = (id, type) => {
    setSubQuestions((prev) =>
      prev.map((sq) => (sq.id === id ? { ...sq, type } : sq))
    )
  }

  const handleSubQuestionChange = (id, key, value) => {
    setSubQuestions((prev) =>
      prev.map((sq) => (sq.id === id ? { ...sq, [key]: value } : sq))
    )
  }

  const removeSubQuestion = (id) => {
    setSubQuestions((prev) => prev.filter((sq) => sq.id !== id))
  }

  const isSubmitDisabled = () => {
    if (!caseStudyText.trim()) return true // Case Study Text must not be empty
    if (subQuestions.length === 0) return true // At least one subquestion is required
    return false
  }

  const handleSubmit = (e) => {
    e.preventDefault()
    const formData = {
      text: caseStudyText,
      subQuestions,
    }
    onSubmit(formData)
  }

  return (
    <div className='stimulus-case-study-form'>
      <QuestionText questionText={questionText} handleTextChange={handleTextChange} />
      <h3>Stimulus Case Study</h3>
      <Form onSubmit={handleSubmit}>

        <h4>Subquestions</h4>
        {subQuestions.map((sq) => {
          const QuestionComponent = COMPONENT_MAP[sq.type] || null
          return (
            <div key={sq.id} className='subquestion'>
              <QuestionTypeDropdown
                handleQuestionTypeSelection={(type) =>
                  handleSubQuestionTypeSelection(sq.id, type)
                }
              />
              {QuestionComponent && (
                <QuestionComponent
                  questionText={sq.text}
                  handleTextChange={(e) =>
                    handleSubQuestionChange(sq.id, 'text', e.target.value)
                  }
                  onDataChange={(data) =>
                    handleSubQuestionChange(sq.id, 'data', data)
                  }
                />
              )}
              <Button
                variant='danger'
                className='mt-2'
                onClick={() => removeSubQuestion(sq.id)}
              >
                Remove Subquestion
              </Button>
            </div>
          )
        })}

        <Button
          type='button' // Explicitly set this as a non-submit button
          variant='secondary'
          className='mt-3'
          onClick={addSubQuestion}
        >
          Add Subquestion
        </Button>
      </Form>
    </div>
  )
}

export default StimulusCaseStudy
