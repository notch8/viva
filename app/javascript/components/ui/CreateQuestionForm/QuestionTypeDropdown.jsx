import React from 'react'
import { Dropdown, Form } from 'react-bootstrap'
import CustomDropdown from '../CustomDropdown'

const QuestionTypeDropdown = ({ handleQuestionTypeSelection, QUESTION_TYPE_NAMES }) => {
  const questionTypeDropdown = (questionType) => {
    handleQuestionTypeSelection(questionType)
  }

  return (
    <Form.Group controlId='questionType'>
      <CustomDropdown dropdownSelector='.question-type-dropdown'>
        <Dropdown onSelect={questionTypeDropdown} className='question-type-dropdown'>
          <Dropdown.Toggle variant='secondary'>Select Question Type</Dropdown.Toggle>
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
