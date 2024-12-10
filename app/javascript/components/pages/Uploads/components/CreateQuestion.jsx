import React from 'react'
import { Dropdown, Form } from 'react-bootstrap'
import CustomDropdown from '../../../ui/CustomDropdown'
import { QUESTION_TYPE_NAMES } from '../../../../constants/questionTypes'

const CreateQuestion = ({ selectedType, onTypeSelect }) => {
  return (
    <div>
      <h2 className='h5 fw-bold mt-5'>Create a Question</h2>
      <Form>
        <Form.Group controlId='questionType'>
          <Form.Label>Select Question Type</Form.Label>
          <CustomDropdown dropdownSelector='.question-type-dropdown'>
            <Dropdown onSelect={onTypeSelect} className='question-type-dropdown'>
              <Dropdown.Toggle variant='secondary'>{selectedType}</Dropdown.Toggle>
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
    </div>
  )
}

export default CreateQuestion
