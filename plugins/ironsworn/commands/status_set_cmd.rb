module AresMUSH    
  module Ironsworn
    class StatusSetCmd
      include CommandHandler
      
      attr_accessor :target_name, :status_name, :rating
      
      def parse_args
        # Admin version
        if (cmd.args =~ /\//)
          args = cmd.parse_args(ArgParser.arg1_slash_arg2_equals_arg3)
          self.target_name = titlecase_arg(args.arg1)
          self.status_name = downcase_arg(args.arg2)
          self.rating = integer_arg(args.arg3)
        else
          args = cmd.parse_args(ArgParser.arg1_equals_arg2)
          self.target_name = enactor_name
          self.status_name = downcase_arg(args.arg1)
          self.rating = integer_arg(args.arg2)
        end
      end
      
      def required_args
        [self.target_name, self.status_name, self.rating]
      end
           
      def check_valid_status_name              
        return t('ironsworn.invalid_status_name') if !Ironsworn.is_valid_status_name?(self.status_name)
        return nil
      end

      def check_valid_rating
        return t('ironsworn.invalid_status_rating') if (self.status_name == "momentum" && (self.rating < -6 || self.rating > 10))
        return t('ironsworn.invalid_status_rating') if (self.status_name != "momentum" && (self.rating < 0 || self.rating > 5))
        return nil
      end
      
      def check_can_set
        return nil if enactor_name == self.target_name
        return nil if Ironsworn.can_manage_abilities?(enactor)
        return t('dispatcher.not_allowed')
      end     
      
      def handle
        if (self.status_name == "supply")
          Game.master.update(ironsworn_supply: self.rating)
          return client.emit_success t('ironsworn.status_set')
        end

        ClassTargetFinder.with_a_character(self.target_name, client, enactor) do |model|
          case self.status_name
            when "health"
              model.update(ironsworn_health: self.rating)
            when "spirit"
              model.update(ironsworn_spirit: self.rating)
            when "momentum"
              model.update(ironsworn_momentum: self.rating)
          end
          client.emit_success t('ironsworn.status_set')
        end
      end
    end
  end
end
