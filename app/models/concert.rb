class Concert < ActiveRecord::Base
  belongs_to :access
  belongs_to :infomation
  serialize :content
end
