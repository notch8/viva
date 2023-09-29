import React from 'react'
import { Table } from 'react-bootstrap'

const MatchingAnswers = ({ answers }) => {
  return (
    <Table bordered className='bg-white'>
      <tbody>
        {answers.map((answer, index) => {
          console.log(answer)
          return (
            <tr className='matching-table-row' key={index}>
              <td className='px-3 text-primary fw-semibold matchee align-middle text-center'>{answer.answer}</td>
              <td className='p-0 d-flex flex-column matcher'>
                {answer.correct && answer.correct.map((match, index) => (
                  <span className='px-3 py-2' key={match + index}>{match}</span>
                ))}
              </td>
            </tr>
          )
        })}
      </tbody>
    </Table>
  )
}

export default MatchingAnswers
