
# Match instance_id
class MatchesInstanceId
  def self.===(item)
    item.include?(':instance_id')
  end
end