class Attachment < ActiveRecord::Base
  mount_uploader :file, FileUploader

  belongs_to :story
  belongs_to :user
end
