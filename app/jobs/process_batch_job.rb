class ProcessBatchJob < ApplicationJob
    queue_as :default
  
    def perform(document_id, batch)
      document = Document.find(document_id)
  
      successful_rows = 0
      failed_rows = 0
      error_messages = []
  
      batch.each do |row|
        patient = Patient.new(
          patient_id: row['health identifier'],
          origin_province: row['health identifier province'],
          address1: row['address 1'],
          address2: row['address 2'],
          email: row['email'],
          phone: row['phone'],
          sex: row['sex']
        )
  
        if patient.save
          successful_rows += 1
        else
          failed_rows += 1
          error_messages << "Error for patient ID #{row['health identifier']}: #{patient.errors.full_messages.join(', ')}"
        end
      end
  
      document.increment!(:successful_rows, successful_rows)
      document.increment!(:failed_rows, failed_rows)
      document.document_errors += error_messages.join('; ') unless error_messages.empty?
  
      total_patients_processed = successful_rows + failed_rows
  
      if total_patients_processed == document.number_of_patients
        if failed_rows.zero?
          document.update(status: 'success')
        else
          document.update(status: 'partially successful')
        end
        document.update(upload_end: Time.current)
      end
    end
  end