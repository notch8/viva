

import React from 'react'
import { InputGroup, Form, Button, Alert } from 'react-bootstrap'
import { useForm } from '@inertiajs/inertia-react'

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
        <InputGroup className="mb-3">
          <InputGroup.Text id='current-password'>
            Current Password
          </InputGroup.Text>
          <Form.Control
            aria-label="Enter your current password"
            aria-describedby="current-password"
            onChange={e => setData('current_password', e.target.value)}
          />
          {errors.current_password &&
            <div className='text-danger small w-100 ms-2'>
              Error: current password {errors.current_password[0]}.
            </div>
          }
        </InputGroup>
        <InputGroup className="mb-3">
          <InputGroup.Text id='password'>
            New Password
          </InputGroup.Text>
          <Form.Control
            aria-label="Input your New Password"
            aria-describedby="password"
            onChange={e => setData('password', e.target.value)}
          />
          {errors.password &&
            <div className='text-danger small w-100 ms-2'>
              Error: new password {errors.password[0]}.
            </div>
          }
        </InputGroup>
        <InputGroup className="mb-3">
          <InputGroup.Text id='password_confirmation'>
            Confirm New Password
          </InputGroup.Text>
          <Form.Control
            aria-label="Re-enter your new password"
            aria-describedby="password_confirmation"
            onChange={e => setData('password_confirmation', e.target.value)}
          />
          {errors.password_confirmation &&
            <div className='text-danger small w-100 ms-2'>
              Error: password confirmation {errors.password_confirmation[0]}.
            </div>
          }
        </InputGroup>
        <Button type="submit" disabled={processing}>Save</Button>
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