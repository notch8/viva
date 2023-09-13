import React from 'react'
import { Container } from 'react-bootstrap'
import Layout from '../App'
import SettingsForm from '../ui/SettingsForm'
import PasswordForm from '../ui/PasswordForm'

const Settings = ({ currentUser }) => {

  return (
    <Layout>
      <Container className='px-5 bg-light-1 mt-4 rounded p-3'>
        <div className='px-5'>

        <h3 className='pt-3 fw-semibold'>Settings</h3>
        <p>On this page, you can easily update your account information, including your email, first name, and last name. Simply click on the respective section, make your changes, and save them. Keeping your information up to date is important for account security and personalization.</p>
        <SettingsForm currentUser={currentUser} />
        <h3 className='pt-3 fw-semibold'>Update Your Password</h3>
        <p>Ensuring a secure password is essential for protecting your account. Your password must be at least 8 characters long. Remember to use a combination of uppercase and lowercase letters, numbers, and symbols for added security.</p>
        <PasswordForm />
        </div>
      </Container>
    </Layout>
  )
}

export default Settings
