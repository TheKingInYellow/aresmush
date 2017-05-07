module AresMUSH

  module Idle
    class IdleSetCmd
      include CommandHandler
      
      attr_accessor :name, :status

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)
        self.name = titlecase_arg(args.arg1)
        self.status = titlecase_arg(args.arg2)
      end
      
      def required_args
        {
          args: [ self.name, self.status ],
          help: 'idle'
        }
      end
      
      
      def check_can_manage
        return nil if Idle.can_idle_sweep?(enactor)
        return t('dispatcher.not_allowed')
      end
      
      def check_action
        actions = [ 'Nothing', 'Dead', 'Gone', 'Npc' ]
        return t('idle.use_roster_cmd') if self.status == 'Roster'
        
        return t('idle.invalid_action', :actions => actions.join(" ")) if !actions.include?(self.status)
        return nil
      end
            
      def handle
        ClassTargetFinder.with_a_character(self.name, client, enactor) do |model|

          if (model.on_roster?)
            client.emit_failure t('idle.use_roster_cmd')
            return
          end
          if (model.is_npc?)
            client.emit_failure t('idle.use_npc_cmd')
            return
          end
          
          if (self.status == 'Nothing')
            model.update(idle_state: nil)
          elsif (self.status == 'Npc')
            model.update(is_npc: true)
          else
            model.update(idle_state: self.status)
          end

          # Reset their password and handle
          Login::Api.set_random_password(model)
          if (model.handle)
            model.handle.delete
          end
          
          client.emit_success t('idle.idle_status_set', :name => self.name, :status => self.status)
        end
      end
    end
  end
end