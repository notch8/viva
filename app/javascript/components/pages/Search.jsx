import React from 'react'
import Layout from '../App'
import { useForm } from '@inertiajs/inertia-react'
import QuestionWrapper from '../ui/Question/QuestionWrapper'
import SearchBar from '../ui/Search/SearchBar'
import SearchFilters from '../ui/Search/SearchFilters'

const Search = (props) => {
  const { filtered_questions, categories, keywords, types, levels } = props
  const { setData, get, processing, errors, clearErrors, recentlySuccessful, data } = useForm({
    selected_keywords: [],
    selected_categories: [],
    selected_types: [],
    selected_levels: [],
  })

  const handleCheck = (event, filter_name) => {
    console.log({filter_name})
    let filter = `selected_${filter_name}`
    var selected_array = [...data[filter]];
    if (event.target.checked) {
      selected_array = [...data[filter], event.target.value];
    } else {
      selected_array.splice(...data[filter].indexOf(event.target.value), 1);
    }
    console.log(selected_array)
    setData(filter, selected_array)
  }

  const submit = (e) => {
    clearErrors()
    e.preventDefault()
    get('/')
  }

  console.log(filtered_questions)
  return (
    <Layout>
      <SearchBar
        categories={categories}
        keywords={keywords}
        types={types}
        levels={levels}
        submit={submit}
        handleCheck={handleCheck}
        processing={processing}
      />
      <SearchFilters
        data={data}
      />
      {filtered_questions && filtered_questions.map((question) => {
          return (
            <QuestionWrapper
              key={question.id}
              question={question}
            />
          )
        })
      }
    </Layout>
  )
}

export default Search
