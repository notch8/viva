import React from 'react'
import { useForm } from '@inertiajs/inertia-react'
import {
  Row, Col, InputGroup, Form, Button, Alert
} from 'react-bootstrap'

const SettingsForm = ({ currentUser }) => {
  const { data, setData, patch, processing, errors, clearErrors, recentlySuccessful } = useForm({
    first_name: currentUser.first_name || '',
    last_name: currentUser.last_name || '',
    title: currentUser.title || '',
    email: currentUser.email || '',
  })

  const submit = (e) => {
    clearErrors()
    e.preventDefault()
    patch('/settings/update')
  }

  return (
    <>
      <Form onSubmit={submit}>
        <h3 className='pt-3 fw-semibold'>Settings</h3>
        <p>
          On this page, you can easily update your account information, including your email, first name, and last name. Simply click on the respective section, make your changes, and save them. Keeping your information up to date is important for account security and personalization.
        </p>
        <Row>
          <Col md={6}>
            <InputGroup className='mb-3'>
              <InputGroup.Text id='first-name'>
                First Name
              </InputGroup.Text>
              <Form.Control
                aria-label='Input your first name'
                aria-describedby='first-name'
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
            <InputGroup className='mb-3'>
              <InputGroup.Text id='last-name'>
                  Last Name
              </InputGroup.Text>
              <Form.Control
                aria-label='Input your last name'
                aria-describedby='last-name'
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
            <InputGroup className='mb-3'>
              <InputGroup.Text id='title'>
                Title
              </InputGroup.Text>
              <Form.Control
                aria-label='Input your title'
                aria-describedby='title'
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
            <InputGroup className='mb-3'>
              <InputGroup.Text id='email'>
                Email
              </InputGroup.Text>
              <Form.Control
                aria-label='Input your email'
                aria-describedby='email'
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
        <Button className='btn btn-primary d-block ms-auto' type='submit' disabled={processing}>Save</Button>
      </Form>
      {recentlySuccessful &&
        <Alert className='mt-3' variant='success'>
          <p>Your information has been saved successfully.</p>
        </Alert>
      }
    </>
  )
}

export default SettingsForm