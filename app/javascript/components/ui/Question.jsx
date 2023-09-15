import React from 'react'
import { Container } from 'react-bootstrap'

const Question = ({ text }) => {
  return (
    <Container fluid className=''>
      <h6>Question</h6>
      <p>{text}</p>
    </Container>
  )
}

export default Question
