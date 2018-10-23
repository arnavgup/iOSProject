class Course < ApplicationRecord
    has_many :enrollments
    belongs_to :professor

    scope :active, -> {where(active: true)}
    scope :inactive, -> {where(active: false)}
    scope :alphabetical, -> {order(:semester_year)}
    scope :getByYear, -> (year) (professorID) {where('semester_year=?', year)}
    scope :forProfessor, -> (professorID) {where ('professor_id = ?', professorID)}
end
