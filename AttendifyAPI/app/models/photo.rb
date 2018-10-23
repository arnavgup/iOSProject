class Photo < ApplicationRecord

    scope :for_andrew_id, -> (id){ where("andrew_id = ?", id) }
end
