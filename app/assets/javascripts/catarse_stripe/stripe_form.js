CATARSE.StripeForm = CATARSE.UserDocument.extend({
  el: '#catarse_stripe_form',

  events: {
    'click input[type=submit]': 'onSubmitToStripe',
    'keyup #user_document' : 'onUserDocumentKeyup'
  },

  initialize: function() {
    this.loader = $('.loader');
  },

  onSubmitToStripe: function(e) {
    $(e.currentTarget).hide();
    this.loader.show();
  }
});