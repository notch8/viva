import React from 'react'
import { Container, InputGroup, Form, Row, Col } from 'react-bootstrap'
import Layout from '../App'
import SettingsForm from '../ui/SettingsForm'
import PasswordForm from '../ui/PasswordForm'

const Settings = () => {
  return (
    <Layout>
      <Container className='bg-light-1 mt-4 rounded p-3'>
        <h2 className='pt-3'>Settings</h2>
        <p>On this page, you can easily update your account information, including your email, first name, and last name. Simply click on the respective section, make your changes, and save them. Keeping your information up to date is important for account security and personalization.</p>
        <SettingsForm />
        <h2 className='pt-3'>Update Your Password</h2>
        <p>Ensuring a secure password is essential for protecting your account. Remember to use a combination of uppercase and lowercase letters, numbers, and symbols for added security.</p>
        <PasswordForm />
      </Container>
    </Layout>
  )
}

export default Settings
