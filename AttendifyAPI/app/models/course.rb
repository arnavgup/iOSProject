class Course < ApplicationRecord
    has_many :enrollments
    belongs_to :professor

    scope :active, -> {where(active: true)}
    scope :inactive, -> {where(active: false)}
    scope :alphabetical, -> {order(:semester_year)}
    
end
