import React, { useState, useEffect } from 'react'
import { Button } from 'react-bootstrap'
import { SUBQUESTION_TYPE_NAMES } from '../../../constants/questionTypes'
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

  const COMPONENT_MAP = {
    'Bow Tie': Bowtie,
    'Categorization': Categorization,
    'Drag and Drop': DragAndDrop,
    'Essay': Essay,
    'Matching': Matching,
    'Multiple Choice': MultipleChoice,
    'Select All That Apply': SelectAllThatApply,
  }

  const initializeDataForType = (type) => {
    switch (type) {
    case 'Multiple Choice':
    case 'Select All That Apply':
    case 'Drag and Drop':
      return [{ answer: '', correct: false }] // Default answer structure
    case 'Bow Tie':
      return { center: { answers: [] }, left: { answers: [] }, right: { answers: [] } }
    case 'Matching':
    case 'Categorization':
      return [{ answer: '', correct: [] }] // Default structure for pairings
    case 'Essay':
      return { html: '' } // Default structure for essays
    default:
      return null // Default for unsupported types
    }
  }

  const formatDataForType = (subQuestion) => {
    const { type, data, text } = subQuestion

    switch (type) {
    case 'Essay':
      return {
        html: text
          .split('\n')
          .map((line) => `<p>${line}</p>`)
          .join(''),
      }
    case 'Multiple Choice':
    case 'Select All That Apply':
    case 'Drag and Drop':
      return Array.isArray(data)
        ? data.filter((item) => item.answer.trim() !== '')
        : []
    case 'Matching':
    case 'Categorization':
      return Array.isArray(data)
        ? data.map((pair) => ({
          answer: pair.answer.trim(),
          correct: Array.isArray(pair.correct) ? pair.correct.map((item) => item.trim()) : [],
        }))
        : []
    case 'Bow Tie':
      return data
    default:
      return data
    }
  }

  const addSubQuestion = () => {
    setSubQuestions((prev) => [
      ...prev,
      { id: Date.now(), type: '', text: '', data: null },
    ])
  }

  const handleSubQuestionTypeSelection = (id, type) => {
    setSubQuestions((prev) =>
      prev.map((sq) =>
        sq.id === id ? { ...sq, type, data: initializeDataForType(type) } : sq
      )
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

  useEffect(() => {
    const formattedSubQuestions = subQuestions.map((sq) => ({
      ...sq,
      data: formatDataForType(sq),
    }))
    onDataChange({ text: questionText, subQuestions: formattedSubQuestions })
  }, [questionText, subQuestions, onDataChange])

  return (
    <div className='stimulus-case-study-form'>
      <h3>Stimulus Case Study</h3>
      <QuestionText questionText={questionText} handleTextChange={handleTextChange} />

      <h4>Subquestions</h4>
      {subQuestions.map((sq) => {
        const QuestionComponent = COMPONENT_MAP[sq.type] || null
        return (
          <div key={sq.id} className='subquestion'>
            <QuestionTypeDropdown
              handleQuestionTypeSelection={(type) =>
                handleSubQuestionTypeSelection(sq.id, type)
              }
              QUESTION_TYPE_NAMES={SUBQUESTION_TYPE_NAMES}
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
            <div>
              <Button
                variant='danger'
                className='mt-2'
                onClick={() => removeSubQuestion(sq.id)}
              >
                Remove Subquestion
              </Button>
            </div>
          </div>
        )
      })}

      <Button
        type='button'
        variant='secondary'
        className='mt-3'
        onClick={addSubQuestion}
      >
        Add Subquestion
      </Button>
    </div>
  )
}

export default StimulusCaseStudy

