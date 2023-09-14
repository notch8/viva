import React, { useState } from 'react'
import { InputGroup, Form } from 'react-bootstrap'
import { Eye, EyeClosed } from '@phosphor-icons/react'

const PasswordInput = ({ id, errors, name, setData }) => {
  const [isVisible, setVisible] = useState(false)

  const toggle = () => {
    setVisible(!isVisible)
  }

  return (
    <InputGroup className='mb-3'>
      <InputGroup.Text id={id}>
        {name}
      </InputGroup.Text>
      <Form.Control
        type={isVisible ? 'text' : 'password'}
        aria-label={`Enter your ${name}`}
        aria-describedby={id}
        onChange={e => setData(id, e.target.value)}
      />
        <InputGroup.Text onClick={toggle}>
          {isVisible ? <Eye /> : <EyeClosed />}
        </InputGroup.Text>
      {errors[id] &&
        <div className='text-danger small w-100 ms-2'>
          Error: {name} {errors[id]}.
        </div>
      }
    </InputGroup>
  )
}

export default PasswordInput