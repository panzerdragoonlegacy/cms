class Share < ActiveRecord::Base
  include Categorisable
  include Taggable

  has_paper_trail

  belongs_to :contributor_profile

  validates :url, presence: true, length: { in: 1..250 }, uniqueness: true
  validates :comment, presence: true, length: { in: 1..250 }
  validates :contributor_profile, presence: true
end
