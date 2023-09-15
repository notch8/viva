import React from 'react'
import Layout from '../App'
import QuestionWrapper from '../ui/QuestionWrapper'
import SearchBar from '../ui/SearchBar'

const Search = (props) => {
    // console.log({...props})
    const { filtered_questions, categories, keywords, types, levels } = props
  return (
    <Layout>
      <SearchBar
        categories={categories}
        keywords={keywords}
        types={types}
        levels={[1, 2, 3]}
      />
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
