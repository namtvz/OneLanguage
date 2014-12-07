class Attachment < ActiveRecord::Base
  has_attached_file :data
  validates_attachment_content_type :data, content_type: ["application/pdf", "image/jpeg", "image/gif", "image/png"]

  belongs_to :user
  belongs_to :channel

  def full_url
    data.url
  end
end
