import React from 'react'
import BowTieAnswers from './BowTieAnswers'
import DragAndDropAnswers from './DragAndDropAnswers'
import MatchingAnswers from './MatchingAnswers'
import StimulusCaseStudyAnswers from './StimulusCaseStudyAnswers'
import { Row, Col, Button, Badge } from 'react-bootstrap'

const Answers = ({ question_type, answers }) => {
  return (
    <>
      <h3 className='h6 fw-bold default-answers'>Answers</h3>
      {question_type === 'Question::BowTie' && <BowTieAnswers answers={answers} />}
      {question_type === 'Question::DragAndDrop' && <DragAndDropAnswers answers={answers} />}
      {question_type === 'Question::Matching' && <MatchingAnswers answers={answers} />}
      {question_type === 'Question::StimulusCaseStudy' && <StimulusCaseStudyAnswers answers={answers} />}

      {/* All other question types use the same format */}
      {answers.map((answer, index) => {
        console.log({ answer, index })
        return (
          <Row className={`rounded m-1 p-1 d-flex align-items-center justify-content-center ${answer.correct ? "correct" : ""}`}>
            <Col sm={2}>
              <Button variant="primary" className="m-1">{index}</Button>
            </Col>
            <Col sm={10}>
              <span>{answer.text}</span>
            </Col>
            <Col sm={2} className="align-self-end ms-auto">
              {answer.correct &&
                <Badge bg="light" text="dark" className="ms-auto">CORRECT</Badge>
              }
            </Col>
          </Row>
        )
      })}
    </>
  )
}

export default Answers
