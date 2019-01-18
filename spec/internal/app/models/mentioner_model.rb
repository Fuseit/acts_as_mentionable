class MentionerModel < ActiveRecord::Base
  acts_as_mentioner :body
end
