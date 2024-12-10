import React, { useState } from 'react'
import { Dropdown, Form } from 'react-bootstrap'
import CustomDropdown from '../CustomDropdown'
import { QUESTION_TYPE_NAMES } from '../../../constants/questionTypes'

const QuestionTypeDropdown = ({ handleQuestionTypeSelection }) => {
  const [selectedQuestionType, setSelectedQuestionType] = useState('Bow Tie')

  const questionTypeDropdown = (questionType) => {
    handleQuestionTypeSelection(questionType)
    setSelectedQuestionType(questionType)
  }

  return (
    <>
      <h2 className='h5 fw-bold mt-5'>Create a Question</h2>
      <Form>
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
      </Form>
    </>
  )
}

export default QuestionTypeDropdown
