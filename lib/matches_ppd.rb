
# Match -ppd-
class MatchesPpd
  def self.===(item)
    item.include?('-ppd-')
  end
end