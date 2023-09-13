import React, { useState } from 'react'
import { Container } from 'react-bootstrap'
import Layout from '../App'
import SettingsForm from '../ui/SettingsForm'
import PasswordForm from '../ui/PasswordForm'

const Settings = ({ currentUser }) => {
  const [passwordFormValues, setPasswordFormValues] = useState({
    currentPassword: '',
    newPassword: '',
    passwordConfirmation: ''
  })

  const handleChange = (e) => {
    const key = e.target.id;
    const value = e.target.value
    setValues(values => ({
        ...values,
        [key]: value,
    }))
  }

  const handleSubmit = (e) => {
    e.preventDefault()
    router.post('/users', values)
  }

  // const updateSettingsForm = (value, property) => {
  //   const [initialProperty, nestedProperty] = property.split('.')
9   //       ? { [initialProperty]: { ...requestForm[initialProperty], [nestedProperty]: value } }
  //       : { [initialProperty]: value }

  //     return {
  //       ...currentState,
  //       ...updatedState,
  //     }
  //   })
  // }

  // const handleSubmit = async (event) => {
  //   setButtonDisabled(true)
  //   if (!event.formData) {
  //     // these steps are needed for requests without a dynamic form
  //     // but error on the event resulting from the react json form
  //     event.preventDefault()
  //     event.stopPropagation()
  //     setValidated(true)
  //   }
  //   setFormSubmitting(true)

  //   if (requestForm.billingSameAsShipping === true) Object.assign(requestForm.billing, requestForm.shipping)

  //   const { data, error } = await createRequest({
  //     dynamicFormData: { name: dynamicForm.name, formData, ...requestForm },
  //     wareID,
  //     accessToken,
  //   })
  //   // if we have data AND an error, the request was created, but the attachments failed
  //   // in that case, we still need to send the request to the vendor
  //   if (error && !data) {
  //     setFormSubmitting(false)
  //     setCreateRequestError(error)
  //     return
  //   } else if (error) {
  //     setCreateRequestError(error)
  //   }

  return (
    <Layout>
      <Container className='bg-light-1 mt-4 rounded p-3'>
        <h2 className='pt-3'>Settings</h2>
        <p>On this page, you can easily update your account information, including your email, first name, and last name. Simply click on the respective section, make your changes, and save them. Keeping your information up to date is important for account security and personalization.</p>
        <SettingsForm currentUser={currentUser} />
        <h2 className='pt-3'>Update Your Password</h2>
        <p>Ensuring a secure password is essential for protecting your account. Your password must be at least 8 characters long. Remember to use a combination of uppercase and lowercase letters, numbers, and symbols for added security.</p>
        <PasswordForm />
      </Container>
    </Layout>
  )
}

export default Settings
