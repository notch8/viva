import React, { useState, useEffect } from 'react'
import {
  InputGroup,
  DropdownButton,
  Button,
  Container,
  Form
} from 'react-bootstrap'
import { MagnifyingGlass, XCircle } from '@phosphor-icons/react'
import { Inertia } from '@inertiajs/inertia'
import { ExportModal } from '../Export/ExportModal'

export const SearchBar = ({
  subjects,
  // keywords,
  types,
  levels,
  users,
  processing,
  query,
  onQueryChange,
  onSubmit,
  onReset,
  onFilterChange,
  filterState,
  bookmarkedQuestionIds,
  hasBookmarks,
  showExportModal,
  onDeleteAllBookmarks,
  onShowExportModal,
  onHideExportModal,
  lms,
  filterMyQuestions,
  onFilterMyQuestionsToggle,
  currentUser
}) => {
  // Build filters object with users first for admins, or regular filters for non-admins
  const filters = currentUser?.admin && users && users.length > 0
    ? { users, subjects, types, levels }
    : { subjects, types, levels }

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
          {(query ||
            filterState.selectedSubjects.length > 0 ||
            filterState.selectedTypes.length > 0 ||
            filterState.selectedLevels.length > 0 ||
            (filterState.selectedUsers && filterState.selectedUsers.length > 0) ||
            (!currentUser?.admin && filterMyQuestions)) && (
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
          {/* Filter My Questions Button - only show for non-admins */}
          {!currentUser?.admin && (
            <Button
              variant={filterMyQuestions ? 'primary' : 'outline-light-4'}
              className={`text-${filterMyQuestions ? 'white' : 'black'} fs-6 d-flex align-items-center justify-content-between`}
              size='lg'
              onClick={onFilterMyQuestionsToggle}
              style={{ minWidth: '180px' }}
            >
              <span>MY QUESTIONS</span>
              {filterMyQuestions && (
                <span className='ms-2'>✓</span>
              )}
            </Button>
          )}

          {Object.keys(filters).map((key, index) => (
            <DropdownButton
              variant='outline-light-4 text-black fs-6 d-flex align-items-center justify-content-between'
              title={key.toUpperCase()}
              id={`input-group-dropdown-${index}`}
              size='lg'
              autoClose='outside'
              key={index}
            >
              {filters[key].map((item, itemIndex) => {
                // For users, item is an object with id and email
                const filterKey = `selected${key.charAt(0).toUpperCase() + key.slice(1)}`
                const filterValue = key === 'users' ? String(item.id) : item

                // Extract display label logic for better readability
                const getDisplayLabel = () => {
                  if (key === 'users') return item.email
                  if (key === 'types' && item.startsWith('question_')) return item.substring(9)
                  return item
                }
                const displayLabel = getDisplayLabel()

                // Normalize selectedUsers array values to strings for comparison
                // (selectedUsers comes from URL params as strings, but item.id is a number)
                const selectedArray = filterState[filterKey] || []
                const normalizedSelected = key === 'users'
                  ? selectedArray.map(v => String(v))
                  : selectedArray
                const isChecked = normalizedSelected.includes(filterValue)

                return (
                  <Form.Check
                    type='checkbox'
                    id={key === 'users' ? `user-${item.id}` : item}
                    className='p-2'
                    key={itemIndex}
                  >
                    <Form.Check.Input
                      type='checkbox'
                      id={key === 'users' ? `user-${item.id}` : item}
                      className='mx-0'
                      value={filterValue}
                      onChange={(event) =>
                        onFilterChange(
                          event,
                          filterKey
                        )
                      }
                      checked={isChecked}
                    />
                    <Form.Check.Label className='ps-2'>
                      {displayLabel}
                    </Form.Check.Label>
                  </Form.Check>
                )
              })}
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
                className={`btn btn-primary p-2 m-2 ${
                  !hasBookmarks ? 'disabled' : ''
                }`}
                role='button'
                aria-disabled={!hasBookmarks}
              >
                View Bookmarks
              </a>
              <Button
                variant='danger'
                className='p-2 m-2'
                onClick={onDeleteAllBookmarks}
                disabled={!hasBookmarks}
              >
                Clear Bookmarks
              </Button>
              {hasBookmarks && (
                <Button
                  variant='secondary'
                  className='p-2 m-2'
                  onClick={onShowExportModal}
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
        onHide={onHideExportModal}
        hasBookmarks={hasBookmarks}
        lms={lms}
      />
    </Form>
  )
}

// Container component - handles state, effects, and API calls
const SearchBarWithState = (props) => {
  const [hasBookmarks, setHasBookmarks] = useState(
    props.bookmarkedQuestionIds.length > 0
  )
  const [showExportModal, setShowExportModal] = useState(false)

  // Update bookmark state when props change
  useEffect(() => {
    setHasBookmarks(props.bookmarkedQuestionIds.length > 0)
  }, [props.bookmarkedQuestionIds])

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
    <SearchBar
      {...props}
      hasBookmarks={hasBookmarks}
      showExportModal={showExportModal}
      onDeleteAllBookmarks={handleDeleteAllBookmarks}
      onShowExportModal={() => setShowExportModal(true)}
      onHideExportModal={() => setShowExportModal(false)}
      lms={props.lms}
      filterMyQuestions={props.filterMyQuestions}
      onFilterMyQuestionsToggle={props.onFilterMyQuestionsToggle}
      users={props.users}
      currentUser={props.currentUser}
    />
  )
}

export default SearchBarWithState
