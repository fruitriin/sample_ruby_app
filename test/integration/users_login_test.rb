require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "login with invalid information" do
    get login_path
    assert_template"sessions/new"
    post login_path params: { session: {email: "" , password: ""}}
    assert_template "sessions/new"
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "login with valid infomation" do
    get login_path
    post login_path params: { session: {email: @user.email, password: "password"}}
    assert_redirected_to @user
    follow_redirect!
    assert_template "users/show"
    assert_select "a[href=?]", login_path, count:0
    assert_select "a[href=?]", logout_path
    # assert_select "a[href=?]". users_path(@user)
  end

  test "login with valid infomation followed by logout" do
    get login_path
    post login_path, params: {session: { email: @user.email, password: "password"}}
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template "users/show"
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url

    delete logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", users_path(@user), count: 0

  end

  test "authenticated? shuld return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "login with remembbering" do
    log_in_as(@user, remember_me: "1")
    assert_not_empty cookies['remember_token']
  end

  test "login without remembering" do
    log_in_as(@user, remember_me: '1')
    assert_not_empty cookies['remember_token']
    delete logout_path
    log_in_as(@user, remember_me: '0')
    assert_empty cookies['remember_token']
  end
end
