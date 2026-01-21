import React, { useState, useEffect } from 'react'
import { Form } from 'react-bootstrap'
import { Typeahead } from 'react-bootstrap-typeahead'
// https://github.com/ericgio/react-bootstrap-typeahead

const Subject = ({
  subjectOptions = [],
  handleAddSubject,
  selectedSubjects = []
}) => {
  const [subject, setSubject] = useState(selectedSubjects || [])

  useEffect(() => {
    setSubject(selectedSubjects || [])
  }, [selectedSubjects])

  const handleSubjectChange = (selectedSubject) => {
    const validSubject = selectedSubject || []
    setSubject(validSubject)
    handleAddSubject(validSubject)
  }

  return (
    <div className='bg-light-2 p-2 mb-2 rounded'>
      <h6 className='fw-bold'>Subjects</h6>
      <Form.Group id='add-subject'>
        <Typeahead
          id='basic-typeahead'
          inputProps={{
            id: 'basic-typeahead-input',
            name: 'subjects',
            'aria-label': 'Select subjects'
          }}
          onChange={handleSubjectChange}
          options={subjectOptions || []}
          placeholder='Select subjects'
          multiple={true}
          selected={subject || []}
        />
      </Form.Group>
    </div>
  )
}

export default Subject
