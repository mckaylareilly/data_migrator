class Patient < ApplicationRecord
    validates :patient_id, presence: true
    validates :origin_province, presence: true
end