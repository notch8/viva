import React from 'react'

const EssayAnswers = ({ answers }) => {
  return (
    <div dangerouslySetInnerHTML={{__html: answers.html}} />
  )
}

export default EssayAnswers
