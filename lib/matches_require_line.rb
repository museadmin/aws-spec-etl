
# Match a require line
class MatchesRequireLine
  def self.===(item)
    item.include?('require')
  end
end