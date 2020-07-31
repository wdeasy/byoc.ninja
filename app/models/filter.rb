class Filter < ApplicationRecord
  validates :name, presence: true
  before_save :lowercase

  def lowercase
    self.name.downcase!
  end

  def self.contains(string)
    s = string.downcase
    Filter.pluck(:name).any? { |f| s.include? f }
  end
end
