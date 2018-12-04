
# Match source_profile
class MatchesSourceProfile
  def self.===(item)
    item.include?('source_profile')
  end
end