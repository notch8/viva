import React, { useState } from 'react'
import { Dropdown, Form } from 'react-bootstrap'
import CustomDropdown from '../CustomDropdown'

const QuestionTypeDropdown = ({ handleQuestionTypeSelection, QUESTION_TYPE_NAMES }) => {
  const [selectedQuestionType, setSelectedQuestionType] = useState('Select Question Type')

  const questionTypeDropdown = (questionType) => {
    handleQuestionTypeSelection(questionType)
    setSelectedQuestionType(questionType)
  }

  return (
    <Form.Group controlId='questionType'>
      <Form.Label>Select Question Type</Form.Label>
      <CustomDropdown dropdownSelector='.question-type-dropdown'>
        <Dropdown onSelect={questionTypeDropdown} className='question-type-dropdown'>
          <Dropdown.Toggle variant='secondary'>{selectedQuestionType}</Dropdown.Toggle>
          <Dropdown.Menu>
            {QUESTION_TYPE_NAMES.map(({ key, value }) => (
              <Dropdown.Item key={key} eventKey={value}>
                {value}
              </Dropdown.Item>
            ))}
          </Dropdown.Menu>
        </Dropdown>
      </CustomDropdown>
    </Form.Group>
  )
}

export default QuestionTypeDropdown
