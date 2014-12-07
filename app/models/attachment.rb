class Attachment < ActiveRecord::Base
  has_attached_file :data
  do_not_validate_attachment_file_type :data

  belongs_to :user
  belongs_to :channel

  def full_url
    data.url
  end
end
