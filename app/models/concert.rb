class Concert < ActiveRecord::Base
  belongs_to :access
  belongs_to :infomation
  serialize :content
  serialize :program
  serialize :name
end
