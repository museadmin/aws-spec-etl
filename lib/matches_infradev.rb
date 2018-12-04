
# Match -infradev-
class MatchesInfradev
  def self.===(item)
    item.include?('-infradev-') || item.include?('-INFRADEV-')
  end
end