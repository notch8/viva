import React, { useState, useEffect } from 'react'
import { Col } from 'react-bootstrap'
import { Inertia } from '@inertiajs/inertia'

const QuestionMetadata = ({ question, bookmarkedQuestionIds }) => {
  const [isBookmarked, setIsBookmarked] = useState(bookmarkedQuestionIds.includes(question.id))

  useEffect(() => {
    setIsBookmarked(bookmarkedQuestionIds.includes(question.id))
  }, [bookmarkedQuestionIds])

  const handleBookmarkToggle = () => {
    if (isBookmarked) {
      Inertia.delete(`/bookmarks/${question.id}`, {
        onSuccess: () => {
          setIsBookmarked(false)
        },
        onError: () => {
          console.error('Error removing bookmark')
        }
      })
    } else {
      Inertia.post('/bookmarks', { question_id: question.id }, {
        onSuccess: () => {
          setIsBookmarked(true)
        },
        onError: () => {
          console.error('Error adding bookmark')
        }
      })
    }
  }

  return (
    <div className='bg-light-2 p-2 rounded'>
      <button className='btn btn-primary mt-1 mb-4' onClick={handleBookmarkToggle}>
        {isBookmarked ? 'Unbookmark' : 'Bookmark'}
      </button>
      {/* {question.keyword_names &&
        <>
          <h6 className='fw-bold'>Keywords</h6>
          {question.keyword_names.map((keyword, index) => (
            <div
              className='m-1 btn bg-white text-lowercase'
              key={index}
            >
              {keyword}
            </div>
          ))}
        </>
      } */}
      {question.subject_names &&
        <>
          <h6 className='fw-bold pt-3'>Subject</h6>
          {question.subject_names.map((subject, index) => (
            <div
              className='m-1 btn bg-white text-lowercase'
              key={index}
            >
              {subject}
            </div>
          ))}
        </>
      }
      <div className='d-flex mx-1 text-center mt-5'>
        <Col className='bg-white rounded-start p-2'>
          <h6 className='fw-bold'>Level</h6>
          <span className='strait small'>{question.level}</span>
        </Col>
        <Col className='bg-light-3 rounded-end p-2'>
          <h6 className='fw-bold'>Type</h6>
          <span className='strait small'>{question.type_name}</span>
        </Col>
      </div>
    </div>
  )
}

export default QuestionMetadata
