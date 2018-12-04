
# Match role_arn
class MatchesRoleArn
  def self.===(item)
    item.include?('role_arn')
  end
end