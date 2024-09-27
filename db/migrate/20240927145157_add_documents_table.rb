class AddDocumentsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :documents do |t|
      t.string :file_name
      t.string :status
      t.string :number_of_patients
      t.integer :successful_rows
      t.integer :failed_rows
      t.datetime :upload_start
      t.datetime :upload_end
      t.string :document_errors

      t.timestamps
    end
  end
end
