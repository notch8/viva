import React, {
  useState, useEffect, useCallback, useMemo, useRef
} from 'react'
import { Button } from 'react-bootstrap'
import { SUBQUESTION_TYPE_NAMES } from '../../../constants/questionTypes'
import Scenario from './Scenario'
import Bowtie from './Bowtie'
import Categorization from './Categorization'
import DragAndDrop from './DragAndDrop'
import Essay from './Essay'
import Matching from './Matching'
import MultipleChoice from './MultipleChoice'
import SelectAllThatApply from './SelectAllThatApply'
import Upload from './Upload'
import QuestionTypeDropdown from './QuestionTypeDropdown'
import QuestionText from './QuestionText'

const StimulusCaseStudy = ({ handleTextChange, onDataChange, questionText, questionType, resetFields }) => {
  const [subQuestions, setSubQuestions] = useState([])
  const updateTimeout = useRef(null)

  const COMPONENT_MAP = useMemo(
    () => ({
      'Scenario': Scenario,
      'Bow Tie': Bowtie,
      'Categorization': Categorization,
      'Drag and Drop': DragAndDrop,
      'Essay': Essay,
      'Matching': Matching,
      'Multiple Choice': MultipleChoice,
      'Select All That Apply': SelectAllThatApply,
      'File Upload': Upload
    }),
    []
  )

  const initializeDataForType = useCallback((type) => {
    switch (type) {
    case 'Scenario':
      return { text: '' }
    case 'Multiple Choice':
    case 'Select All That Apply':
    case 'Drag and Drop':
      return [{ answer: '', correct: false }]
    case 'Bow Tie':
      return {
        center: { label: 'Center Label', answers: [] },
        left: { label: 'Left Label', answers: [] },
        right: { label: 'Right Label', answers: [] },
      }
    case 'Matching':
      return [{ answer: '', correct: '' }]
    case 'Categorization':
      return [{ answer: '', correct: [] }]
    case 'Essay':
    case 'File Upload':
      return { html: '<p></p>' }
    default:
      return null
    }
  }, [])

  const updateParent = useCallback(
    (updatedSubQuestions) => {
      if (updateTimeout.current) {
        clearTimeout(updateTimeout.current)
      }

      updateTimeout.current = setTimeout(() => {
        onDataChange({
          text: questionText,
          subQuestions: updatedSubQuestions.map((sq) => ({
            ...sq,
            data: sq.data,
          })),
        })
      }, 300)
    },
    [questionText, onDataChange]
  )

  const handleSubQuestionTypeSelection = useCallback(
    (id, type) => {
      setSubQuestions((prev) => {
        const updated = prev.map((sq) =>
          sq.id === id ? { ...sq, type, data: initializeDataForType(type) } : sq
        )
        updateParent(updated)
        return updated
      })
    },
    [initializeDataForType, updateParent]
  )

  const handleSubQuestionChange = useCallback(
    (id, key, value) => {
      setSubQuestions((prev) => {
        const updated = prev.map((sq) => {
          if (sq.id === id) {
            const updatedSq = { ...sq, [key]: value }
            if ((sq.type === 'Essay' || sq.type === 'File Upload') && key === 'text') {
              updatedSq.data = {
                html: value
                  .split('\n')
                  .map((line, index) => `<p key=${index}>${line}</p>`)
                  .join(''),
              }
            }
            return updatedSq
          }
          return sq
        })
        updateParent(updated)
        return updated
      })
    },
    [updateParent]
  )

  const addSubQuestion = useCallback(() => {
    setSubQuestions((prev) => {
      const updated = [...prev, { id: Date.now(), type: '', text: '', data: null }]
      updateParent(updated)
      return updated
    })
  }, [updateParent])

  const removeSubQuestion = useCallback(
    (id) => {
      setSubQuestions((prev) => {
        const updated = prev.filter((sq) => sq.id !== id)
        updateParent(updated)
        return updated
      })
    },
    [updateParent]
  )

  useEffect(() => {
    updateParent(subQuestions)
    return () => {
      if (updateTimeout.current) {
        clearTimeout(updateTimeout.current)
      }
    }
  }, [subQuestions, updateParent])

  return (
    <div className='stimulus-case-study-form'>
      <h3>{questionType} Question</h3>
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
                resetFields={resetFields}
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

export default React.memo(StimulusCaseStudy)
