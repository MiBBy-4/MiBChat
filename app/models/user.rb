class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  scope :all_except, ->(user) { where.not(id: user) }
  after_create_commit { broadcast_append_to 'users' }
  after_update_commit { broadcast_update }
  has_many :messages
  has_many :participants
  has_one_attached :avatar

  after_commit :add_default_avatar, on: %i[create update]

  enum status: %i[offline away online]

  def avatar_thumbnail
    avatar.variant(resize_to_limit: [150, 150]).processed
  end

  def chat_avatar
    avatar.variant(resize_to_limit: [50, 50]).processed
  end

  def broadcast_update
    broadcast_replace_to 'user_status', partial: 'users/status', user: self    
  end

  def status_to_css
    case status
    when 'online'
      'bg-success'
    when 'away'
      'bg-warning'
    when 'offline'
      'bg-dark'
    else
      'bg-danger'
    end
  end

  private

  def add_default_avatar
    return if avatar.attached?

    avatar.attach(
      io: File.open(Rails.root.join('app', 'assets', 'images', 'default_profile.jpg')),
      filename: 'default_profile.jpg',
      content_type: 'image/jpg'
    )
  end
end
