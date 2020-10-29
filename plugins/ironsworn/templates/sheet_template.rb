module AresMUSH
  module Ironsworn
    class SheetTemplate < ErbTemplateRenderer
      
      attr_accessor :char
      
      def initialize(char)
        @char = char
        @markdown = MarkdownFormatter.new
        super File.dirname(__FILE__) + "/sheet.erb"
      end
     
      def stats
        format_three_per_line @char.ironsworn_stats
      end

      def approval_status
        if (char.on_roster?)
          status = "%xb%xh#{t('ironsworn.rostered')}%xn"
        elsif (char.is_npc?)
          status = "%xb%xh#{t('ironsworn.npc')}%xn"
        elsif (char.idled_out?)
          status = "%xr%xh#{t('ironsworn.idled_out', :status => char.idled_out_reason)}%xn"
        elsif (!char.is_approved?)
          status = "%xr%xh#{t('ironsworn.unapproved')}%xn"
        else
          status = "%xg%xh#{t('ironsworn.approved')}%xn"
        end
        status
      end

      def status
        m_lbl = left("%xhMomentum%xn:", 11)
        m_val = left("%xh#{@char.ironsworn_momentum}%xn", 9)
        h_lbl = left("%xhHealth%xn:", 11)
        h_val = left("%xh#{@char.ironsworn_health}%xn/%xh5%xn", 9)
        s_lbl = left("%xhSpirit%xn:", 11)
        s_val = left("%xh#{@char.ironsworn_spirit}%xn/%xh5%xn", 9)
        sp_lbl= left("%xhSupply:", 11)
        sp_val= "%xh#{Game.master.ironsworn_supply}%xn/%xh5%xn"

        "\n#{m_lbl}#{m_val}#{h_lbl}#{h_val}#{s_lbl}#{s_val}#{sp_lbl}#{sp_val}"
      end

      def assets
        @char.ironsworn_assets.to_a.sort_by { |a| a.name }
          .each_with_index
            .map do |a, i| 
              asset = Ironsworn.get_asset(a.name)
              steps = asset['steps']
              max_health = asset['max_health']
              step1 = "\n* #{steps[0]}"
              step2 = a.rating >= 2 ? "\n* #{steps[1]}" : ""
              step3 = a.rating >= 3 ? "\n* #{steps[2]}" : "" 
              health_name = asset['category'] == 'Companion' ? "Health" : "Integrity";
              health = max_health ? ", %xh#{health_name} #{a.health}%xn/%xh#{max_health}%xn" : ""
	      prereq = asset['prereq'] ? "\n%xh#{asset['prereq']}%xn" : ""
              @markdown.to_mush "\n%xh#{a.name}%xn (#{asset['category']}#{health}) %xh#{a.note}%xn#{prereq}#{step1}#{step2}#{step3}"
        end
      end

      def progress(ticks, max)
        progress = ticks / 4
        ticks = ticks % 4;

        chars = (1..max+1).map { |i| return i > progress ? "." : (i < progress ? "@" : String(ticks))}
        "[#{chars}]"
      end

      def legacies
        b_lbl = left("\n%xhBonds%xn:", 11)
        b_prg = self.progress(@char.ironsworn_legacy_bonds, 22)
        q_lbl = left("\n%xhQuests%xn:", 11)
        q_prg = self.progress(@char.ironsworn_legacy_quests, 22)
        d_lbl = left("\n%xhDiscoveries%xn:", 11)        
        d_prg = self.progress(@char.ironsworn_legacy_discoveries, 22)
        "#{b_lbl}#{b_prg}#{q_lbl}#{q_prg}#{d_lbl}#{d_prg}"
      end

      def format_three_per_line(list)
        list.to_a.sort_by { |a| a.name }
          .each_with_index
            .map do |a, i| 
              linebreak = i % 3 == 0 ? "\n" : ""
              title = left("#{a.name}:", 13)
              rating = left(a.rating, 13)
              "#{linebreak}%xh#{title}%xn#{rating}"
        end
      end
    end
  end
end
