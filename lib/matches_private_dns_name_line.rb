
# Match a private_dns_name line
class MatchesPrivateDnsNameLine
  def self.===(item)
    item.include?('private_dns_name')
  end
end