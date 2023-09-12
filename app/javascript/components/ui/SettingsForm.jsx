

import React from 'react'
import { Row, Col, InputGroup, Form } from 'react-bootstrap'

const SettingsForm = () => {
  return (
    <>
      <Row>
        <Col md={6}>
          <InputGroup className="mb-3">
            <InputGroup.Text id='first-name'>
              First Name
            </InputGroup.Text>
            <Form.Control
              aria-label="Input your first name"
              aria-describedby="first-name"
            />
          </InputGroup>
        </Col>
        <Col md={6}>
          <InputGroup className="mb-3">
              <InputGroup.Text id='last-name'>
                Last Name
              </InputGroup.Text>
              <Form.Control
                aria-label="Input your last name"
                aria-describedby="last-name"
              />
          </InputGroup>
        </Col>
      </Row>
      <InputGroup className="mb-3">
        <InputGroup.Text id='email'>
          Email
        </InputGroup.Text>
        <Form.Control
          aria-label="Input your email"
          aria-describedby="email"
        />
      </InputGroup>
    </>
  )
}

export default SettingsForm