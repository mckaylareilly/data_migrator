require 'csv'

class ProcessDocumentJob < ApplicationJob
  queue_as :default

  def perform(document_id, uploaded_file)
    document = Document.find(document_id)
    document.update(upload_start: Time.current)

    begin
      total_rows_processed = 0
      batch_size = 1000
      document.update(
        status: 'processing',
      )

      CSV.foreach(uploaded_file.path, headers: true).each_slice(batch_size) do |batch|
        patient_data = batch.map(&:to_h)
        total_rows_processed += patient_data.size

        ProcessBatchJob.perform_later(document_id, patient_data)
      end

      document.update(
        status: 'complete',
        number_of_patients: total_rows_processed,
        upload_end: Time.current
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