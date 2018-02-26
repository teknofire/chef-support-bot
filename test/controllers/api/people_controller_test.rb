require 'test_helper'

class Api::PeopleControllerTest < ActionDispatch::IntegrationTest
  setup do
    @data = {"token"=>"a1B2c3D4e5F6", "team_id"=>"123456", "team_domain"=>"testing", "channel_id"=>"ABCDEFG", "channel_name"=>"general", "user_id"=>"TWFW331", "user_name"=>"test-user", "text"=>"" }
  end

  test "should fail authorization" do
    @data["token"] = "asdfasdfasdfa"

    post register_api_people_url, params: @data, as: :json

    assert_redirected_to api_invalid_token_url
  end

  test "should register new user" do
    assert_difference('Person.count') do
      post register_api_people_url, params: @data, as: :json
    end

    assert_response :success
    assert_match "You have been registered", @response.body
  end

  test "should get status" do
    post status_api_people_url, params: @data
    assert_response :success
  end

  test "should mark user as away" do
    post away_api_people_url, params: @data

    assert_response :success
  end
end
