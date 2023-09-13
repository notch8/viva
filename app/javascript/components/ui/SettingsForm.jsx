

import React, { useState } from 'react'
import { useForm } from '@inertiajs/inertia-react'
import { Row, Col, InputGroup, Form, Button, Alert } from 'react-bootstrap'

const SettingsForm = ({ currentUser, notice }) => {
  const { data, setData, patch, processing, isDirty, errors } = useForm({
    first_name: currentUser.first_name || '',
    last_name: currentUser.last_name || '',
    title: currentUser.title || '',
    email: currentUser.email || '',
  })

  const [show, setShow] = useState(false)
  // const [validated, setValidated] = useState(false);

  const submit = (e) => {
    setShow(false)
    e.preventDefault()
    patch('/settings/update')
    if (isDirty && (errors.toString.length === 0)) {
      setShow(true)
    }
  }

  //console.log(errors)

  return (
    <>
      <Form onSubmit={submit}>
        <Row>
          <Col md={6}>
            <InputGroup className="mb-3">
              <InputGroup.Text id='first-name'>
                First Name
              </InputGroup.Text>
              <Form.Control
                aria-label="Input your first name"
                aria-describedby="first-name"
                value={data.first_name}
                onChange={e => setData('first_name', e.target.value)}
              />
              {errors.first_name &&
                <div className='text-danger small w-100 ms-2'>
                  Error: first_name {errors.first_name[0]}.
                </div>
              }
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
                  value={data.last_name}
                  onChange={e => setData('last_name', e.target.value)}
                />
                {errors.last_name &&
                  <div className='text-danger small w-100 ms-2'>
                    Error: last_name {errors.last_name[0]}.
                  </div>
                }
            </InputGroup>
          </Col>
        </Row>
        <Row>
          <Col md={6}>
            <InputGroup className="mb-3">
              <InputGroup.Text id='title'>
                Title
              </InputGroup.Text>
              <Form.Control
                aria-label="Input your title"
                aria-describedby="title"
                value={data.title}
                onChange={e => setData('title', e.target.value)}
              />
              { errors.title &&
                <div className='text-danger small w-100 ms-2'>
                  Error: title {errors.title[0]}.
                </div>
              }
            </InputGroup>
          </Col>
          <Col md={6}>
            <InputGroup className="mb-3">
              <InputGroup.Text id='email'>
                Email
              </InputGroup.Text>
              <Form.Control
                aria-label="Input your email"
                aria-describedby="email"
                value={data.email}
                onChange={e => setData('email', e.target.value)}
              />
              { errors.email &&
                <div className='text-danger small w-100 ms-2'>
                  Error: email {errors.email[0]}.
                </div>
              }
            </InputGroup>
          </Col>
        </Row>
        <Button type="submit" disabled={processing}>Save</Button>
      </Form>
      {show &&
        <Alert className='mt-3' variant="success" onClose={() => setShow(false)} dismissible>
          <p>Your information has been saved successfully.</p>
        </Alert>
      }
    </>
  )
}

export default SettingsForm