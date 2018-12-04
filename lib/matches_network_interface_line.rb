
# Match a Network Interface line
class MatchesNetworkInterfaceLine
  def self.===(item)
    item.include?('have_network_interface')
  end
end