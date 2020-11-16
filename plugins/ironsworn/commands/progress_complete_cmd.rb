module AresMUSH
  module Ironsworn
    class ProgressCompleteCmd
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
        return t('ironsworn.invalid_progress_name') if !self.progress
        return t('ironsworn.invalid_progress_name') if self.progress.completed
        return nil
      end

      def check_can_set
        return nil if enactor_name == self.target_name
        return nil if Ironsworn.can_manage_abilities?(enactor)
        return t('dispatcher.not_allowed')
      end
 
      def handle
        client.emit_success t('ironsworn.progress_completed')  
        self.progress.update(completed: true)
      end
    end
  end
end
