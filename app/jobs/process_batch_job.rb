class ProcessBatchJob < ApplicationJob
    queue_as :default
  
    def perform(document_id, batch)
      document = Document.find(document_id)
  
      successful_rows = 0
      failed_rows = 0
      error_messages = []
  
      batch.each do |row|
        patient_attributes = row.to_hash.slice('health identifier', 'health identifier province', 'address 1', 'address 2', 'email', 'phone', 'sex')
  
        patient = Patient.new(
          patient_id: patient_attributes['health identifier'],
          origin_province: patient_attributes['health identifier province'],
          address1: patient_attributes['address 1'],
          address2: patient_attributes['address 2'],
          email: patient_attributes['email'],
          phone: patient_attributes['phone'],
          sex: patient_attributes['sex']
        )
  
        if patient.save
          successful_rows += 1
        else
          failed_rows += 1
          error_messages << "Error for patient ID #{patient_attributes['health identifier']}: #{patient.errors.full_messages.join(', ')}"
        end
      end
  
      document.increment!(:successful_rows, successful_rows)
      document.increment!(:failed_rows, failed_rows)
      document.document_errors += error_messages.join('; ') unless error_messages.empty?
  
      if document.number_of_patients == (document.successful_rows + document.failed_rows)
        document.update(
          upload_end: Time.current,
          status: failed_rows.zero? ? 'success' : 'partially successful'
        )
      end
    end
  end