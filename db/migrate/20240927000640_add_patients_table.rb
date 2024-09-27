class AddPatientsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :patients do |t|
      t.string :patient_id, null: false
      t.string :origin_province, null: false
      t.string :address1
      t.string :address2 
      t.string :email
      t.string :phone
      t.string :sex

      t.timestamps
    end
  end
end
