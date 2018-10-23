class Professor < ApplicationRecord
    has_many :courses
    scope :alphabetical, -> { order(:last_name, :first_name) }

    def name
        return first_name + " " + last_name
    end

end
