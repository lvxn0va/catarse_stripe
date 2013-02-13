jQuery ->
  Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'))
  stripe_handler.setupForm()

window.stripe_handler =
  setupForm: () ->
    $("form.stripe").submit ->
      $('input[type=submit]').attr('disabled', true)
      if $('#card_number').length
        stripe_handler.processCard()
        false
      else
        true

  processCard: ->
    card =
      number:      $('#card_number').val()
      cvc:         $('#card_code').val()
      exp_month:   $('#card_month').val()
      exp_year:    $('#card_year').val()
      address_zip: $("#card_zip").val()
    Stripe.createToken(card, stripe_handler.handleStripeResponse)

  handleStripeResponse: (status, response) ->
    if status == 200
      $('input[id$="stripe_card_token"]').val(response.id)
      $("form.stripe")[0].submit()
    else
      parent = $('.error_messages').find('ul')[0]
      if parent
        message = '<li>' + response.error.message + '</li>'
      else
        parent  = $('.error_messages')
        message = '<h2>Something went wrong!</h2><ul><li>' + response.error.message + '</li></ul>'

      $(parent).append(message)
      $('input[type=submit]').attr('disabled', false)