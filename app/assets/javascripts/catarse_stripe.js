//= require ./catarse_stripe/checkout
//= require ./catarse_stripe/user_document
//= require_tree ./catarse_stripe

$(function() {
  var view = window.stripeForm = new CATARSE.StripeForm();
});
