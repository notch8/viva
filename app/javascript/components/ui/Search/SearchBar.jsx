import React, { useEffect } from 'react'
import {
  InputGroup, DropdownButton, Button, Container, Form
} from 'react-bootstrap'
import { MagnifyingGlass } from '@phosphor-icons/react'
import { setDropdownWidth } from '../../../utilities/dropdown-width'

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
    selectedLevels
  } = props
  const filters = { subjects, keywords, types, levels }

  useEffect(() => {
    const removeResizeListener = setDropdownWidth()
    return () => {
      removeResizeListener()
    }
  }, [])

  return (
    <Form onSubmit={submit}>
      <Container className='p-0 mt-2 search-bar'>
        <InputGroup className='mb-3 flex-column flex-md-row'>
          {/* props being passed to this component are each of the filters. the keys are the name of the filter, and the values are the list of items to filter by */}
          {Object.keys(filters).map((key, index) => (
            <DropdownButton
              key={index}
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
          ))}
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
