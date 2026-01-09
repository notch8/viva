import React from 'react'
import { Form, Button } from 'react-bootstrap'
import Bowtie from './Bowtie'
import Categorization from './Categorization'
import DragAndDrop from './DragAndDrop'
import Essay from './Essay'
import Matching from './Matching'
import MultipleChoice from './MultipleChoice'
import SelectAllThatApply from './SelectAllThatApply'
import StimulusCaseStudy from './StimulusCaseStudy'
import Upload from './Upload'
import QuestionTypeDropdown from './QuestionTypeDropdown'
import LevelDropdown from './LevelDropdown'
import Subject from './Subject'
import ImageUploader from './ImageUploader'
import { QUESTION_TYPE_NAMES } from '../../../constants/questionTypes'

const COMPONENT_MAP = {
  'Bow Tie': Bowtie,
  'Categorization': Categorization,
  'Drag and Drop': DragAndDrop,
  'Essay': Essay,
  'Matching': Matching,
  'Multiple Choice': MultipleChoice,
  'Select All That Apply': SelectAllThatApply,
  'Stimulus Case Study': StimulusCaseStudy,
  'File Upload': Upload
}

export const QuestionFormUI = ({
  question,
  questionType,
  questionText,
  images,
  level,
  subjects,
  data,
  resetFields,
  subjectOptions,
  isSubmitDisabled,
  onQuestionTypeSelection,
  onTextChange,
  onDataChange,
  onImagesChange,
  onLevelSelection,
  onAddSubject,
  onRemoveSubject,
  onSubmit
}) => {
  const QuestionComponent = COMPONENT_MAP[questionType] || null

  return (
    <div className='create-question-form'>
      <h2 className='h5 fw-bold mt-5'>Create a Question</h2>
      <QuestionTypeDropdown
        handleQuestionTypeSelection={onQuestionTypeSelection}
        QUESTION_TYPE_NAMES={QUESTION_TYPE_NAMES}
      />

      {QuestionComponent && (
        <div className='question-body bg-white mt-4 p-4'>
          <Form onSubmit={onSubmit} className='question-form mx-4'>
            <div className='d-flex flex-wrap'>
              <div className='flex-fill'>
                <QuestionComponent
                  handleTextChange={onTextChange}
                  onDataChange={onDataChange}
                  questionText={questionText}
                  questionType={questionType}
                  resetFields={resetFields}
                />
                <ImageUploader images={images} setImages={onImagesChange} />
              </div>
              <div className='tag-section m-4'>
                <Subject
                  subjectOptions={subjectOptions}
                  handleAddSubject={onAddSubject}
                  handleRemoveSubject={onRemoveSubject}
                />
                <LevelDropdown handleLevelSelection={onLevelSelection} />
              </div>
            </div>

            <Button
              type='submit'
              className='btn btn-primary mt-3'
              disabled={isSubmitDisabled}
            >
              Submit
            </Button>
          </Form>
        </div>
      )}
    </div>
  )
}

export default QuestionFormUI
