import React from 'react'
import { Form } from 'react-bootstrap'

const Scenario = ({ scenarioText, handleTextChange }) => {
  return (
    <>
      <Form.Group controlId='scenarioText' className='pr-4'>
        <Form.Label className='h6 fw-bold'>Enter Scenario Text</Form.Label>
        <p className=''>*Required Field</p>
        <Form.Control
          as='textarea'
          rows={5}
          value={scenarioText}
          onChange={handleTextChange}
          placeholder='Enter your scenario text here'
          className='mr-4 p-2 mb-4'
        />
      </Form.Group>
    </>
  )
}

export default React.memo(Scenario)
