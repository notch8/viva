import React from 'react'
import {
  Table, Col, Row, Container
} from 'react-bootstrap'

const ThreeColumnTable = ({ incorrectAnswers }) => {
  return (
    <div className='incorrect-question-answers mt-3'>
      <h4 className='h6 fw-bold'>Incorrect Answers</h4>
      <Container className='pt-2'>
        <Row className='bg-white rounded'>
          {incorrectAnswers.map((incorrectAnswer, index) => (
            <Col className='p-0' key={incorrectAnswer.label}>
              <Table striped bordered hover className='mb-0' >
                <thead>
                  <tr>
                    <th className='p-1 text-center'>
                      {incorrectAnswer.label}
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {incorrectAnswer.answers.map((answer, index) => (
                    <tr key={index}>
                      <td>
                        {answer.answer}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </Table>
            </Col>
          )
          )}
        </Row>
      </Container>
    </div>
  )
}

export default ThreeColumnTable
