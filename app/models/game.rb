class Game < ActiveRecord::Base
  belongs_to :creator, class_name: "User"
  belongs_to :participant, class_name: "User"
  
  def players
    [creator, participant]
  end
  
end
