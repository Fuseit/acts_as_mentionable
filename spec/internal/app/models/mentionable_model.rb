class MentionableModel < ActiveRecord::Base
  acts_as_mentionable :username
end
