
# Match -prod.prod
class MatchesProdProd
  def self.===(item)
    item.include?('-prod.prod')
  end
end