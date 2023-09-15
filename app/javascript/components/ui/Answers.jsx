import React from 'react'
import { Container } from 'react-bootstrap'

const Answers = ({ question_type, answers }) => {
  console.log({ question_type, answers })

  return (
    <Container fluid className=''>
      <h6>Answers</h6>
      {question_type === 'Question::BowTie' &&
        answers.map((answer, index) => {
          // TODO: display the answers
        })
      }
      {question_type === 'Question::Matching' &&
        answers.map((answer, index) => {
          // TODO: display the answers. potentially using <ListGroup> from react-bootstrap
        })
      }
      {question_type === 'Question::DragAndDrop' &&
        answers.map((answer, index) => {
          // TODO: display the answers
        })
      }

      {/* All other question types use the same format */}
      {answers.map((answer, index) => {
        console.log({ answer, index })
        // TODO: display the answers
        return <p>{answer}</p>
      })}
    </Container>
  )
}

export default Answers
