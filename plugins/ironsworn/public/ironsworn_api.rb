module AresMUSH
  module Ironsworn

    def self.get_asset_info(a)
      asset_def = Ironsworn.get_asset(a.name)
      return {
        name: a.name,
        rating: a.rating,
        note: a.note,
        health: a.health,
        max_health: asset_def['max_health'],
        category: asset_def['category'],
        steps: asset_def['steps'].map { |s| Website.format_markdown_for_html(s) }
      }
    end

    def self.get_shared_assets(char)
      IronswornAsset.all
          .select { |a| a.character != char }
          .map { |k| self.get_asset_info(k) }
          .select { |ast| ast[:category] != "Path" && ast[:category] != "Companion" }
    end
    
    def self.get_web_sheet(char, viewer)
      {
        stats: (char.ironsworn_stats || {}).sort.map { |k| {
          name: k.name,
          rating: k.rating
        }},
        assets: (char.ironsworn_assets || {}).sort.map { 
          |k| self.get_asset_info(k)
        },
        assets_shared: self.get_shared_assets(char),
        momentum: char.ironsworn_momentum,
        health: char.ironsworn_health,
        spirit: char.ironsworn_spirit,
        supply: Game.master.ironsworn_supply,
        quests: char.ironsworn_legacy_quests,
        bonds: char.ironsworn_legacy_bonds,
        discoveries: char.ironsworn_legacy_discoveries
      }
    end
    
  end
end
