class AlcoholCheck < ApplicationRecord
  belongs_to :user
  belongs_to :checker, class_name: 'User'

  enum :check_type, arrival: 0, departure: 1

  validates :alcohol_value, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :checker_must_be_different_from_user
  validate :only_one_check_per_type_per_day, on: :create

  before_validation :set_checked_on, on: :create

  private

  def set_checked_on
    self.checked_on ||= Date.current
  end

  def checker_must_be_different_from_user
    return if checker_id.nil? || user_id.nil?
    errors.add(:checker, "は本人以外を選択してください") if checker_id == user_id
  end

  def only_one_check_per_type_per_day
    return if user_id.blank? || check_type.blank?

    already_exists = AlcoholCheck.exists?(
      user_id: user_id,
      check_type: check_type,
      checked_on: Date.current
    )

    if already_exists
      errors.add(:base, "同じ種類のアルコールチェックは1日1回までです")
    end
  end
end
