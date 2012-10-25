class Link < ActiveRecord::Base
  belongs_to :category
  has_many :contributions, :as => :contributable, :dependent => :destroy
  has_many :dragoons, :through => :contributions
  has_many :taggings, :as => :taggable, :dependent => :destroy
  has_many :tags, :through => :taggings
  
  validates :name, :presence => true, :length => { :in => 2..100 }, :uniqueness => true
  validates :description, :presence => true, :length => { :in => 2..250 }
  validates :category, :presence => true
end