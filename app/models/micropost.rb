class Micropost < ApplicationRecord
  belongs_to :user
  default_scope ->{order created_at: :desc}
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true,
    length: {maximum: Settings.micropost.content.max_length}
  validate :picture_size

  private
  # Validates the size of an uploaded picture.
  def picture_size
    return unless picture.size > Settings.micropost.picture.max_size.megabytes
    errors.add(:picture, :picture_too_large)
  end
end
