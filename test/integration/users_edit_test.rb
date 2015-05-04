require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
	def setup
		@user = users(:john)
	end

	test "unsuccessful edit" do
		log_in_as(@user)
		get edit_user_path(@user)
  		assert_template 'users/edit'

  		patch user_path(@user), user: { 
          		name: 					"",
    			email: 					"user@invalid",
    			password: 				"foo",
    			password_confirmation: 	"bah" }

  		assert_template 'users/edit'
    	assert_select 'div#error_explanation'
    	assert_select 'div.field_with_errors'
	end

	test "successful edit with friendly forwarding" do
		get edit_user_path(@user)
		log_in_as(@user)
		assert_redirected_to edit_user_path(@user)
		assert_not session[:forwarding_url]

		name = "Foo Bar"
		email = "foo@bar.com"

		patch user_path(@user), user: {
			name: 	name,
			email: 	email,
			password: "",
			password_confirmation: "" }
		
		assert_not flash.empty?
		assert_redirected_to @user

		@user.reload
		assert_equal @user.name, name
		assert_equal @user.email, email
	end
end
