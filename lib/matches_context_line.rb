
# Match a context line
class MatchesContextLine
  def self.===(item)
    item.include?('context ')
  end
end