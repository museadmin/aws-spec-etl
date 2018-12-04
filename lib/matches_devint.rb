
# Match -devint-
class MatchesDevint
  def self.===(item)
    item.include?('-devint-') || item.include?('-DEVINT-')
  end
end