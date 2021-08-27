class Filter < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: true
  before_save :lowercase

  enum filter_type: [:inclusive, :exclusive]

  scope :include_filter, -> { where( :filter_type => :inclusive ) }
  scope :exclude_filter, -> { where( :filter_type => :exclusive ) }

  def lowercase
    self.name.downcase!
  end

  def self.contains(string, filter_type)
    s = string.downcase
    Filter.where(:filter_type => filter_type).pluck(:name).any? { |f| s.include? f }
  end
end
