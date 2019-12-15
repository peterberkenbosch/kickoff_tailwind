class User < ApplicationRecord
  devise :masqueradable, :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  has_person_name
end
