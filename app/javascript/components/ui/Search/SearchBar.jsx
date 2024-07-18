import React, { useState, useEffect } from 'react'
import {
  InputGroup, DropdownButton, Button, Container, Form, Dropdown
} from 'react-bootstrap'
import { MagnifyingGlass } from '@phosphor-icons/react'
import CustomDropdown from '../../ui/CustomDropdown'
import { Inertia } from '@inertiajs/inertia'

const SearchBar = (props) => {
  const {
    subjects,
    keywords,
    types,
    levels,
    submit,
    handleFilters,
    processing,
    selectedKeywords,
    selectedTypes,
    selectedSubjects,
    selectedLevels,
    bookmarkedQuestionIds
  } = props
  const filters = { subjects, keywords, types, levels }
  const [hasBookmarks, setHasBookmarks] = useState(bookmarkedQuestionIds.length > 0)

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
      },
    })
  }

  const handleExportBookmarks = () => {
    const queryString = bookmarkedQuestionIds.map(id => `bookmarked_question_ids[]=${encodeURIComponent(id)}`).join('&')
    const url = `/.xml?${queryString}`
    window.location.href = url
  }

  return (
    <Form onSubmit={submit}>
      <Container className='p-0 mt-2 search-bar'>
        <InputGroup className='mb-3 flex-column flex-md-row'>
          {/* props being passed to this component are each of the filters. the keys are the name of the filter, and the values are the list of items to filter by */}
          {Object.keys(filters).map((key, index) => (
            <CustomDropdown key={index} dropdownSelector='.dropdown-toggle'>
              <DropdownButton
                variant='outline-light-4 text-black fs-6 d-flex align-items-center justify-content-between'
                title={key}
                id={`input-group-dropdown-${index}`}
                size='lg'
                autoClose='outside'
              >
                {filters[key].map((item, itemIndex) => (
                  <Form.Check type='checkbox' id={item} className='p-2' key={itemIndex}>
                    <Form.Check.Input
                      type='checkbox'
                      id={item}
                      className='mx-0'
                      value={item}
                      onChange={(event) => handleFilters(event, key)}
                      defaultChecked={selectedSubjects.includes(item) || selectedKeywords.includes(item) || selectedTypes.includes(item) || selectedLevels.includes(item)}
                    />
                    <Form.Check.Label className='ps-2'>
                      {filters[key] === 'types' ? item.substring(10) : item}
                    </Form.Check.Label>
                  </Form.Check>
                )
                )}
              </DropdownButton>
            </CustomDropdown>
          ))}
          <CustomDropdown key='bookmark' dropdownSelector='.dropdown-toggle'>
            <DropdownButton
              variant='outline-light-4 text-black fs-6 d-flex align-items-center justify-content-between'
              title='Bookmarks'
              id='input-group-dropdown-bookmark'
              size='lg'
              autoClose='outside'
            >
              <Button
                variant='primary'
                className='p-2 m-2 mt-3'
                onClick={handleExportBookmarks}
                disabled={!hasBookmarks}
              >
                Export {bookmarkedQuestionIds.length > 0 ? bookmarkedQuestionIds.length : ''} Bookmark{bookmarkedQuestionIds.length > 1 || bookmarkedQuestionIds.length === 0 ? 's' : ''}
              </Button>
              <Dropdown.Divider />
              <Button
                variant='danger'
                className='p-2 m-2 mb-3'
                onClick={handleDeleteAllBookmarks}
                disabled={!hasBookmarks}
              >
                Clear Bookmarks
              </Button>
            </DropdownButton>
          </CustomDropdown>
          <Button
            className='d-flex align-items-center fs-6 justify-content-center'
            id='button-addon2'
            size='lg'
            type='submit'
            disabled={processing}
          >
            <span className='me-1'>Search</span>
            <MagnifyingGlass size={20} weight='bold'/>
          </Button>
        </InputGroup>
      </Container>
    </Form>
  )
}

export default SearchBar
