import React, { useState } from 'react'
import {
  Container, Row, Col, Card, Button, Form, Alert
} from 'react-bootstrap'
import Layout from '../../App'

const Analytics = () => {
  const [selectedReport, setSelectedReport] = useState('assessment')
  const [dateError, setDateError] = useState('')
  const [processing, setProcessing] = useState(false)
  const [showSuccess, setShowSuccess] = useState(false)
  const [data, setData] = useState({
    report_type: 'assessment',
    date_range: 'last_7_days',
    start_date: '',
    end_date: ''
  })

  const handleReportChange = (reportType) => {
    setSelectedReport(reportType)
    setData(prev => ({ ...prev, report_type: reportType }))
    setDateError('')
  }

  const validateDateRange = () => {
    if (data.date_range === 'custom') {
      if (!data.start_date || !data.end_date) {
        setDateError('Please select both start and end dates.')
        return false
      }

      const startDate = new Date(data.start_date)
      const endDate = new Date(data.end_date)

      if (endDate < startDate) {
        setDateError('End date cannot be before start date.')
        return false
      }
    }

    setDateError('')
    return true
  }

  const handleSubmit = async (e) => {
    e.preventDefault()

    if (!validateDateRange()) {
      return
    }

    setProcessing(true)
    setShowSuccess(false)

    try {
      const formData = new FormData()
      formData.append('report_type', data.report_type)
      formData.append('date_range', data.date_range)
      if (data.start_date) formData.append('start_date', data.start_date)
      if (data.end_date) formData.append('end_date', data.end_date)

      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')
      const response = await fetch('/analytics/export', {
        method: 'POST',
        headers: {
          'X-CSRF-Token': csrfToken || '',
          'X-Requested-With': 'XMLHttpRequest'
        },
        credentials: 'same-origin',
        body: formData
      })

      if (!response.ok) {
        throw new Error('Export failed')
      }

      // Get the blob and trigger download
      const blob = await response.blob()
      const url = window.URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = 'user_report.csv'
      document.body.appendChild(a)
      a.click()
      window.URL.revokeObjectURL(url)
      document.body.removeChild(a)

      setShowSuccess(true)
      setTimeout(() => setShowSuccess(false), 5000)
    } catch (error) {
      console.error('Export error:', error)
    } finally {
      setProcessing(false)
    }
  }

  return (
    <Layout>
      <Container className='bg-light-1 rounded p-5'>
        <h2 className='h5 fw-bold mb-4'>Analytics</h2>

        <Row className='mb-4'>
          <Col md={4} className='mb-3 mb-md-0'>
            <Card
              className={`h-100 cursor-pointer ${selectedReport === 'assessment' ? 'border-primary' : ''}`}
              onClick={() => handleReportChange('assessment')}
              style={{ cursor: 'pointer' }}
            >
              <Card.Body>
                <Card.Title className='h6'>Assessment Report</Card.Title>
                <Card.Text className='small text-muted'>
                  Question ID, Subject(s), Creator Email, Date Created, Date Last Edited
                </Card.Text>
              </Card.Body>
            </Card>
          </Col>

          <Col md={4} className='mb-3 mb-md-0'>
            <Card
              className={`h-100 cursor-pointer ${selectedReport === 'user' ? 'border-primary' : ''}`}
              onClick={() => handleReportChange('user')}
              style={{ cursor: 'pointer' }}
            >
              <Card.Body>
                <Card.Title className='h6'>User Report</Card.Title>
                <Card.Text className='small text-muted'>
                  User Email, Date Created, Role, Last Login, Questions Created Count, Questions Exported Count
                </Card.Text>
              </Card.Body>
            </Card>
          </Col>

          <Col md={4}>
            <Card
              className={`h-100 cursor-pointer ${selectedReport === 'utilization' ? 'border-primary' : ''}`}
              onClick={() => handleReportChange('utilization')}
              style={{ cursor: 'pointer' }}
            >
              <Card.Body>
                <Card.Title className='h6'>Utilization Report</Card.Title>
                <Card.Text className='small text-muted'>
                  Question ID, Export Date, Subject(s)
                </Card.Text>
              </Card.Body>
            </Card>
          </Col>
        </Row>

        <div className='bg-white rounded p-4 shadow-sm'>
          <Form onSubmit={handleSubmit}>
            <Row className='mb-3'>
              <Col md={12}>
                <Form.Group>
                  <Form.Label>Date Range</Form.Label>
                  <Form.Select
                    value={data.date_range}
                    onChange={(e) => {
                      setData(prev => ({ ...prev, date_range: e.target.value }))
                      setDateError('')
                    }}
                  >
                    <option value='last_7_days'>Last 7 Days</option>
                    <option value='last_30_days'>Last 30 Days</option>
                    <option value='last_90_days'>Last 90 Days</option>
                    <option value='last_year'>Last Year</option>
                    <option value='custom'>Custom Range</option>
                    <option value='all_time'>All Time</option>
                  </Form.Select>
                </Form.Group>
              </Col>
            </Row>

            {data.date_range === 'custom' && (
              <Row className='mb-3'>
                <Col md={6}>
                  <Form.Group>
                    <Form.Label>Start Date</Form.Label>
                    <Form.Control
                      type='date'
                      value={data.start_date}
                      onChange={(e) => {
                        setData(prev => ({ ...prev, start_date: e.target.value }))
                        setDateError('')
                      }}
                      required
                      isInvalid={!!dateError}
                    />
                  </Form.Group>
                </Col>

                <Col md={6}>
                  <Form.Group>
                    <Form.Label>End Date</Form.Label>
                    <Form.Control
                      type='date'
                      value={data.end_date}
                      onChange={(e) => {
                        setData(prev => ({ ...prev, end_date: e.target.value }))
                        setDateError('')
                      }}
                      required
                      isInvalid={!!dateError}
                    />
                  </Form.Group>
                </Col>
                {dateError && (
                  <Col md={12} className='mt-2'>
                    <small className='text-danger'>{dateError}</small>
                  </Col>
                )}
              </Row>
            )}

            <div className='d-flex justify-content-end'>
              <Button
                type='submit'
                disabled={processing}
                variant='primary'
              >
                {processing ? 'Generating...' : 'Export CSV'}
              </Button>
            </div>
          </Form>

          {showSuccess && (
            <Alert variant='success' className='mt-3' dismissible onClose={() => setShowSuccess(false)}>
              Your report has been generated successfully and will download shortly.
            </Alert>
          )}
        </div>
      </Container>
    </Layout>
  )
}

export default Analytics
