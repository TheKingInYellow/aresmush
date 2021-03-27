module AresMUSH    
  module Ironsworn
    class AssetHealthCmd
      include CommandHandler
      
      attr_accessor :target_name, :asset_name, :health
      
      def parse_args
        # Admin version
        if (cmd.args =~ /\//)
          args = cmd.parse_args(ArgParser.arg1_slash_arg2_equals_arg3)
          self.target_name = titlecase_arg(args.arg1)
          self.asset_name = titlecase_arg(args.arg2)
          self.health = integer_arg(args.arg3)
        else
          args = cmd.parse_args(ArgParser.arg1_equals_arg2)
          self.target_name = enactor_name
          self.asset_name = titlecase_arg(args.arg1)
          self.health = integer_arg(args.arg2)
        end
      end
      
      def required_args
        [self.target_name, self.asset_name, self.health]
      end
           
      def check_valid_asset_name
        asset = Ironsworn.get_asset(self.asset_name)
        return t('ironsworn.invalid_asset_name') if !asset || !asset['max_health']
        return nil
      end

      def check_valid_health
        asset = Ironsworn.get_asset(self.asset_name)
        return t('ironsworn.invalid_asset_health') if (self.health > asset['max_health'])
        return nil
      end
      
      def check_can_set
        return nil if enactor_name == self.target_name
        return nil if Ironsworn.can_manage_abilities?(enactor)
        return t('dispatcher.not_allowed')
      end     
      
      def handle
        ClassTargetFinder.with_a_character(self.target_name, client, enactor) do |model|
	  Ironsworn.set_asset_health(model, self.asset_name, self.health)
          client.emit_success t('ironsworn.asset_set')
        end
      end
    end
  end
end
