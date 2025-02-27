import React, { useState } from 'react'
import { Form, InputGroup } from 'react-bootstrap'
import { Typeahead } from 'react-bootstrap-typeahead'

const Subject = ({ subjectOptions, handleAddSubject }) => {
  const [subject, setSubject] = useState([])

  const handleSubjectChange = (selected) => {
    setSubject(selected)
    handleAddSubject(selected)
  }

  return (
    <div className='bg-light-2 p-2 mb-2 rounded'>
      <h6 className='fw-bold'>Subjects</h6>
      <InputGroup className='mb-3 text-uppercase'>
        <Form.Group controlId='add-subject'>
          <Typeahead
            id="basic-typeahead"
            onChange={handleSubjectChange}
            options={subjectOptions}
            placeholder="Select subjects"
            multiple={true}
            selected={subject}
          />
        </Form.Group>
      </InputGroup>
    </div>
  )
}

export default Subject
