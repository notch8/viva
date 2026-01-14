import React, { useState, useEffect } from 'react'
import Layout from '../../App'
import { Container, Row, Col } from 'react-bootstrap'
import { Inertia } from '@inertiajs/inertia'
import { useForm } from '@inertiajs/inertia-react'
import QuestionWrapper from '../../ui/Question/QuestionWrapper'
import SearchBar from '../../ui/Search/SearchBar'
import SearchFilters from '../../ui/Search/SearchFilters'
import Pagination from '../../Pagination'

const Search = ({
  filteredQuestions,
  selectedSubjects,
  selectedKeywords,
  selectedTypes,
  selectedLevels,
  subjects,
  keywords,
  types,
  levels,
  bookmarkedQuestionIds,
  searchTerm,
  pagination,
  filterMyQuestions
}) => {

  const [query, setQuery] = useState(searchTerm || '')
  const [filterState, setFilterState] = useState({
    selectedKeywords: selectedKeywords || [],
    selectedTypes: selectedTypes || [],
    selectedSubjects: selectedSubjects || [],
    selectedLevels: selectedLevels || []
  })
  const [filterMyQuestionsState, setFilterMyQuestionsState] = useState(filterMyQuestions || false)

  // Update state when props change
  useEffect(() => {
    if (searchTerm !== undefined && searchTerm !== query) {
      setQuery(searchTerm)
    }

    setFilterState({
      selectedKeywords: selectedKeywords || [],
      selectedTypes: selectedTypes || [],
      selectedSubjects: selectedSubjects || [],
      selectedLevels: selectedLevels || []
    })

    if (filterMyQuestions !== undefined) {
      setFilterMyQuestionsState(filterMyQuestions)
    }
  }, [searchTerm, selectedKeywords, selectedTypes, selectedSubjects, selectedLevels, filterMyQuestions])

  const { processing, clearErrors } = useForm()

  const handleSearchChange = (event) => {
    setQuery(event.target.value)
  }

  const handleSearchSubmit = (event) => {
    if (event) event.preventDefault()
    clearErrors()

    Inertia.get('/', {
      search: query,
      selected_keywords: filterState.selectedKeywords,
      selected_subjects: filterState.selectedSubjects,
      selected_types: filterState.selectedTypes,
      selected_levels: filterState.selectedLevels,
      filter_my_questions: filterMyQuestionsState,
    }, {
      preserveState: true,
      preserveScroll: true
    })
  }

  const handleFilterChange = (event, filterKey) => {
    const { value, checked } = event.target

    const newFilterState = { ...filterState }
    const updatedFilters = [...newFilterState[filterKey]]

    if (checked && !updatedFilters.includes(value)) {
      updatedFilters.push(value)
    } else if (!checked) {
      const index = updatedFilters.indexOf(value)
      if (index !== -1) {
        updatedFilters.splice(index, 1)
      }
    }

    newFilterState[filterKey] = updatedFilters
    setFilterState(newFilterState)

    // Immediately trigger the search when new filters are selected
    Inertia.get('/', {
      search: query,
      selected_keywords: newFilterState.selectedKeywords,
      selected_subjects: newFilterState.selectedSubjects,
      selected_types: newFilterState.selectedTypes,
      selected_levels: newFilterState.selectedLevels,
      filter_my_questions: filterMyQuestionsState,
    }, {
      preserveState: true,
      preserveScroll: true
    })
  }

  // Removes a specific filter item and triggers a search
  // @param {string} item - The filter value to remove
  // @param {string} filterType - The type of filter ('Subjects', 'Types', or 'Levels')
  const removeFilterAndSearch = (item, filterType) => {
    // Create updated filter arrays
    let updatedKeywords = [...filterState.selectedKeywords]
    let updatedSubjects = [...filterState.selectedSubjects]
    let updatedTypes = [...filterState.selectedTypes]
    let updatedLevels = [...filterState.selectedLevels]

    // Remove the item from the appropriate array
    if (filterType === 'Subjects') {
      updatedSubjects = updatedSubjects.filter(subject => subject !== item)
    } else if (filterType === 'Keywords') {
      updatedKeywords = updatedKeywords.filter(keyword => keyword !== item)
    } else if (filterType === 'Types') {
      updatedTypes = updatedTypes.filter(type => type !== item)
    } else if (filterType === 'Levels') {
      updatedLevels = updatedLevels.filter(level => level !== item)
    }

    setFilterState({
      selectedKeywords: updatedKeywords,
      selectedSubjects: updatedSubjects,
      selectedTypes: updatedTypes,
      selectedLevels: updatedLevels
    })

    // Perform search with the updated values
    Inertia.get('/', {
      search: query,
      selected_keywords: updatedKeywords,
      selected_subjects: updatedSubjects,
      selected_types: updatedTypes,
      selected_levels: updatedLevels,
      filter_my_questions: filterMyQuestionsState,
    }, {
      preserveState: true,
      preserveScroll: true
    })
  }

  const handleReset = () => {
    setQuery('')
    setFilterState({
      selectedKeywords: [],
      selectedTypes: [],
      selectedSubjects: [],
      selectedLevels: []
    })
    setFilterMyQuestionsState(false)

    Inertia.get('/', {
      search: '',
      selected_keywords: [],
      selected_subjects: [],
      selected_types: [],
      selected_levels: [],
      filter_my_questions: false,
    }, {
      preserveState: true,
      preserveScroll: true
    })
  }

  // Handler for toggling "My Questions" filter
  const handleFilterMyQuestionsToggle = () => {
    const newValue = !filterMyQuestionsState
    setFilterMyQuestionsState(newValue)

    Inertia.get('/', {
      search: query,
      selected_keywords: filterState.selectedKeywords,
      selected_subjects: filterState.selectedSubjects,
      selected_types: filterState.selectedTypes,
      selected_levels: filterState.selectedLevels,
      filter_my_questions: newValue,
    }, {
      preserveState: true,
      preserveScroll: true
    })
  }

  const handleBookmarkBatch = () => {
    const filteredIds = filteredQuestions.map(question => question.id).join(',')
    Inertia.post('/bookmarks/create_batch', { filtered_ids: filteredIds }, {
      onSuccess: () => {
        console.log('Bookmarks added successfully')
      },
      onError: () => {
        console.error('Error adding bookmarks')
      }
    })
  }

  return (
    <Layout>
      <SearchBar
        subjects={subjects}
        keywords={keywords}
        types={types}
        levels={levels}
        processing={processing}
        query={query}
        onQueryChange={handleSearchChange}
        onSubmit={handleSearchSubmit}
        onReset={handleReset}
        onFilterChange={handleFilterChange}
        filterState={filterState}
        bookmarkedQuestionIds={bookmarkedQuestionIds || []}
        filterMyQuestions={filterMyQuestionsState}
        onFilterMyQuestionsToggle={handleFilterMyQuestionsToggle}
      />
      <SearchFilters
        selectedSubjects={filterState.selectedSubjects}
        selectedKeywords={filterState.selectedKeywords}
        selectedTypes={filterState.selectedTypes}
        selectedLevels={filterState.selectedLevels}
        removeFilterAndSearch={removeFilterAndSearch}
        onBookmarkBatch={handleBookmarkBatch}
      />
      {pagination && pagination.count !== undefined && (
        <Container className='mt-3 mb-2'>
          <Row>
            <Col className='px-0'>
              <p className='text-muted mb-0'>
                <strong>{pagination.count}</strong> result{pagination.count !== 1 ? 's' : ''} found
                {searchTerm && ` for "${searchTerm}"`}
              </p>
            </Col>
          </Row>
        </Container>
      )}
      {filteredQuestions.length ?
        (
          <>
            {filteredQuestions.map((question) => {
              return (
                <QuestionWrapper
                  key={question.id}
                  question={question}
                  bookmarkedQuestionIds={bookmarkedQuestionIds}
                />
              )
            })}
            <Container className='px-0 py-0'>
              <Pagination metadata={pagination} />
            </Container>
          </>
        ) : (
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
