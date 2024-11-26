class Employee < ApplicationRecord
	# serialize :phone_numbers, Array

  validates :employee_id, presence: true, uniqueness: true
  validates :first_name, :last_name, :email, :doj, :salary, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :salary, numericality: { greater_than_or_equal_to: 0 }
end
