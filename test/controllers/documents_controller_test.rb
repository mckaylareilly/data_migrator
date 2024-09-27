require 'test_helper'

class DocumentsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @document_params = { file: fixture_file_upload('test.csv', 'text/csv') }
  end

  test "should get new" do
    get new_document_url
    assert_response :success
  end

  test "should create document" do
    assert_difference('Document.count', 1) do
      post documents_url, params: { document: @document_params }
    end
  end

  test "should get index" do
    get documents_url
    assert_response :success
  end

  test "should show document" do
    document = Document.create!(file_name: 'test.csv', status: 'pending')
    get document_url(document)
    assert_response :success
  end
end