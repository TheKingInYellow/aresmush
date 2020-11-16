module AresMUSH
  module Ironsworn
    def self.stats
      Global.read_config('ironsworn', 'stats')
    end

    def self.assets
      Global.read_config('ironsworn', 'assets')
    end
  
    def self.get_asset(name)
      return Ironsworn.assets.select { |a| a['name'].downcase == name.downcase }.first
    end

    def self.is_valid_status_name?(name)
      return true if ["health", "momentum", "spirit", "supply"].include?(name)
      return false
    end

    def self.is_valid_stat_name?(name)
      return true if Ironsworn.stats.any? { |s| s['name'].downcase == name.downcase }
      return false
    end
 
    def self.is_valid_asset_name?(name)
      return true if Ironsworn.assets.any? { |s| s['name'].downcase == name.downcase }
      return false
    end

    def self.asset_has_health?(name)
      return true if Ironsworn.assets.any? { |s| s['name'].downcase == name.downcase && s['max_health'] }
      return false
    end

    def self.can_manage_abilities?(actor)
      return false if !actor
      actor.has_permission?("manage_apps")
    end

    def self.stat_rating(char, stat_name)
      charac = Ironsworn.find_stat(char, stat_name)
      charac ? charac.rating : 0
    end

    def self.asset_rating(char, asset_name)
      ass = Ironsworn.find_asset(char, asset_name)
      ass ? ass.rating : 0
    end

    def self.asset_note(char, asset_name)
      ass = Ironsworn.find_asset(char, asset_name)
      ass ? ass.note : ""
    end

    def self.asset_health(char, asset_name)
      ass = Ironsworn.find_asset(char, asset_name)
      ass ? ass.health : ""
    end

    def self.find_stat(char, stat_name)
      name_downcase = stat_name.downcase
      char.ironsworn_stats.select { |a| a.name.downcase == name_downcase }.first
    end

    def self.find_asset(char, asset_name)
      name_downcase = asset_name.downcase
      char_asset = char.ironsworn_assets.select { |a| a.name.downcase == name_downcase }.first
      return char_asset if char_asset
      IronswornAsset.all.select { |a| a.name.downcase == name_downcase }.first
    end
  
    def self.set_stat(char, stat_name, rating)
      charac = Ironsworn.find_stat(char, stat_name)
      
      if (charac && rating < 1)
        charac.delete
        return
      end
      
      if (charac)
        charac.update(rating: rating)
      else
        IronswornStat.create(name: stat_name, rating: rating, character: char)
      end
    end

    def self.set_asset_rating(char, asset_name, rating)
      charac = Ironsworn.find_asset(char, asset_name)
      
      if (charac && rating < 1)
        charac.delete
        return
      end
      
      if (charac)
        charac.update(rating: rating)
      else
        asset = Ironsworn.get_asset(asset_name)
        IronswornAsset.create(name: asset_name, rating: rating, character: char, health: asset['max_health'])
      end
    end

    def self.set_asset_note(char, asset_name, note)
      charac = Ironsworn.find_asset(char, asset_name)
      
      if (charac)
        charac.update(note: note)
      end
    end

    def self.set_asset_health(char, asset_name, health)
      charac = Ironsworn.find_asset(char, asset_name)
      
      if (charac)
        charac.update(health: health)
      end
    end

    def self.get_stat(char, stat)
      if stat.is_a? Integer
        return stat.to_i
      end

      asset = Ironsworn.get_asset(stat)
      if asset != nil
        rating = asset['max_health'] ? Ironsworn.find_asset(char, stat).health : nil
      elsif Ironsworn.is_valid_stat_name?(stat)
        rating = Ironsworn.find_stat(char, stat).rating
      elsif stat.downcase == "momentum"
        rating = char.ironsworn_momentum
      elsif stat.downcase == "health"
        rating = char.ironsworn_health
      elsif stat.downcase == "spirit"
        rating = char.ironsworn_spirit
      elsif stat.downcase == "supply"
        rating = Game.master.ironsworn_supply
      else
        rating = nil
      end
      rating
    end

    def self.rating_name(roll, action1, action2)
      matching = action1 == action2 ? "matching " : ""
      if (roll > action1 && roll > action2)
        result = "strong hit"
      elsif (roll > action1 || roll > action2)
        result = "weak hit"
      else
        result = "miss"
      end

      return "#{matching}#{result}"
    end

    def self.emit_results(message, client, room, is_private)
      if (is_private)
        client.emit message
      else
        room.emit_ooc message
        channel = Global.read_config("ironsworn", "roll_channel")
        if (channel)
          Channels.send_to_channel(channel, message)
        end

        if (room.scene)
          Scenes.add_to_scene(room.scene, message)
        end

      end
      Global.logger.info "Ironsworn roll results: #{message}"
    end

    def self.determine_roll_result(enactor, roll_str)
       match = /^(?<ability>[^\+\-]+)\s*(?<modifier>[\+\-]\s*\d+)?$/.match(roll_str)
       return nil if !match

       ability = match[:ability].strip
       modifier = match[:modifier].nil? ? 0 : match[:modifier].gsub(/\s+/, "").to_i

       rating = Ironsworn.get_stat(enactor, ability)
       return nil if !rating
       
       if (ability.is_a? Integer)
         progress = true
         die = 0
       else
         die = 1 + rand(6)
       end

       mods = modifier + rating
       roll = die + mods
       action1 = rand(10)+1
       action2 = rand(10)+1
       result = Ironsworn.rating_name(roll, action1, action2)
       return t(progress ? 'ironsworn.progress_roll_results': 'ironsworn.roll_results', 
         :name => enactor.name, 
         :result => result, 
         :roll => roll, 
         :roll_str => roll_str, 
         :action1 => action1, 
         :action2 => action2, 
         :mods => mods)
    end
 
    def self.determine_web_roll_result(request, enactor)
      roll_str = request.args[:roll_string]
      
      message = Ironsworn.determine_roll_result(enactor, roll_str)
      return { message: message } 
    end
   
    def self.find_progress(char, name)
      return char.ironsworn_progress.select { |a| a.name.downcase == name.downcase }.first    
    end

    def self.convert_progress_rank(rank)
      ranks = ["Troublesome", "Dangerous", "Formidable", "Extreme", "Epic"]
      if (rank.is_a? Integer) 
        if (rank >= 0 && rank <= 4)
          return ranks[rank]
        else
          return nil
        end
      else
        return ranks.index(rank)
      end
    end

    def self.get_progress_ticks_per_rank(rank)
      rank_ticks = [12, 8, 4, 2, 1];
      rank_ticks[rank]
    end

  end
end
