class NewsEntry < ActiveRecord::Base
  include Sluggable

  belongs_to :dragoon

  validates :name, presence: true, length: { in: 2..55 }, uniqueness: true
  validates :content, presence: true

  before_save :publish_news_entry

  def publish_news_entry
    # The first time the news entry is published:
    if self.published_at.blank? && self.publish

      # Set published_at field in the database to the current datetime:
      self.published_at = DateTime.now

      full_url = "http://www.thewilloftheancients.com/news/" + self.url

      # Get Twitter authentication details from secrets.yml
      client = Twitter::REST::Client.new do |config|
        config.consumer_key = 
          Rails.application.secrets.twitter["consumer_key"]
        config.consumer_secret = 
          Rails.application.secrets.twitter["consumer_secret"]
        config.access_token = Rails.application.secrets.twitter["oauth_token"]
        config.access_token_secret = 
          Rails.application.secrets.twitter["oauth_token_secret"]
      end

      # Post the status update field + short URL to Twitter:
      if self.name[-1] == "?" or self.name[-1] == "!"
        client.update(self.name + " " + full_url)
      else
        client.update(self.name + ": " + full_url)
      end
    end
  end
end
