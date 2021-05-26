module AresMUSH
  module Ironsworn
    class ProgressMarkCmd
      include CommandHandler

      attr_accessor :target_name, :progress_name, :char, :progress, :extra

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_slash_optional_arg2)

        if (args.arg2 != nil)
          self.target_name = titlecase_arg(args.arg1)
          self.progress_name = titlecase_arg(args.arg2)
        else
          self.target_name = enactor_name
          self.progress_name = titlecase_arg(args.arg1)
        end
        self.extra = cmd.switch_is?("extra")
        self.char = Character.named(self.target_name)
        self.progress = self.char ? Ironsworn.find_progress(self.char, self.progress_name) : nil
      end

      def required_args
        [self.target_name, self.progress_name]
      end

      def check_target_name
        return t('ironsworn.invalid_char_name') if !self.char
        return nil
      end

      def check_valid_progress_name
        return t('ironsworn.invalid_progress_mark') if !self.progress && !["Bonds", "Quests", "Discoveries"].include?(self.progress_name)
        return nil
      end

      def check_can_set
        return nil if enactor_name == self.target_name
        return nil if Ironsworn.can_manage_abilities?(enactor)
        return t('dispatcher.not_allowed')
      end

      def mark_progress
        if (self.extra)
          new_ticks = self.progress.ticks + (2*Ironsworn.get_progress_ticks_per_rank(self.progress.rank))
          client.emit_success t('ironsworn.progress_extra_marked')  
        else
          new_ticks = self.progress.ticks + Ironsworn.get_progress_ticks_per_rank(self.progress.rank)
          client.emit_success t('ironsworn.progress_marked')  
        end
        self.progress.update(ticks: new_ticks)
      end

      def handle
        if (self.progress_name == "Bonds")
          self.char.update(ironsworn_legacy_bonds: self.char.ironsworn_legacy_bonds + (extra ? 2 : 1))
        elsif (self.progress_name == "Quests")
          self.char.update(ironsworn_legacy_quests: self.char.ironsworn_legacy_quests + (extra ? 2 : 1))
        elsif (self.progress_name == "Discoveries")
          self.char.update(ironsworn_legacy_discoveries: self.char.ironsworn_legacy_discoveries + (extra ? 2 : 1))
        else
          return self.mark_progress
        end
 
        client.emit_success t(extra ? 'ironsworn.progress_extra_marked' : 'ironsworn.progress_marked')
      end
    end
  end
end
