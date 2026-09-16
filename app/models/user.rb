class User < ApplicationRecord
  devise :database_authenticatable,
         authentication_keys: [:employee_number]

  enum :role, employee: 0, admin: 1

  has_many :alcohol_checks, dependent: :restrict_with_error
  has_many :confirmed_alcohol_checks, class_name: 'AlcoholCheck', foreign_key: 'checker_id', dependent: :restrict_with_error

  validates :employee_number, presence: true, uniqueness: true
  validates :name, presence: true
end
