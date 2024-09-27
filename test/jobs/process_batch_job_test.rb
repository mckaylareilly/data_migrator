require 'test_helper'

class ProcessBatchJobTest < ActiveJob::TestCase
  def setup
    @document = Document.create!(
      file_name: 'test.csv',
      status: 'pending',
      number_of_patients: 3,
      successful_rows: 0,
      failed_rows: 0,
      document_errors: ''  # Ensure this is initialized as an empty string
    )
  end

  test "should process a batch of valid patients" do
    batch = [
      { 'health identifier' => '123', 'health identifier province' => 'Province A', 'address 1' => 'Address 1', 'address 2' => '', 'email' => 'test1@example.com', 'phone' => '1234567890', 'sex' => 'M' },
      { 'health identifier' => '456', 'health identifier province' => 'Province B', 'address 1' => 'Address 2', 'address 2' => '', 'email' => 'test2@example.com', 'phone' => '0987654321', 'sex' => 'F' }
    ]
  
    @document.update(number_of_patients: batch.size) # Make sure this is set
    ProcessBatchJob.perform_now(@document.id, batch)
  
    assert_equal 2, @document.reload.successful_rows  # Two valid patients should be saved
    assert_equal 0, @document.failed_rows  # No invalid patients should fail
  end

  test "should process a batch with some invalid patients" do
    batch = [
      { 'health identifier' => 'valid_id_1', 'health identifier province' => 'Province A', 'address 1' => 'Address 1', 'address 2' => '', 'email' => 'test1@example.com', 'phone' => '1234567890', 'sex' => 'M' },
      { 'health identifier' => '', 'health identifier province' => 'Province B', 'address 1' => 'Address 2', 'address 2' => '', 'email' => 'invalid_email', 'phone' => '0987654321', 'sex' => 'F' } # Invalid patient
    ]
  
    @document.update(number_of_patients: batch.size)
    ProcessBatchJob.perform_now(@document.id, batch)
  
    assert_equal 1, @document.reload.successful_rows
    assert_equal 1, @document.failed_rows
  end

  test "should update document status to success when all patients are valid" do
    batch = [
      { 'health identifier' => '123', 'health identifier province' => 'Province A', 'address 1' => 'Address 1', 'address 2' => '', 'email' => 'test1@example.com', 'phone' => '1234567890', 'sex' => 'M' },
      { 'health identifier' => '456', 'health identifier province' => 'Province B', 'address 1' => 'Address 2', 'address 2' => '', 'email' => 'test2@example.com', 'phone' => '0987654321', 'sex' => 'F' },
      { 'health identifier' => '789', 'health identifier province' => 'Province C', 'address 1' => 'Address 3', 'address 2' => '', 'email' => 'test3@example.com', 'phone' => '1112223333', 'sex' => 'M' }
    ]

    @document.update!(number_of_patients: 3)  # Set total patients to match batch size

    ProcessBatchJob.perform_now(@document.id, batch)

    assert_equal 3, @document.reload.successful_rows
    assert_equal 0, @document.failed_rows
    assert_equal '', @document.document_errors
  end

  test "should not change document status if batch size does not match" do
    batch = [
      { 'health identifier' => '123', 'health identifier province' => 'Province A', 'address 1' => 'Address 1', 'address 2' => '', 'email' => 'test1@example.com', 'phone' => '1234567890', 'sex' => 'M' }
    ]

    ProcessBatchJob.perform_now(@document.id, batch)

    assert_equal 1, @document.reload.successful_rows
    assert_equal 0, @document.failed_rows
  end
end