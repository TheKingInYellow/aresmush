module AresMUSH    
  module Ironsworn
    class ProgressAddCmd
      include CommandHandler
      
      attr_accessor :target_name, :progress_name, :rank, :type, :char, :rank_val, :note
      
      def parse_args
        args = cmd.parse_args(/(?<arg1>[^\/=]+)\/?(?<arg2>[^=]+)?=(?<arg3>[^,]+),(?<arg4>[^,]+),?(?<arg5>.+)?/)
     
        if (args.arg2 != nil)
          self.target_name = titlecase_arg(args.arg1)
          self.progress_name = titlecase_arg(args.arg2)
        else
          self.target_name = enactor_name
          self.progress_name = titlecase_arg(args.arg1)
        end
        self.rank = titlecase_arg(args.arg3)
        self.type = titlecase_arg(args.arg4)
        self.note = args.arg5

        self.char = Character.named(self.target_name)
        self.rank_val = Ironsworn.convert_progress_rank(self.rank)
      end
      
      def required_args
        [self.target_name, self.progress_name, self.rank, self.type]
      end
           
      def check_target_name
        return t('ironsworn.invalid_char_name') if !self.char
        return nil
      end
      
      def check_valid_progress_name
        return t('ironsworn.invalid_progress_name') if Ironsworn.find_progress(self.char, self.progress_name)
        return t('ironsworn.invalid_progress_name') if Ironsworn.is_valid_asset_name?(self.progress_name)
        return t('ironsworn.invalid_progress_name') if Ironsworn.is_valid_stat_name?(self.progress_name)
        return t('ironsworn.invalid_progress_name') if ["Bonds", "Quests", "Discoveries"].include?(self.progress_name)
        return nil
      end

      def check_valid_type
        return t('ironsworn.invalid_progress_type') if !["Foe", "Vow", "Background", "Bond", "Expedition"].include?(self.type)
        return nil
      end

      def check_valid_rank
        return t('ironsworn.invalid_progress_rank') if !self.rank_val
        return nil
      end
      
      def check_can_set
        return nil if enactor_name == self.target_name
        return nil if Ironsworn.can_manage_abilities?(enactor)
        return t('dispatcher.not_allowed')
      end     
      
      def handle
        IronswornProgress.create(
          name: self.progress_name,
          type: self.type,
          ticks: 0,
          character: self.char,
          note: self.note,
          rank: self.rank_val,
          completed: false
        )
        client.emit_success t('ironsworn.progress_added')
      end
    end
  end
end
