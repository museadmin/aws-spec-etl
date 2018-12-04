
# Match image_id
class MatchesImageId
  def self.===(item)
    item.include?(':image_id')
  end
end