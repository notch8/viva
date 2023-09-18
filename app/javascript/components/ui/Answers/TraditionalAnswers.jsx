import React from 'react'
import { Row, Col, Button, Badge } from 'react-bootstrap'

const TraditionalAnswers = ({ answers }) => {
  return (
    answers.map((answer, index) => {
      console.log({ answer, index })
      return (
        <Row className={`rounded m-1 p-1 d-flex align-items-center justify-content-center ${answer.correct ? "correct" : ""}`}>
          <Col sm={2}>
            <Button variant="primary" className="m-1">{index}</Button>
          </Col>
          <Col sm={10}>
            <span>{answer.answer}</span>
          </Col>
          <Col sm={2} className="align-self-end ms-auto">
            {answer.correct &&
              <Badge bg="light" text="dark" className="ms-auto">CORRECT</Badge>
            }
          </Col>
        </Row>
      )
    })
  )
}

export default TraditionalAnswers
