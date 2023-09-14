

import React from 'react'
import { Form, Button, Alert, Col } from 'react-bootstrap'
import { useForm } from '@inertiajs/inertia-react'
import PasswordInput from './PasswordInput'

const PasswordForm = () => {
  const { setData, patch, processing, errors, clearErrors, recentlySuccessful } = useForm({
    current_password: '',
    password: '',
    password_confirmation: ''
  })

  const submit = (e) => {
    clearErrors()
    e.preventDefault()
    patch('/settings/update-password')
  }

  return (
    <>
      <Form onSubmit={submit}>
        <h3 className='pt-3 fw-semibold'>Update Your Password</h3>
        <p>
          Ensuring a secure password is essential for protecting your account. Your password must be at least 8 characters long. Remember to use a combination of uppercase and lowercase letters, numbers, and symbols for added security.
        </p>
        <Col md={8}>
          <PasswordInput
            id='current_password'
            errors={errors}
            name='current password'
            setData={setData}
          />
          <PasswordInput
            id='password'
            errors={errors}
            name='password'
            setData={setData}
          />
          <PasswordInput
            id='password_confirmation'
            errors={errors}
            name='password confirmation'
            setData={setData}
          />
        </Col>
        <Button type="submit" disabled={processing} className='btn btn-primary d-block ms-auto' >Save</Button>
      </Form>
      {recentlySuccessful &&
        <Alert className='mt-3' variant="success">
          <p>Your new password has been saved successfully.</p>
        </Alert>
      }
    </>
  )
}

export default PasswordForm