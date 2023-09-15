import React from 'react'
import { Container } from 'react-bootstrap'

const IncorrectAnswers = ({ incorrect_answers }) => {
  return (
    <Container fluid className=''>
      <h6>Incorrect Answers</h6>
      {incorrect_answers.map((answer, index) => {
        // TODO: display the incorect answers
      })}
    </Container>
  )
}

export default IncorrectAnswers
