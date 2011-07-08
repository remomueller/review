require 'test_helper'

class PublicationsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @proposed = publications(:proposed)
    @draft = publications(:draft)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:publications)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create publication" do
    assert_difference('Publication.count') do
      post :create, :publication => @draft.attributes
    end

    assert_redirected_to publication_path(assigns(:publication))
  end

  test "should show publication" do
    get :show, :id => @proposed.to_param
    assert_response :success
  end

  test "should get edit if publication is a draft" do
    get :edit, :id => @draft.to_param
    assert_response :success
  end

  test "should not get edit if publication is proposed" do
    get :edit, :id => @proposed.to_param
    assert_redirected_to root_path
  end

  test "should update publication" do
    put :update, :id => @draft.to_param, :publication => @proposed.attributes
    assert_redirected_to publication_path(assigns(:publication))
  end

  test "should destroy publication" do
    assert_difference('Publication.current.count', -1) do
      delete :destroy, :id => @draft.to_param
    end

    assert_redirected_to publications_path
  end
end
