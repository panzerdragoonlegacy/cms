class ContributorProfile < ActiveRecord::Base
  include Publishable
  include SluggableWithoutId

  has_one :user, dependent: :destroy
  has_many :news_entries, dependent: :destroy

  has_many :contributions, dependent: :destroy
  has_many(
    :pages,
    through: :contributions,
    source: :contributable,
    source_type: 'Page'
  )
  has_many(
    :albums,
    through: :contributions,
    source: :contributable,
    source_type: 'Album'
  )
  has_many(
    :pictures,
    through: :contributions,
    source: :contributable,
    source_type: 'Picture'
  )
  has_many(
    :music_tracks,
    through: :contributions,
    source: :contributable,
    source_type: 'MusicTrack'
  )
  has_many(
    :videos,
    through: :contributions,
    source: :contributable,
    source_type: 'Video'
  )
  has_many(
    :downloads,
    through: :contributions,
    source: :contributable,
    source_type: 'Download'
  )
  has_many(
    :quizzes,
    through: :contributions,
    source: :contributable,
    source_type: 'Quiz'
  )

  validates :name, presence: true, length: { in: 2..50 }, uniqueness: true

  before_save :set_published_at

  has_attached_file(
    :avatar,
    styles: {
      mini_thumbnail: '25x25#',
      thumbnail: '75x75#',
      embedded: '280x280#'
    },
    path: ':rails_root/public/system/:attachment/:id/:style/:avatar_filename',
    url: '/system/:attachment/:id/:style/:avatar_filename'
  )

  validates_attachment(
    :avatar,
    content_type: { content_type: 'image/jpeg' },
    size: { in: 0..5.megabytes }
  )

  before_post_process :avatar_filename

  # Sets avatar filename in the database.
  def avatar_filename
    if avatar_content_type == 'image/jpeg'
      self.avatar_file_name = 'avatar.jpg' if avatar.present?
    end
  end

  # Sets avatar filename in the file system.
  Paperclip.interpolates :avatar_filename do |attachment, _style|
    attachment.instance.avatar_filename
  end
end
