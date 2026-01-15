import React, { useState, useEffect } from 'react'
import { Button, Col } from 'react-bootstrap'
import { Inertia } from '@inertiajs/inertia'
import { usePage } from '@inertiajs/inertia-react'
import QuestionEditModal from './QuestionEditModal'
//  modal for editing questions
import { ChatText } from '@phosphor-icons/react'
import FeedbackModal from './FeedbackModal'

const QuestionMetadata = ({ question, bookmarkedQuestionIds, subjects }) => {
  const { props } = usePage()
  const { currentUser } = props
  const [isBookmarked, setIsBookmarked] = useState(
    bookmarkedQuestionIds.includes(question.id)
  )
  const [showEditModal, setShowEditModal] = useState(false)
  const [showFeedbackModal, setShowFeedbackModal] = useState(false)

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
      Inertia.post(
        '/bookmarks',
        { question_id: question.id },
        {
          onSuccess: () => {
            setIsBookmarked(true)
          },
          onError: () => {
            console.error('Error adding bookmark')
          }
        }
      )
    }
  }

  const handleDelete = () => {
    if (confirm('Are you sure you want to delete this question?')) {
      Inertia.delete(`/api/questions/${question.id}`, {
        onSuccess: () => {
          alert('Question deleted successfully')
        },
        onError: () => {
          console.error('Error deleting question')
        }
      })
    }
  }

  const handleFeedback = () => {
    setShowFeedbackModal(true)
  }

  const handleEdit = () => {
    setShowEditModal(true)
  }

  return (
    <div className='bg-light-2 p-2 rounded'>
      <button
        className='btn btn-primary mt-1 mb-4'
        onClick={handleBookmarkToggle}
      >
        {isBookmarked ? 'Unbookmark' : 'Bookmark'}
      </button>{' '}
      {(currentUser.id === question.user_id || currentUser.admin) && (
        <button className='btn btn-danger mt-1 mb-4' onClick={handleDelete}>
          Delete
        </button>
      )}{' '}
      {(currentUser.id === question.user_id || currentUser.admin) && (
        <button className='btn btn-secondary mt-1 mb-4' onClick={handleEdit}>
          Edit
        </button>
      )}
      <QuestionEditModal
        show={showEditModal}
        onClose={() => setShowEditModal(false)}
        question={question}
        subjects={subjects}
      />
      {/* NOTE: Keywords were removed to avoid consistency issues with manually added keywords */}
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
      {question.subject_names && (
        <>
          <h6 className='fw-bold pt-3'>Subject</h6>
          {question.subject_names.map((subject, index) => (
            <div
              className='m-1 badge badge-light text-dark bg-white'
              key={index}
            >
              {subject}
            </div>
          ))}
        </>
      )}
      <div className='d-flex mx-1 text-center mt-5 mb-2'>
        <Col className='bg-white rounded-start p-2'>
          <h6 className='fw-bold'>Level</h6>
          <span className='strait small'>{question.level}</span>
        </Col>
        <Col className='bg-light-3 rounded-end p-2'>
          <h6 className='fw-bold'>Type</h6>
          <span className='strait small'>{question.type_name}</span>
        </Col>
      </div>
      <div className='d-flex justify-content-between align-items-center text-muted'>
        <small className='ps-1'>Question ID: {question.hashid}</small>
        <Button
          className='me-2 d-flex align-items-center btn btn-secondary btn-sm'
          onClick={handleFeedback}
        >
          <ChatText size={24} weight='bold' className='me-1' />
          <span>Provide Feedback</span>
        </Button>
      </div>
      <FeedbackModal
        show={showFeedbackModal}
        onClose={() => setShowFeedbackModal(false)}
        question={question}
      />
    </div>
  )
}

export default QuestionMetadata
