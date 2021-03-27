module AresMUSH    
  module Ironsworn
    class AssetSetCmd
      include CommandHandler
      
      attr_accessor :target_name, :asset_name, :rating
      
      def parse_args
        # Admin version
        if (cmd.args =~ /\//)
          args = cmd.parse_args(ArgParser.arg1_slash_arg2_equals_arg3)
          self.target_name = titlecase_arg(args.arg1)
          self.asset_name = titlecase_arg(args.arg2)
          self.rating = integer_arg(args.arg3)
        else
          args = cmd.parse_args(ArgParser.arg1_equals_arg2)
          self.target_name = enactor_name
          self.asset_name = titlecase_arg(args.arg1)
          self.rating = integer_arg(args.arg2)
        end
      end
      
      def required_args
        [self.target_name, self.asset_name, self.rating]
      end
           
      def check_valid_rating
        return nil if Ironsworn.can_manage_abilities?(enactor) # Admin can set any rating.
        return nil if !self.rating
        return t('ironsworn.invalid_asset_rating') if self.rating > 5 || self.rating < 0
        if (!enactor.is_approved?)
          return 1
        end
        return nil
      end
      
      def check_valid_asset_name
        return t('ironsworn.invalid_asset_name') if !Ironsworn.is_valid_asset_name?(self.asset_name)
        return nil
      end
      
      def check_can_set
        return nil if enactor_name == self.target_name
        return nil if Ironsworn.can_manage_abilities?(enactor)
        return t('dispatcher.not_allowed')
      end     
      
      def handle
        ClassTargetFinder.with_a_character(self.target_name, client, enactor) do |model|
	  Ironsworn.set_asset_rating(model, self.asset_name, self.rating)
          client.emit_success t('ironsworn.asset_set')
        end
      end
    end
  end
end
