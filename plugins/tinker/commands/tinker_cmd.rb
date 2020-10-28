module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
    def get_abils(char)
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


      def handle
        a = self.get_abils(enactor)
        client.emit_raw "#{a}"
        client.emit_success "Done!"
      end

    end
  end
end
