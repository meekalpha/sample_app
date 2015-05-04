require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, user: { 
          name: 					"",
    			email: 					"user@invalid",
    			password: 				"foo",
    			password_confirmation: 	"bah"}
  	end
  	assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
  end

  test "valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, user: { 	
        name:  "Example User",
        email: "user@example.com",
        password:              "password",
        password_confirmation: "password" }
    end
    user = assigns(:user)
    #activation message, not logged in
    assert_not flash.empty?
    assert_not is_logged_in?
    #one email sent
	  assert_equal 1, ActionMailer::Base.deliveries.size
    #try to log in before activation
    log_in_as(user)
    assert_not is_logged_in?
    assert_not flash.empty?
    #invalid activation token, correct email
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    assert_not user.reload.activated?
    #valid token, wrong email
    get edit_account_activation_path(user.activation_token, email: "wrong")
    assert_not is_logged_in?
    assert_not user.reload.activated?
    #both wrong
    get edit_account_activation_path("invalid token", email: "wrong")
    assert_not is_logged_in?
    assert_not user.reload.activated?
    #valid token and email
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end
