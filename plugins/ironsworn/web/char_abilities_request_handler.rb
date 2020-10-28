module AresMUSH
  module Ironsworn
    class CharAbilitiesRequestHandler
      def handle(request)
        char = Character.find_one_by_name request.args[:id]
        enactor = request.enactor
        
        if (!char)
          return []
        end

        error = Website.check_login(request, true)
        return error if error
        
         abilities = []
        char.ironsworn_stats.each do |s|
          abilities << s.name
        end
        assets = []
        shared_assets = []
        IronswornAsset.all.each do |a|
          asset = Ironsworn.get_asset(a.name)
          if (asset['max_health'])
            if (a.character == char)
              assets << a.name
            elsif (asset['category'] != "Path" && asset['category'] != "Companion")
              shared_assets << a.name 
            end
          end
        end
        assets.each do |a|
          abilities << a
        end

        abilities << "Momentum"
        abilities << "Health"
        abilities << "Spirit"
        abilities << "Supply"

        shared_assets.each do |a|
          abilities << a
        end

        return abilities
      end
    end
  end
end
