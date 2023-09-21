import React, { useState } from 'react'
import {
  Collapse, Button, Container, Row, Col
} from 'react-bootstrap'
import { Plus, Minus } from '@phosphor-icons/react'
import Answers from '../Answers'
import Question from '.'
import QuestionMetadata from './QuestionMetadata'

const QuestionWrapper = ({ question }) => {
  const [open, setOpen] = useState(false)

  return (
    <Container className='bg-light-1 rounded container p-4 mt-3'>
      <Row>
        <Col md={7} className='p-2'>
          <Question text={question.text} />
          <Collapse in={open}>
            {/* The div id that corresponds to the "aria-controls" value on the Button must be in this same file.
                Otherwise, the collapse is expanded by default, and will not collapse either.
            */}
            <div id='question-answers'>
              <Answers question_type={question.type} answers={question.data} />
            </div>
          </Collapse>
        </Col>
        <Col md={4} className='px-0'>
          <QuestionMetadata question={question} />
        </Col>
        <Col sm={1} className='d-flex align-items-center justify-content-center'>
          <Button
            onClick={() => setOpen(!open)}
            aria-controls='question-answers'
            aria-expanded={open}
            className='mx-2 mt-2 rounded-circle d-flex px-1 py-1 bg-light-4 border-0'
          >
            { open ? <Minus size={20} weight='bold'  /> : <Plus size={20} weight='bold' /> }
          </Button>
        </Col>
      </Row>
    </Container>
  )
}

export default QuestionWrapper
