import React from 'react'
import {
  Row, Col, Container, Button 
} from 'react-bootstrap'
import IncorrectAnswers from '../IncorrectAnswers/TwoColumnLayout'

const DragAndDropAnswers = ({ answers }) => {
  const correctAnswers = answers.filter(answer => answer.correct)
  const incorrectAnswers = answers.filter(answer => !answer.correct)

  return (
    <>
      <Container className='DragAndDropAnswers'>
        <Row className='bg-white rounded'>
          {correctAnswers.map((correctAnswer, index) => {
            return (
              <Col className='border-end correct-answer py-3' key={index}>
                <span>{correctAnswer.answer}</span>
              </Col>
            )
          })}
        </Row>
      </Container>
      {
        incorrectAnswers.length > 0 &&
        <IncorrectAnswers incorrectAnswers={incorrectAnswers} />
      }
    </>
  )
}

export default DragAndDropAnswers
