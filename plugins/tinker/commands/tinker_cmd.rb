module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        char = Character.named('Davu')
        progress_name = 'TheAce'
        client.emit Ironsworn.find_progress(char, progress_name) != nil
        client.emit Ironsworn.is_valid_asset_name?(progress_name)
        client.emit Ironsworn.is_valid_stat_name?(progress_name)
        client.emit_success "Done!"
      end

    end
  end
end
