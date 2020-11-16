module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.has_permission?("tinker")
        return nil
      end
      
      def handle
        char = Character.named('Toran')
        char.update(ironsworn_legacy_bonds: 0)
        client.emit_success "Done!"
      end

    end
  end
end
