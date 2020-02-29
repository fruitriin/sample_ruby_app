require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @admin = users(:michael)
    @non_admin = users(:archer)
  end

  test "index including pagination" do
    log_in_as(@user)
    get users_path
    assert_template "users/index"
    assert_select "div.pagination"
    User.paginate(page: 1).each do |user|
      assert_select "a[href=?]", user_path(user), text: user.name
    end
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference "User.count" do
      delete user_path(@user)
    end
    assert_redirected_to login_url
  end

  test "should redirect destory when logged in as a non-admin" do
    log_in_as(@non_admin)
    assert_no_difference "User.count" do
      delete user_path(@user)
    end
    assert_redirected_to root_url
  end
  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template "users/index"
    assert_select "div.pagination"
    first_page_of_users = User.paginate(page:1)
    first_page_of_users.each do |user|
      assert_select "a[href=?]", user_path(user), text:user.name
      unless user == @admin
        assert_select "a[href=?]", user_path(user), text: "delete"
      end
    end
    assert_difference "User.count", -1 do
      delete user_path(@non_admin)
    end
  end

  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select "a", text:"delete", count: 0
  end

end
