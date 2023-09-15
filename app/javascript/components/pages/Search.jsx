import React from 'react'
import Layout from '../App'
import QuestionWrapper from '../ui/QuestionWrapper'

const Search = ({ filtered_questions }) => {
  console.log({ filtered_questions })

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
