import React from 'react'
import Layout from '../App'
import { useForm } from '@inertiajs/inertia-react'
import { Container, Row } from 'react-bootstrap'
import QuestionWrapper from '../ui/Question/QuestionWrapper'
import SearchBar from '../ui/Search/SearchBar'
import SearchFilters from '../ui/Search/SearchFilters'

const Search = (props) => {
  const { filteredQuestions, selectedCategories, selectedKeywords, selectedTypes, selectedLevels, categories, keywords, types, levels } = props
  const { setData, get, processing, errors, clearErrors, recentlySuccessful, data } = useForm({
    selected_keywords: selectedKeywords || [],
    selected_categories: selectedCategories || [],
    selected_types: selectedTypes || [],
    // TODO add selected levels once it is
    selected_levels: selectedLevels || [],
  })

  const handleFilters = (event, filterName) => {
    const { value, checked } = event.target
    const filterKey = `selected_${filterName}`

    setData((prevData) => {
      const updatedData = { ...prevData }
      const selectedArray = updatedData[filterKey] || []

      if (checked && !selectedArray.includes(value)) {
        selectedArray.push(value)
      } else if (!checked) {
        const index = selectedArray.indexOf(value)
        if (index !== -1) {
          selectedArray.splice(index, 1)
        }
      }

      updatedData[filterKey] = selectedArray
      return updatedData
    })
  }

  const submit = (e) => {
    clearErrors()
    e.preventDefault()
    get('/')
  }

  // console.log({filteredQuestions})
  return (
    <Layout>
      <SearchBar
        categories={categories}
        keywords={keywords}
        types={types}
        levels={levels}
        submit={submit}
        handleFilters={handleFilters}
        processing={processing}
        selectedCategories={selectedCategories || []}
        selectedKeywords={selectedKeywords || []}
        selectedTypes={selectedTypes || []}
        selectedLevels={selectedLevels || []}
      />
      <SearchFilters
        selectedCategories={selectedCategories || []}
        selectedKeywords={selectedKeywords || []}
        selectedTypes={selectedTypes || []}
        selectedLevels={selectedLevels || []}
        handleFilters={handleFilters}
        submit={submit}
      />
      {filteredQuestions.length ?
        (filteredQuestions.map((question) => {
          return (
            <QuestionWrapper
              key={question.id}
              question={question}
            />
          )
        })) : (
          <Container className='mt-5'>
            <Row>
              Your search returned no results. Try removing some filters and searching again.
            </Row>
          </Container>
        )
      }
    </Layout>
  )
}

export default Search
