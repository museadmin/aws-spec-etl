
# Match cloudfront
class MatchesCloudfront
  def self.===(item)
    item.include?('cloudfront ')
  end
end