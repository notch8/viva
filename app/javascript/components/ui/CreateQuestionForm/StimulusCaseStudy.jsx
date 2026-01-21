import React, {
  useState, useEffect, useCallback, useMemo, useRef
} from 'react'
import { Button, Modal, ListGroup } from 'react-bootstrap'
import {
  DndContext,
  closestCenter,
  KeyboardSensor,
  PointerSensor,
  useSensor,
  useSensors
} from '@dnd-kit/core'
import {
  arrayMove,
  SortableContext,
  sortableKeyboardCoordinates,
  useSortable,
  verticalListSortingStrategy
} from '@dnd-kit/sortable'
import { CSS } from '@dnd-kit/utilities'
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

// Sortable subquestion item component
const SortableSubQuestionItem = ({ subQuestion, index, onEdit, onRemove }) => {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging
  } = useSortable({ id: subQuestion.id })

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    opacity: isDragging ? 0.5 : 1
  }

  return (
    <ListGroup.Item
      ref={setNodeRef}
      style={style}
      className="d-flex justify-content-between align-items-center"
    >
      <div className="d-flex align-items-center flex-grow-1">
        <div
          {...attributes}
          {...listeners}
          className="me-3"
          style={{ cursor: 'grab', touchAction: 'none' }}
        >
          <span className="text-muted">☰</span>
        </div>
        <div>
          <strong>#{index + 1}</strong> - {subQuestion.type || 'No Type Selected'}
          {subQuestion.text && (
            <div className="text-muted small">
              {subQuestion.text.substring(0, 50)}
              {subQuestion.text.length > 50 ? '...' : ''}
            </div>
          )}
        </div>
      </div>
      <div className="d-flex gap-2">
        <Button
          variant="outline-primary"
          size="sm"
          onClick={() => onEdit(subQuestion)}
        >
          Edit
        </Button>
        <Button
          variant="outline-danger"
          size="sm"
          onClick={() => onRemove(subQuestion.id)}
        >
          Remove
        </Button>
      </div>
    </ListGroup.Item>
  )
}

// Modal for editing individual subquestions
const SubQuestionEditModal = ({
  show,
  onHide,
  subQuestion,
  onChange,
  onSave,
  COMPONENT_MAP,
  resetFields
}) => {
  if (!subQuestion) return null

  const QuestionComponent = COMPONENT_MAP[subQuestion.type] || null

  return (
    <Modal show={show} onHide={onHide} size="xl">
      <Modal.Header closeButton>
        <Modal.Title>Edit Subquestion - {subQuestion.type}</Modal.Title>
      </Modal.Header>
      <Modal.Body>
        <QuestionTypeDropdown
          handleQuestionTypeSelection={(type) => onChange('type', type)}
          QUESTION_TYPE_NAMES={SUBQUESTION_TYPE_NAMES}
        />
        {QuestionComponent && (
          <QuestionComponent
            questionText={subQuestion.text}
            handleTextChange={(e) => onChange('text', e.target.value)}
            onDataChange={(data) => onChange('data', data)}
            resetFields={resetFields}
            data={subQuestion.data}
            questionType={subQuestion.type}
          />
        )}
      </Modal.Body>
      <Modal.Footer>
        <Button variant="secondary" onClick={onHide}>
          Cancel
        </Button>
        <Button variant="primary" onClick={onSave}>
          Save Changes
        </Button>
      </Modal.Footer>
    </Modal>
  )
}

