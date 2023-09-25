import React from 'react'
import {
  Row, Col, Button, Badge
} from 'react-bootstrap'

const TraditionalAnswers = ({ answers }) => {
  return (
    answers && answers.map((answer, index) => {
      return (
        <Row className={`rounded m-1 p-1 d-flex align-items-center justify-content-center ${answer.correct ? 'correct' : ''}`} key={index}>
          <Col xs={2} lg={1} className='px-0'>
            <Button variant='primary' className='m-1'>{index}</Button>
          </Col>
          <Col xs={10} sm={7} lg={8}>
            <span>{answer.answer}</span>
          </Col>
          <Col sm={3} className='d-flex justify-content-center justify-content-md-end align-self-end ms-auto px-0'>
            {answer.correct &&
              <Badge bg='light' text='dark' className='ms-auto'>CORRECT</Badge>
            }
          </Col>
        </Row>
      )
    })
  )
}

export default TraditionalAnswers
