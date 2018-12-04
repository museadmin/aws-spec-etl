
# Match a private_ip_address line
class MatchesPrivateIpAddressLine
  def self.===(item)
    item.include?('private_ip_address')
  end
end