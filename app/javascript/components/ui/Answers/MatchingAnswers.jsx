import React from 'react'
import { Table } from 'react-bootstrap'

const MatchingAnswers = ({ answers }) => {
  return (
    <Table bordered className="bg-white">
      <tbody>
        { answers.map((answer, index) => {
          return (
            <tr key={index}>
              <td className="px-3 text-primary fw-semibold">{answer.answer}</td>
              <td className="px-3">{answer.correct}</td>
            </tr>
          )
        })}
      </tbody>
    </Table>
  )
}

export default MatchingAnswers
