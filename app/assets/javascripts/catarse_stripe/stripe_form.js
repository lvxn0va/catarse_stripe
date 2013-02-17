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

  $('#customButton').click(function(){
    var token = function(res){
      console.log('Got token ID:', res.id);
    };

    StripeCheckout.open({
      key:         'pk_0TofLEX9n7baBwirc2xo1dHtDm8e0',
      address:     true,
      amount:      5000,
      name:        'Joes Pistachios',
      description: 'A bag of Pistachios',
      panelLabel:  'Checkout',
      token:       token
    });

    return false;
  });
});