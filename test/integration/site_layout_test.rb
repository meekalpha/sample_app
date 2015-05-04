require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
	def setup
		@user = users(:john)
	end
	test "layout links" do
		get root_path
		assert_template 'static_pages/home'
		assert_select "a[href=?]", root_path, count: 2
		assert_select "a[href=?]", help_path
		assert_select "a[href=?]", about_path
		assert_select "a[href=?]", contact_path

		assert_select "a[href=?]", login_path
		assert_select "a[href=?]", signup_path

		get signup_path
		assert_template 'users/new'
		assert_select "title", full_title("Sign up")

		log_in_as(@user)
		follow_redirect!

		assert_select "a[href=?]", users_path
		assert_select "a[href=?]", user_path(@user)
		assert_select "a[href=?]", edit_user_path(@user)
		assert_select "a[href=?]", logout_path

		get users_path
		assert_template 'users/index'
		assert_select "title", full_title("All users")

		get edit_user_path(@user)
		assert_template 'users/edit'
		assert_select "title", full_title("Edit user")

		get user_path(@user)
		assert_template 'users/show'
		assert_select "title", full_title(@user.name)

		delete logout_path
		follow_redirect!
		assert_select "a[href=?]", login_path

	end
end
