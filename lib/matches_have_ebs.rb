
# Match a have_ebs line
class MatchesHaveEbs
  def self.===(item)
    item.include?('have_ebs')
  end
end