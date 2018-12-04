
# Match -ft
class MatchesFt
  def self.===(item)
    item.include?('-ft') || item.include?('-FT-')
  end
end