import React from 'react'
import Layout from '../App'
import QuestionWrapper from '../ui/QuestionWrapper'

const Search = (props) => {
    console.log({...props})
    const { filtered_questions } = props
  return (
    <Layout>
      {filtered_questions.map((question) => {
        return (
          <QuestionWrapper
            key={question.id}
            question={question}
          />
        )
      })}
    </Layout>
  )
}

export default Search
