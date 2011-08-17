require 'test_helper'

class PublicationsControllerTest < ActionController::TestCase
  setup do
    @proposed = publications(:proposed)
    @draft = publications(:draft)
  end

  test "should get index" do
    login(users(:valid))
    get :index
    assert_response :success
    assert_not_nil assigns(:publications)
  end

  test "should sort marked for P&P review to top in index if user P&P Secretary" do
    login(users(:pp_secretary))
    get :index
    assert_response :success
    assert_not_nil assigns(:publications)
    tagged_array = assigns(:publications).collect{|p| p.tagged_for_pp_review?.to_s}
    assert_equal tagged_array, tagged_array.sort.reverse
  end
  
  test "should sort marked for P&P review to top in index if user P&P Member" do
    login(users(:pp_committee))
    get :index
    assert_response :success
    assert_not_nil assigns(:publications)
    tagged_array = assigns(:publications).collect{|p| p.tagged_for_pp_review?.to_s}
    assert_equal tagged_array, tagged_array.sort.reverse
  end
  
  test "should sort marked for SC review to top in index if user SC Secretary" do
    login(users(:sc_secretary))
    get :index
    assert_response :success
    assert_not_nil assigns(:publications)
    tagged_array = assigns(:publications).collect{|p| p.tagged_for_sc_review?.to_s}
    assert_equal tagged_array, tagged_array.sort.reverse
  end
  
  test "should sort marked for SC review to top in index if user SC Member" do
    login(users(:sc_committee))
    get :index
    assert_response :success
    assert_not_nil assigns(:publications)
    tagged_array = assigns(:publications).collect{|p| p.tagged_for_sc_review?.to_s}
    assert_equal tagged_array, tagged_array.sort.reverse
  end
  
  test "should sort marked for P&P review followed by SC review to top in index if user is in both P&P and SC committees" do
    login(users(:pp_and_sc_committee))
    get :index
    assert_response :success
    assert_not_nil assigns(:publications)
    tagged_array = assigns(:publications).collect{|p| p.tagged_for_pp_review?.to_s + p.tagged_for_sc_review?.to_s}
    assert_equal tagged_array, tagged_array.sort.reverse
  end

  test "should sort marked for P&P review followed by SC review to top in index if user is in both P&P and SC secretary" do
    login(users(:pp_and_sc_secretary))
    get :index
    assert_response :success
    assert_not_nil assigns(:publications)
    tagged_array = assigns(:publications).collect{|p| p.tagged_for_pp_review?.to_s + p.tagged_for_sc_review?.to_s}
    assert_equal tagged_array, tagged_array.sort.reverse
  end


  test "should get new" do
    login(users(:valid))
    get :new
    assert_response :success
  end

  test "should create publication" do
    login(users(:valid))
    assert_difference('Publication.count') do
      post :create, :publication => @draft.attributes
    end

    assert_redirected_to publication_path(assigns(:publication))
  end

  test "should show publication" do
    login(users(:valid))
    get :show, :id => @proposed.to_param
    assert_response :success
  end

  test "should get edit if publication is a draft" do
    login(users(:valid))
    get :edit, :id => @draft.to_param
    assert_response :success
  end

  test "should not get edit if publication is proposed" do
    login(users(:valid))
    get :edit, :id => @proposed.to_param
    assert_redirected_to root_path
  end

  test "should update publication" do
    login(users(:valid))
    put :update, :id => @draft.to_param, :publication => @proposed.attributes
    assert_redirected_to publication_path(assigns(:publication))
  end

  test "should destroy publication" do
    login(users(:valid))
    assert_difference('Publication.current.count', -1) do
      delete :destroy, :id => @draft.to_param
    end

    assert_redirected_to publications_path
  end
end
