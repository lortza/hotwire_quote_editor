class User < ApplicationRecord
  # We're skipping a lot of normal devise functinality here because it's a
  # tiny demo style app running off of seed data. Don't copy these settings
  # for a normal application with multiple users.
  devise :database_authenticatable, :validatable

end
