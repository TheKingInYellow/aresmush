$:.unshift File.dirname(__FILE__)

module AresMUSH
  module Ironsworn

    def self.plugin_dir
      File.dirname(__FILE__)
    end

    def self.shortcuts
      Global.read_config("ironsworn", "shortcuts")
    end

    def self.get_cmd_handler(client, cmd, enactor)
      case cmd.root
      when "roll"
        return RollCmd
      when "sheet"
        return SheetCmd
      when "status"
        return StatusSetCmd
      when "stat"
        return StatSetCmd
      when "asset"
        case cmd.switch
        when nil
          return AssetSetCmd
        when "note", "name"
          return AssetNoteCmd
        when "health"
          return AssetHealthCmd
        end
      end
    end

    def self.get_event_handler(event_name)
      nil
    end

    def self.get_web_request_handler(request)
      case request.cmd
      when "charAbilities"
        return CharAbilitiesRequestHandler
      when "addSceneRoll"
        return AddSceneRollRequestHandler
      end
    end

  end
end
