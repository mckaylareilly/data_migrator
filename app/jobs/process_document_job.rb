require 'csv'

class ProcessDocumentJob < ApplicationJob
  queue_as :default

  def perform(document_id, uploaded_file)
    document = Document.find(document_id)
    document.update(upload_start: Time.current)

    begin
      total_rows_processed = 0
      batch_size = 1000
      batches = []

  
      CSV.foreach(uploaded_file.path, headers: true).each_slice(batch_size) do |batch|
        batches << batch.map(&:to_h) 
      end

      total_rows_processed = batches.flatten.size 

      batches.each do |batch|
        ProcessBatchJob.perform_later(document_id, batch)
      end

      document.update(
        status: 'processing',
        number_of_patients: total_rows_processed
      )

    rescue => e
      document.update(
        upload_end: Time.current,
        status: 'failed',
        document_errors: e.message
      )
    end
  end
end