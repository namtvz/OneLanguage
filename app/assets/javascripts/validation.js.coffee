root = exports ? this

@validateDeviseForm = ->
  $('.devise-form').validate
    rules:
      'user[email]':
        required: true
        email: true
      'user[password]':
        required: true
        minlength: 8
      'user[password_confirmation]':
        equalTo: '#user_password'
      'user[current_password]':
        required: true
    messages:
      'user[password_confirmation]':
        equalTo: 'Please enter the same with password.'    

