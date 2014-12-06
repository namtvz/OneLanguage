class Attachment < ActiveRecord::Base
  has_attached_file :file
  validates_attachment_content_type :file, content_type: ["application/pdf", "image/jpeg", "image/gif"]
end
