module AresMUSH
  class Character < Ohm::Model
    collection :ironsworn_stats, "AresMUSH::IronswornStat"
    collection :ironsworn_assets, "AresMUSH::IronswornAsset"

    attribute :ironsworn_health, :type => DataType::Integer, :default => 5
    attribute :ironsworn_spirit, :type => DataType::Integer, :default => 5
    attribute :ironsworn_momentum, :type => DataType::Integer, :default => 2
 
    before_delete :delete_ironsworn_collections
    
    def delete_ironsworn_collections
      [ self.ironsworn_stats, self.ironsworn_assets ].each do |list|
        list.each do |a|
          a.delete
        end
      end
    end
  end

  class IronswornStat < Ohm::Model
    include ObjectModel
    
    attribute :name
    attribute :rating, :type => DataType::Integer
    reference :character, "AresMUSH::Character"
    index :name
  end

  class IronswornAsset < Ohm::Model
    include ObjectModel
    
    attribute :name
    attribute :note
    attribute :rating, :type => DataType::Integer
    attribute :health, :type => DataType::Integer
    reference :character, "AresMUSH::Character"
    index :name
  end

  class Game < Ohm::Model
    attribute :ironsworn_supply, :type => DataType::Integer, :default => 5
  end

end
