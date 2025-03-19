import React, { useState, useEffect } from 'react'
import {
  InputGroup, DropdownButton, Button, Container, Form
} from 'react-bootstrap'
import { MagnifyingGlass, XCircle } from '@phosphor-icons/react'
import { Inertia } from '@inertiajs/inertia'
import ExportModal from '../Export/ExportModal'

const SearchBar = ({
  subjects,
  // keywords,
  types,
  levels,
  processing,
  query,
  onQueryChange,
  onSubmit,
  onReset,
  onFilterChange,
  filterState,
  bookmarkedQuestionIds
}) => {
  const filters = { subjects, types, levels }
  const [hasBookmarks, setHasBookmarks] = useState(bookmarkedQuestionIds.length > 0)
  const [showExportModal, setShowExportModal] = useState(false)

  // Update bookmark state when props change
  useEffect(() => {
    setHasBookmarks(bookmarkedQuestionIds.length > 0)
  }, [bookmarkedQuestionIds])

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
    <Form onSubmit={onSubmit}>
      <Container className='p-0 mt-2 search-bar'>
        <InputGroup className='mb-3 flex-column flex-md-row'>
          {/* Search Input */}
          <Form.Control
            type='text'
            name='search'
            placeholder='Search questions...'
            value={query}
            onChange={onQueryChange}
            className='border border-light-4 text-black'
          />
          <Button
            className='d-flex align-items-center fs-6 justify-content-center'
            id='button-addon2'
            size='lg'
            type='submit'
            disabled={processing}
          >
            <span className='me-1'>Apply Search Terms</span>
            <MagnifyingGlass size={20} weight='bold' />
          </Button>
          {(query || filterState.selectedSubjects.length > 0 || filterState.selectedTypes.length > 0 || filterState.selectedLevels.length > 0) && (
            <Button
              variant='secondary'
              className='d-flex align-items-center fs-6 justify-content-center text-white'
              size='lg'
              onClick={onReset}
            >
              <span className='me-1'>Reset All Filters</span>
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
                    onChange={(event) => onFilterChange(event, `selected${key.charAt(0).toUpperCase() + key.slice(1)}`)}
                    checked={filterState[`selected${key.charAt(0).toUpperCase() + key.slice(1)}`].includes(item)}
                  />
                  <Form.Check.Label className='ps-2'>
                    {key === 'types' && item.startsWith('question_') ? item.substring(9) : item}
                  </Form.Check.Label>
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
              <Button
                variant='danger'
                className='p-2 m-2'
                onClick={handleDeleteAllBookmarks}
                disabled={!hasBookmarks}
              >
                Clear Bookmarks
              </Button>
              {hasBookmarks && (
                <Button
                  variant='secondary'
                  className='p-2 m-2'
                  onClick={() => setShowExportModal(true)}
                >
                  Export Options
                </Button>
              )}
            </div>
          </DropdownButton>
        </InputGroup>
      </Container>
      <ExportModal
        show={showExportModal}
        onHide={() => setShowExportModal(false)}
        hasBookmarks={hasBookmarks}
      />
    </Form>
  )
}

export default SearchBar
