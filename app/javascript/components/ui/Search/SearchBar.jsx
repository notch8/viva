import React, { useState, useEffect } from 'react'
import {
  InputGroup, DropdownButton, Button, Container, Form
} from 'react-bootstrap'
import { MagnifyingGlass, XCircle } from '@phosphor-icons/react'
import { Inertia } from '@inertiajs/inertia'

const SearchBar = (props) => {
  const {
    subjects,
    keywords,
    types,
    levels,
    processing,
    selectedKeywords,
    selectedTypes,
    selectedSubjects,
    selectedLevels,
    bookmarkedQuestionIds,
    searchTerm
  } = props

  const filters = { subjects, keywords, types, levels }
  const [query, setQuery] = useState(searchTerm || '')
  const [filterState, setFilterState] = useState({
    selectedKeywords: selectedKeywords || [],
    selectedTypes: selectedTypes || [],
    selectedSubjects: selectedSubjects || [],
    selectedLevels: selectedLevels || []
  })
  const [hasBookmarks, setHasBookmarks] = useState(bookmarkedQuestionIds.length > 0)

  useEffect(() => {
    if (searchTerm !== undefined && searchTerm !== query) {
      setQuery(searchTerm)
    }
  }, [searchTerm])

  useEffect(() => {
    setHasBookmarks(bookmarkedQuestionIds.length > 0)
  }, [bookmarkedQuestionIds])

  const handleSearchChange = (event) => {
    setQuery(event.target.value)
  }

  const handleSearchSubmit = (event) => {
    event.preventDefault()
    console.log('Submitting with filters:', filterState)
    Inertia.get(window.location.pathname, {
      search: query,
      selected_keywords: filterState.selectedKeywords,
      selected_subjects: filterState.selectedSubjects,
      selected_types: filterState.selectedTypes,
      selected_levels: filterState.selectedLevels,
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
    Inertia.get(window.location.pathname, {
      search: '',
      selected_keywords: [],
      selected_subjects: [],
      selected_types: [],
      selected_levels: [],
    }, {
      preserveState: true,
      preserveScroll: true
    })
  }

  const handleFilterChange = (event, filterKey) => {
    const { value, checked } = event.target
    setFilterState((prevState) => {
      const updatedFilters = [...prevState[filterKey]]

      if (checked && !updatedFilters.includes(value)) {
        updatedFilters.push(value)
      } else if (!checked) {
        const index = updatedFilters.indexOf(value)
        if (index !== -1) {
          updatedFilters.splice(index, 1)
        }
      }

      return { ...prevState, [filterKey]: updatedFilters }
    })
  }

  const handleDeleteAllBookmarks = () => {
    Inertia.delete('/bookmarks/destroy_all', {
      onSuccess: () => {
        setHasBookmarks(false)
      },
      onError: () => {
        console.error('Failed to clear all bookmarks')
      }
    })
  }

  return (
    <Form onSubmit={handleSearchSubmit}>
      <Container className='p-0 mt-2 search-bar'>
        <InputGroup className='mb-3 flex-column flex-md-row'>
          {/* Search Input */}
          <Form.Control
            type='text'
            name='search'
            placeholder='search questions...'
            value={query}
            onChange={handleSearchChange}
            className='border border-light-4 text-black'
          />
          <Button
            className='d-flex align-items-center fs-6 justify-content-center'
            id='button-addon2'
            size='lg'
            type='submit'
            disabled={processing}
          >
            <span className='me-1'>Search</span>
            <MagnifyingGlass size={20} weight='bold' />
          </Button>
          {query && (
            <Button
              variant='outline-secondary'
              className='d-flex align-items-center fs-6 justify-content-center ms-2'
              size='lg'
              onClick={handleReset}
            >
              <span className='me-1'>Reset</span>
              <XCircle size={20} weight='bold' />
            </Button>
          )}
        </InputGroup>

        {/* Filters */}
        <InputGroup className='mb-3 flex-column flex-md-row'>
          {Object.keys(filters).map((key, index) => (
            <DropdownButton
              variant='outline-light-4 text-black fs-6 d-flex align-items-center justify-content-between'
              title={key.toUpperCase()}
              id={`input-group-dropdown-${index}`}
              size='lg'
              autoClose='outside'
              key={index}
            >
              {filters[key].map((item, itemIndex) => (
                <Form.Check
                  type='checkbox'
                  id={item}
                  className='p-2'
                  key={itemIndex}
                >
                  <Form.Check.Input
                    type='checkbox'
                    id={item}
                    className='mx-0'
                    value={item}
                    onChange={(event) => handleFilterChange(event, `selected${key.charAt(0).toUpperCase() + key.slice(1)}`)}
                    checked={filterState[`selected${key.charAt(0).toUpperCase() + key.slice(1)}`].includes(item)}
                  />
                  <Form.Check.Label className='ps-2'>{item}</Form.Check.Label>
                </Form.Check>
              ))}
            </DropdownButton>
          ))}

          {/* Bookmarks */}
          <DropdownButton
            variant='outline-light-4 text-black fs-6 d-flex align-items-center justify-content-between'
            title={`BOOKMARKS (${bookmarkedQuestionIds.length})`}
            id='input-group-dropdown-bookmark'
            size='lg'
            autoClose='outside'
          >
            <div className='d-flex flex-column align-items-start'>
              <a
                href='?bookmarked=true'
                className={`btn btn-primary p-2 m-2 ${!hasBookmarks ? 'disabled' : ''}`}
                role='button'
                aria-disabled={!hasBookmarks}
              >
                View Bookmarks
              </a>
              <a
                href={'.xml?bookmarked=true'}
                className={`btn btn-primary p-2 m-2 ${!hasBookmarks ? 'disabled' : ''}`}
                role='button'
                aria-disabled={!hasBookmarks}
              >
                Export Bookmarks
              </a>
              <Button
                variant='danger'
                className='p-2 m-2'
                onClick={handleDeleteAllBookmarks}
                disabled={!hasBookmarks}
              >
                Clear Bookmarks
              </Button>
            </div>
          </DropdownButton>
        </InputGroup>
      </Container>
    </Form>
  )
}

export default SearchBar
