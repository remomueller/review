require 'test_helper'

class PublicationsControllerTest < ActionController::TestCase
  setup do
    @proposed = publications(:proposed)
    @draft = publications(:draft)
  end

  test "should send pp approval" do
    login(users(:pp_secretary))
    post :pp_approval, id: @proposed.to_param, publication: { status: 'approved', additional_sccommittee_instructions: 'Additional Instructions' }
    assert_not_nil assigns(:publication)
    assert_redirected_to publication_path(assigns(:publication))
  end

  test "should not send pp approval for non-pp committee secretary" do
    login(users(:valid))
    post :pp_approval, id: @proposed.to_param, publication: { status: 'approved', additional_sccommittee_instructions: 'Additional Instructions' }
    assert_nil assigns(:publication)
    assert_redirected_to root_path
  end

  test "should send sc approval" do
    login(users(:sc_secretary))
    post :sc_approval, id: @proposed.to_param, publication: { status: 'nominated', additional_sccommittee_instructions: 'Additional Instructions' }
    assert_not_nil assigns(:publication)
    assert_redirected_to publication_path(assigns(:publication))
  end

  test "should not send sc approval for non-steering committee secretary" do
    login(users(:valid))
    post :sc_approval, id: @proposed.to_param, publication: { status: 'nominated', additional_sccommittee_instructions: 'Additional Instructions' }
    assert_nil assigns(:publication)
    assert_redirected_to root_path
  end

  test "should show subcommittee decision" do
    login(users(:pp_secretary))
    post :show_subcommittee_decision, id: @proposed.to_param, format: 'js'
    assert_not_nil assigns(:publication)
    assert_template 'show_subcommittee_decision'
  end

  test "should not show subcommittee decision for non sc secretary" do
    login(users(:valid))
    post :show_subcommittee_decision, id: @proposed.to_param, format: 'js'
    assert_nil assigns(:publication)
    assert_response :success
  end

  test "should get edit subcommittee decision" do
    login(users(:pp_secretary))
    post :edit_subcommittee_decision, id: @proposed.to_param, format: 'js'
    assert_not_nil assigns(:publication)
    assert_template 'edit_subcommittee_decision'
  end

  test "should not get edit subcommittee decision for non sc secretary" do
    login(users(:valid))
    post :edit_subcommittee_decision, id: @proposed.to_param, format: 'js'
    assert_nil assigns(:publication)
    assert_response :success
  end

  test "should show steering committee decision" do
    login(users(:sc_secretary))
    post :show_steering_committee_decision, id: @proposed.to_param, format: 'js'
    assert_not_nil assigns(:publication)
    assert_template 'show_steering_committee_decision'
  end

  test "should not show steering committee decision for non sc secretary" do
    login(users(:valid))
    post :show_steering_committee_decision, id: @proposed.to_param, format: 'js'
    assert_nil assigns(:publication)
    assert_response :success
  end

  test "should get edit steering committee decision" do
    login(users(:sc_secretary))
    post :edit_steering_committee_decision, id: @proposed.to_param, format: 'js'
    assert_not_nil assigns(:publication)
    assert_template 'edit_steering_committee_decision'
  end

  test "should not get edit steering committee decision for non sc secretary" do
    login(users(:valid))
    post :edit_steering_committee_decision, id: @proposed.to_param, format: 'js'
    assert_nil assigns(:publication)
    assert_response :success
  end

  test "should get index" do
    login(users(:valid))
    get :index
    assert_response :success
    assert_not_nil assigns(:publications)
  end
  
  test "should not show 'draft' or 'not approved' for regular users on the publication matrix unless they are the author" do
    login(users(:two))
    get :index, format: 'js'
    assert_not_nil assigns(:publications)
    assert_equal 0, assigns(:publications).where(['user_id = ? and status IN (?)', users(:two).to_param, ['draft', 'not approved']]).size
    assert_template 'index'
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

  test "should get inline edit for secretary" do
    login(users(:pp_secretary))
    post :inline_edit, id: @proposed.to_param, format: 'js'
    assert_not_nil assigns(:publication)
    assert_template 'inline_edit'
  end

  test "should not get inline edit for non-secretary" do
    login(users(:valid))
    post :inline_edit, id: @proposed.to_param, format: 'js'
    assert_nil assigns(:publication)
    assert_response :success
  end

  test "should update inline for secretary" do
    login(users(:pp_secretary))
    post :inline_update, id: @proposed.to_param, publication: { @proposed.to_param.to_s => { targeted_start_date: "05/20/2011", status: 'submitted' } }, format: 'js'
    assert_not_nil assigns(:publication)
    assert_equal "2011-05-20", assigns(:publication).targeted_start_date.strftime("%Y-%m-%d")
    assert_equal "submitted", assigns(:publication).status
    assert_template 'inline_show'
  end

  test "should not update inline for non-secretary" do
    login(users(:valid))
    post :inline_update, id: @proposed.to_param, publication: { @proposed.to_param.to_s => { targeted_start_date: "05/20/2011", status: 'submitted' } }, format: 'js'
    assert_nil assigns(:publication)
    assert_response :success
  end

  test "should get inline show for secretary" do
    login(users(:pp_secretary))
    post :inline_show, id: @proposed.to_param, format: 'js'
    assert_not_nil assigns(:publication)
    assert_template 'inline_show'
  end

  test "should not get inline show for non-secretary" do
    login(users(:valid))
    post :inline_show, id: @proposed.to_param, format: 'js'
    assert_nil assigns(:publication)
    assert_response :success
  end

  test "should create publication" do
    login(users(:valid))
    assert_difference('Publication.count') do
      post :create, publication: @draft.attributes
    end

    assert_redirected_to publication_path(assigns(:publication))
  end
  
  test "should create publication using quick save" do
    login(users(:valid))
    assert_difference('Publication.count') do
      post :create, publication: @draft.attributes, publish: -1
    end
    assert_not_nil assigns(:publication)
    assert_equal 'draft', assigns(:publication).status
    assert_template 'new'
  end

  test "should not create publication draft without full title and abbreviated title" do
    login(users(:valid))
    assert_difference('Publication.count', 0) do
      post :create, publication: @draft.attributes.merge({ full_title: '', abbreviated_title: ''})
    end
    assert_not_nil assigns(:publication)
    assert_equal ["can't be blank"], assigns(:publication).errors[:full_title]
    assert_equal ["can't be blank"], assigns(:publication).errors[:abbreviated_title]
    assert_equal 2, assigns(:publication).errors.size
    assert_template 'new'
  end
  
  test "should create publication for secretary" do
    login(users(:pp_secretary))
    assert_difference('Publication.count') do
      post :create, :publication => @draft.attributes
    end

    assert_redirected_to publication_path(assigns(:publication))
  end

  test "should show publication" do
    login(users(:valid))
    get :show, id: @proposed.to_param
    assert_response :success
  end

  test "should get edit if publication is a draft" do
    login(users(:valid))
    get :edit, id: @draft.to_param
    assert_response :success
  end

  test "should not get edit if publication is proposed" do
    login(users(:valid))
    get :edit, id: @proposed.to_param
    assert_redirected_to root_path
  end

  test "should get edit if publication is proposed and secretary wishes to edit" do
    login(users(:pp_secretary))
    get :edit, id: @proposed.to_param
    assert_template 'edit'
    assert_response :success
  end

  test "should update publication and submit for review" do
    login(users(:valid))
    put :update, id: @draft.to_param, publication: @proposed.attributes, publish: 1
    assert_not_nil assigns(:publication)
    assert_equal 'proposed', assigns(:publication).status
    assert_redirected_to publication_path(assigns(:publication))
  end
  
  test "should update publication and save as a draft" do
    login(users(:valid))
    put :update, id: @draft.to_param, publication: @proposed.attributes
    assert_not_nil assigns(:publication)
    assert_equal 'draft', assigns(:publication).status
    assert_redirected_to publication_path(assigns(:publication))
  end

  test "should not update publication draft without full title and abbreviated title" do
    login(users(:valid))
    put :update, id: @draft.to_param, publication: @proposed.attributes.merge({ full_title: '', abbreviated_title: ''})
    assert_not_nil assigns(:publication)
    assert_equal ["can't be blank"], assigns(:publication).errors[:full_title]
    assert_equal ["can't be blank"], assigns(:publication).errors[:abbreviated_title]
    assert_equal 2, assigns(:publication).errors.size
    assert_template 'edit'
  end
  
  test "should not update publication with invalid id" do
    login(users(:valid))
    put :update, id: -1, publication: @proposed.attributes
    assert_nil assigns(:publication)
    assert_redirected_to root_path
  end
  
  test "should update publication and quick save" do
    login(users(:valid))
    put :update, id: @draft.to_param, publication: @proposed.attributes, publish: -1
    assert_not_nil assigns(:publication)
    assert_equal 'draft', assigns(:publication).status
    assert_template 'edit'
  end

  test "should update publication as secretary" do
    login(users(:pp_secretary))
    put :update, id: @proposed.to_param, publication: { status: 'nominated' }
    assert_not_nil assigns(:publication)
    assert_equal 'nominated', assigns(:publication).status
    assert_redirected_to publication_path(assigns(:publication))
  end

  test "should destroy publication" do
    login(users(:valid))
    assert_difference('Publication.current.count', -1) do
      delete :destroy, id: @draft.to_param
    end

    assert_redirected_to publications_path
  end
  
  test "should not destroy publication with invalid id" do
    login(users(:valid))
    assert_difference('Publication.current.count', 0) do
      delete :destroy, id: -1
    end

    assert_nil assigns(:publication)
    assert_redirected_to root_path
  end
  
  test "should remove nomination from publication reviews" do
    login(users(:pp_secretary))
    post :remove_nomination, id: publications(:tagged_for_pp_and_sc_review), nomination: 'Joe Schmoe', format: 'js'
    
    assert_not_nil assigns(:publication)
    assert !assigns(:publication).proposed_nominations.include?('Joe Schmoe')
    assert_template 'committee_nominations'
  end
  
  test "should not remove nomination from publication reviews for non-secretary" do
    login(users(:valid))
    post :remove_nomination, id: publications(:tagged_for_pp_and_sc_review), nomination: 'Joe Schmoe', format: 'js'
    
    assert_not_nil assigns(:publication)
    assert assigns(:publication).proposed_nominations.include?('Joe Schmoe')
    assert_response :success
  end
  
  test "should not remove nomination from publication reviews for invalid publication" do
    login(users(:pp_secretary))
    post :remove_nomination, id: -1, nomination: 'Joe Schmoe', format: 'js'
    
    assert_nil assigns(:publication)
    assert_response :success
  end
end
