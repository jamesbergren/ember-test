controller = Ember.Controller.extend
  email: 'john@example'

  emailValid: (->
    emailpat = /^[^@]+@[^@]+\.[^@\.]{2,}$/
    email = @get('email')

    unless email.match(emailpat)
      return 'We need a valid email address'

  ).property 'email'

`export default controller`
