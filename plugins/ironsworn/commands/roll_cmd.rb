module AresMUSH    
  module Ironsworn
    class RollCmd
      include CommandHandler
  
      attr_accessor :roll_str, :private_roll
      
      def parse_args
        self.roll_str = titlecase_arg(cmd.args)
        self.private_roll = cmd.switch_is?("private")
      end
            
      def required_args
        [self.roll_str]
      end
      
      def handle
        message = Ironsworn.determine_roll_result(enactor, self.roll_str)
        if (message)
          Ironsworn.emit_results message, client, enactor_room, self.private_roll
        else
          client.emit t('ironsworn.invalid_roll')
        end
      end
    end
  end
end