const StimulusCaseStudy = ({
  handleTextChange,
  onDataChange,
  questionText,
  questionType,
  resetFields,
  data
}) => {
  const [subQuestions, setSubQuestions] = useState(
    data?.subQuestions &&
      Array.isArray(data.subQuestions) &&
      data.subQuestions.length > 0
      ? data.subQuestions.map((sq, idx) => ({
        ...sq,
        id: sq.id || Date.now() + idx,
        type: sq.type_name || sq.type || ''
      }))
      : []
  )
  const [editingSubQuestion, setEditingSubQuestion] = useState(null)
  const [tempSubQuestion, setTempSubQuestion] = useState(null)
  const [showEditModal, setShowEditModal] = useState(false)
  const updateTimeout = useRef(null)

  // Drag and drop sensors
  const sensors = useSensors(
    useSensor(PointerSensor),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates
    })
  )

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

  // Initialize data for different question types
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
        right: { label: 'Right Label', answers: [] }
      }
    case 'Matching':
      return [{ answer: '', correct: '' }]
    case 'Categorization':
      return [{ answer: '', correct: [] }]
    case 'Essay':
    case 'File Upload':
      return ''
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
            data: sq.data
          }))
        })
      }, 50)
    },
    [questionText, onDataChange]
  )

  // Handle drag end event
  const handleDragEnd = useCallback((event) => {
    const { active, over } = event

    if (over && active.id !== over.id) {
      setSubQuestions((prev) => {
        const oldIndex = prev.findIndex((sq) => sq.id === active.id)
        const newIndex = prev.findIndex((sq) => sq.id === over.id)
        const updated = arrayMove(prev, oldIndex, newIndex)
        updateParent(updated)
        return updated
      })
    }
  }, [updateParent])

  // Open edit modal for a subquestion
  const handleEditSubQuestion = useCallback((subQuestion) => {
    setEditingSubQuestion(subQuestion.id)
    setTempSubQuestion({ ...subQuestion })
    setShowEditModal(true)
  }, [])

  // Handle changes within the edit modal
  const handleModalChange = useCallback((key, value) => {
    setTempSubQuestion((prev) => {
      const updated = { ...prev, [key]: value }

      // If type is changed, initialize new data structure
      if (key === 'type') {
        updated.data = initializeDataForType(value)
      }

      return updated
    })
  }, [initializeDataForType])

  // Save changes from edit modal
  const handleSaveModal = useCallback(() => {
    setSubQuestions((prev) => {
      const updated = prev.map((sq) =>
        sq.id === editingSubQuestion ? { ...tempSubQuestion } : sq
      )
      updateParent(updated)
      return updated
    })
    setShowEditModal(false)
    setEditingSubQuestion(null)
    setTempSubQuestion(null)
  }, [editingSubQuestion, tempSubQuestion, updateParent])

  // Close modal without saving
  const handleCloseModal = useCallback(() => {
    setShowEditModal(false)
    setEditingSubQuestion(null)
    setTempSubQuestion(null)
  }, [])

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

      {/* Main question text */}
      <QuestionText
        questionText={questionText}
        handleTextChange={handleTextChange}
      />

      {/* Subquestions section */}
      <div className='mt-4'>
        <h4 className='mb-3'>Subquestions</h4>

        {subQuestions.length === 0 ? (
          <div className='text-muted mb-3'>
            No subquestions added yet. Click "Add Subquestion" to create one.
          </div>
        ) : (
          <DndContext
            sensors={sensors}
            collisionDetection={closestCenter}
            onDragEnd={handleDragEnd}
          >
            <SortableContext
              items={subQuestions.map(sq => sq.id)}
              strategy={verticalListSortingStrategy}
            >
              <ListGroup className='mb-3'>
                {subQuestions.map((sq, index) => (
                  <SortableSubQuestionItem
                    key={sq.id}
                    subQuestion={sq}
                    index={index}
                    onEdit={handleEditSubQuestion}
                    onRemove={removeSubQuestion}
                  />
                ))}
              </ListGroup>
            </SortableContext>
          </DndContext>
        )}

        <Button
          type='button'
          variant='secondary'
          onClick={addSubQuestion}
        >
          Add Subquestion
        </Button>
      </div>

      {/* Edit subquestion modal */}
      <SubQuestionEditModal
        show={showEditModal}
        onHide={handleCloseModal}
        subQuestion={tempSubQuestion}
        onChange={handleModalChange}
        onSave={handleSaveModal}
        COMPONENT_MAP={COMPONENT_MAP}
        resetFields={resetFields}
      />
    </div>
  )
}

export default React.memo(StimulusCaseStudy)
