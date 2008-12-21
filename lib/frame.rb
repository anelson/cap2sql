class Frame < ActiveRecord::Base
    belongs_to :capfile
    has_many :frame_blobs
    has_many :frame_fields
end

