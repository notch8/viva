import React from 'react'
import Layout from '../../App'
import { useForm } from '@inertiajs/inertia-react'
import { Container, Row } from 'react-bootstrap'
import QuestionWrapper from '../../ui/Question/QuestionWrapper'
import SearchBar from '../../ui/Search/SearchBar'
import SearchFilters from '../../ui/Search/SearchFilters'

const Search = (props) => {
  const { filteredQuestions, selectedSubjects, selectedKeywords, selectedTypes, selectedLevels, subjects, keywords, types, levels, exportHrefs, bookmarkedQuestionIds } = props
  const { setData, get, processing, clearErrors } = useForm({
    selected_keywords: selectedKeywords || [],
    selected_subjects: selectedSubjects || [],
    selected_types: selectedTypes || [],
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

  return (
    <Layout>
      <SearchBar
        subjects={subjects}
        keywords={keywords}
        types={types}
        levels={levels}
        submit={submit}
        handleFilters={handleFilters}
        processing={processing}
        selectedSubjects={selectedSubjects || []}
        selectedKeywords={selectedKeywords || []}
        selectedTypes={selectedTypes || []}
        selectedLevels={selectedLevels || []}
        bookmarkedQuestionIds={bookmarkedQuestionIds || []}
      />
      <SearchFilters
        selectedSubjects={selectedSubjects || []}
        selectedKeywords={selectedKeywords || []}
        selectedTypes={selectedTypes || []}
        selectedLevels={selectedLevels || []}
        handleFilters={handleFilters}
        submit={submit}
        exportHrefs={exportHrefs}
      />
      {filteredQuestions.length ?
        (filteredQuestions.map((question) => {
          return (
            <QuestionWrapper
              key={question.id}
              question={question}
              bookmarkedQuestionIds={bookmarkedQuestionIds}
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
