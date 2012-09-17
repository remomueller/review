require 'test_helper'

class PublicationsControllerTest < ActionController::TestCase
  setup do
    @proposed = publications(:proposed)
    @draft = publications(:draft)
    @nominated = publications(:nominated)
  end

  test "should tag for sc review" do
    login(users(:sc_secretary))
    post :tag_for_review, id: @proposed.to_param, committee: 'sc', tagged: '1', format: 'js'
    assert_not_nil assigns(:publication)
    assert_equal 'sc', assigns(:committee)
    assert_equal true, assigns(:publication).tagged_for_sc_review
    assert_template 'tag_for_review'
  end

  test "should untag for sc review" do
    login(users(:sc_secretary))
    post :tag_for_review, id: @proposed.to_param, committee: 'sc', format: 'js'
    assert_not_nil assigns(:publication)
    assert_equal 'sc', assigns(:committee)
    assert_equal false, assigns(:publication).tagged_for_sc_review
    assert_template 'tag_for_review'
  end

  test "should tag for pp review" do
    login(users(:pp_secretary))
    post :tag_for_review, id: @proposed.to_param, committee: 'pp', tagged: '1', format: 'js'
    assert_not_nil assigns(:publication)
    assert_equal 'pp', assigns(:committee)
    assert_equal true, assigns(:publication).tagged_for_pp_review
    assert_template 'tag_for_review'
  end

  test "should untag for pp review" do
    login(users(:pp_secretary))
    post :tag_for_review, id: @proposed.to_param, committee: 'pp', format: 'js'
    assert_not_nil assigns(:publication)
    assert_equal 'pp', assigns(:committee)
    assert_equal false, assigns(:publication).tagged_for_pp_review
    assert_template 'tag_for_review'
  end

  test "should not tag for review as non-secretary" do
    login(users(:valid))
    post :tag_for_review, id: @proposed.to_param, committee: 'pp', tagged: '1', format: 'js'
    assert_nil assigns(:publication)
    assert_response :success
  end

  test "should send reminder" do
    login(users(:pp_secretary))
    post :send_reminder, id: @proposed.to_param, reviewer_id: users(:pp_committee).to_param, format: 'js'
    assert_not_nil assigns(:publication)
    assert_not_nil assigns(:reviewer)
    assert_not_nil assigns(:user_publication_review)
    assert_template 'send_reminder'
  end

  test "should not send reminder for non-secretary" do
    login(users(:valid))
    post :send_reminder, id: @proposed.to_param, reviewer_id: users(:pp_committee).to_param, format: 'js'
    assert_nil assigns(:publication)
    assert_nil assigns(:reviewer)
    assert_nil assigns(:user_publication_review)
    assert_response :success
  end

  test "should edit manuscript" do
    login(users(:valid))
    post :edit_manuscript, id: @nominated.to_param, format: 'js'
    assert_not_nil assigns(:publication)
    assert_template 'publications/manuscripts/edit_manuscript'
  end

  test "should not edit manuscript on publication pending sc approval" do
    login(users(:valid))
    post :edit_manuscript, id: @proposed.to_param, format: 'js'
    assert_response :success
  end

  test "should show manuscript" do
    login(users(:valid))
    post :show_manuscript, id: @nominated.to_param, format: 'js'
    assert_not_nil assigns(:publication)
    assert_template 'publications/manuscripts/show_manuscript'
  end

  test "should not show manuscript on publication pending sc approval" do
    login(users(:valid))
    post :show_manuscript, id: @proposed.to_param, format: 'js'
    assert_response :success
  end

  test "should upload manuscript in DOC format" do
    login(users(:valid))
    post :upload_manuscript, id: @nominated.to_param, publication: { manuscript: fixture_file_upload('../../test/support/publications/manuscripts/test_01.doc') }
    assert_not_nil assigns(:publication)
    assert_equal 'test_01.doc', assigns(:publication).manuscript.identifier
    assert_redirected_to publication_path(assigns(:publication))
  end

  test "should upload manuscript in DOCX format" do
    login(users(:valid))
    post :upload_manuscript, id: @nominated.to_param, publication: { manuscript: fixture_file_upload('../../test/support/publications/manuscripts/test_01.docx') }
    assert_not_nil assigns(:publication)
    assert_equal 'test_01.docx', assigns(:publication).manuscript.identifier
    assert_redirected_to publication_path(assigns(:publication))
  end

  test "should upload manuscript in PDF format" do
    login(users(:valid))
    post :upload_manuscript, id: @nominated.to_param, publication: { manuscript: fixture_file_upload('../../test/support/publications/manuscripts/test_01.pdf') }
    assert_not_nil assigns(:publication)
    assert_equal 'test_01.pdf', assigns(:publication).manuscript.identifier
    assert_redirected_to publication_path(assigns(:publication))
  end

  test "should not upload manuscript on publication pending sc approval" do
    login(users(:valid))
    post :upload_manuscript, id: @proposed.to_param, publication: { manuscript: fixture_file_upload('../../test/support/publications/manuscripts/test_01.doc') }
    assert_not_nil assigns(:publication)
    assert_equal 'Please specify a file to upload.', flash[:notice]
    assert_redirected_to publication_path(assigns(:publication))
  end

  test "should not upload manuscript non-existent manuscript" do
    login(users(:valid))
    post :upload_manuscript, id: @nominated.to_param
    assert_not_nil assigns(:publication)
    assert_equal 'Please specify a file to upload.', flash[:notice]
    assert_redirected_to publication_path(assigns(:publication))
  end

  test "should not upload manuscript" do
    login(users(:two))
    post :upload_manuscript, id: @nominated.to_param, publication: { manuscript: fixture_file_upload('../../test/support/publications/manuscripts/test_01.doc') }
    assert_nil assigns(:publication)
    assert_redirected_to root_path
  end

  test "should destroy manuscript" do
    login(users(:valid))
    post :destroy_manuscript, id: @proposed.to_param, format: 'js'
    assert_not_nil assigns(:publication)
    assert_template 'publications/manuscripts/edit_manuscript'
  end

  test "should not destroy manuscript" do
    login(users(:two))
    post :destroy_manuscript, id: @proposed.to_param, format: 'js'
    assert_nil assigns(:publication)
    assert_response :success
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
    assert_not_nil assigns(:publications)
    assert_response :success
  end

  test "should get print" do
    login(users(:valid))
    get :print
    assert_not_nil assigns(:order)
    assert_not_nil assigns(:publications)
    assert_response :success
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

  test "should update inline for secretary" do
    login(users(:pp_secretary))
    post :inline_update, id: @proposed.to_param, publication: { targeted_start_date: "05/20/2011", status: 'submitted' }, format: 'js'
    assert_not_nil assigns(:publication)
    assert_equal "2011-05-20", assigns(:publication).targeted_start_date.strftime("%Y-%m-%d")
    assert_equal "submitted", assigns(:publication).status
    assert_template 'inline_update'
    assert_response :success
  end

  test "should not update inline for non-secretary" do
    login(users(:valid))
    post :inline_update, id: @proposed.to_param, publication: { targeted_start_date: "05/20/2011", status: 'submitted' }, format: 'js'
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
    assert_redirected_to publications_path
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
