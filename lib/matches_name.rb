
# Match name
class MatchesName
  def self.===(item)
    item.include?('name')
  end
end