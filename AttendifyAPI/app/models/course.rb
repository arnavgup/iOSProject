class Course < ApplicationRecord
    has_many :enrollments
    belongs_to :professor
end
