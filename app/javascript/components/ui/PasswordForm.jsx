

import React from 'react'
import { InputGroup, Form, Button, Col } from 'react-bootstrap'

const PasswordForm = () => {
  return (
    <Form>
      <Col md={8}>
        <InputGroup className="mb-3">
          <InputGroup.Text id='current-password'>
            Current Password
          </InputGroup.Text>
          <Form.Control
            aria-label="Enter your current password"
            aria-describedby="current-password"
          />
        </InputGroup>
        <InputGroup className="mb-3">
          <InputGroup.Text id='new-password'>
            New Password
          </InputGroup.Text>
          <Form.Control
            aria-label="Input your New Password"
            aria-describedby="new-password"
          />
        </InputGroup>
        <InputGroup className="mb-3">
          <InputGroup.Text id='confirm-new-password'>
            Confirm New Password
          </InputGroup.Text>
          <Form.Control
            aria-label="Re-enter your new password"
            aria-describedby="confirm-new-password"
          />
        </InputGroup>
      </Col>
      <Button className='btn btn-primary d-block ms-auto' type="submit">Save</Button>
    </Form>
  )
}

export default PasswordForm