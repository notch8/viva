import React from 'react'
import { Link } from '@inertiajs/inertia-react'

export default function Pagination({ metadata, filterParams = {} }) {
  if (!metadata || metadata.pages <= 1) return null

  const { page, pages, prev, next, count, limit } = metadata
  const itemsPerPage = limit || 10 // Fallback to 10 if limit is not provided
  const startItem = (page - 1) * itemsPerPage + 1
  const endItem = Math.min(page * itemsPerPage, count)

  const buildPageUrl = (pageNum) => {
    const params = new URLSearchParams()
    params.set('page', pageNum)

    // Add filter params to URL
    if (filterParams.search) {
      params.set('search', filterParams.search)
    }
    if (filterParams.selected_keywords?.length) {
      filterParams.selected_keywords.forEach(k => params.append('selected_keywords[]', k))
    }
    if (filterParams.selected_subjects?.length) {
      filterParams.selected_subjects.forEach(s => params.append('selected_subjects[]', s))
    }
    if (filterParams.selected_types?.length) {
      filterParams.selected_types.forEach(t => params.append('selected_types[]', t))
    }
    if (filterParams.selected_levels?.length) {
      filterParams.selected_levels.forEach(l => params.append('selected_levels[]', l))
    }
    if (filterParams.selected_users?.length) {
      filterParams.selected_users.forEach(u => params.append('selected_users[]', u))
    }
    if (filterParams.filter_my_questions) {
      params.set('filter_my_questions', 'true')
    }

    return `?${params.toString()}`
  }

  // Generate array of page numbers to display
  const getPageNumbers = () => {
    const delta = 2 // Pages to show on each side of current
    const range = []
    const rangeWithDots = []

    for (
      let i = Math.max(2, page - delta);
      i <= Math.min(pages - 1, page + delta);
      i++
    ) {
      range.push(i)
    }

    if (page - delta > 2) {
      rangeWithDots.push(1, '...')
    } else {
      rangeWithDots.push(1)
    }

    rangeWithDots.push(...range)

    if (page + delta < pages - 1) {
      rangeWithDots.push('...', pages)
    } else if (pages > 1) {
      rangeWithDots.push(pages)
    }

    return rangeWithDots
  }

  const pageNumbers = getPageNumbers()

  return (
    <div className='flex flex-col items-center gap-3 py-4'>
      <div className='text-sm text-gray-600 mb-3'>
        Showing <span className='font-medium'>{startItem}</span> to <span className='font-medium'>{endItem}</span> of <span className='font-medium'>{count}</span> results
      </div>
      <nav className='flex items-center justify-center gap-1' aria-label='Pagination'>
        {/* Previous Button */}
        {prev ? (
          <Link
            href={buildPageUrl(prev)}
            className='px-3 py-2 rounded border border-gray-300 text-decoration-none hover:bg-gray-50'
            preserveScroll
          >
          Previous
          </Link>
        ) : (
          <span className='px-3 py-2 rounded border border-gray-200 text-gray-400 cursor-not-allowed'>
          Previous
          </span>
        )}

        {/* {/* Page Numbers */}
        {pageNumbers.map((pageNum, index) => {
          if (pageNum === '...') {
            return (
              <span key={`ellipsis-${index}`} className='px-3 py-2'>
        …
              </span>
            )
          }

          const isActive = pageNum === page

          if (isActive) {
            return (
              <span
                key={pageNum}
                className='px-3 py-2 rounded border border-gray-900 bg-gray-100 font-semibold'
                aria-current='page'
              >
                {pageNum}
              </span>
            )
          }

          return (
            <Link
              key={pageNum}
              href={buildPageUrl(pageNum)}
              className='px-3 py-2 rounded border border-gray-300 text-decoration-none hover:bg-gray-50'
              preserveScroll
            >
              {pageNum}
            </Link>
          )
        })}

        {/* Next Button */}
        {next ? (
          <Link
            href={buildPageUrl(next)}
            className='px-3 py-2 rounded border border-gray-300 text-decoration-none hover:bg-gray-50'
            preserveScroll
          >
          Next
          </Link>
        ) : (
          <span className='px-3 py-2 rounded border border-gray-200 text-gray-400 cursor-not-allowed'>
          Next
          </span>
        )}
      </nav>
    </div>
  )
}