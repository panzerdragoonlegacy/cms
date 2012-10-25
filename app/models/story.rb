class Story < ActiveRecord::Base
  acts_as_url :name, :sync_url => true
  
  def to_param 
    url 
  end
  
  attr_accessible :category_id, :name, :description, :content, :publish, :dragoon_ids, :tag_ids, 
    :illustrations_attributes  
  
  belongs_to :category  
  has_many :contributions, :as => :contributable, :dependent => :destroy
  has_many :dragoons, :through => :contributions
  has_many :taggings, :as => :taggable, :dependent => :destroy
  has_many :tags, :through => :taggings
  has_many :chapters, :dependent => :destroy
  has_many :illustrations, :as => :illustratable, :dependent => :destroy
  accepts_nested_attributes_for :illustrations, :reject_if => lambda { |a| a[:illustration].blank? }, 
    :allow_destroy => true
  
  validates :name, :presence => true, :length => { :in => 2..100 }, :uniqueness => true
  validates :description, :presence => true, :length => { :in => 2..250 }
  validates :category, :presence => true
  after_save :update_chapter_urls
  
  # Updates chapter urls based on the (potentially) changed story url.
  def update_chapter_urls
    self.chapters.each do |chapter|
      chapter.save
    end
  end
end