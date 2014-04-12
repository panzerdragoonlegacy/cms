class Article < ActiveRecord::Base
  include Categorisable
  include Contributable
  include Illustratable
  include Relatable
  include Sluggable
        
  validates :name, :presence => true, :length => { :in => 2..100 }, :uniqueness => true
  validates :description, :presence => true, :length => { :in => 2..250 }
  validates :content, :presence => true
end