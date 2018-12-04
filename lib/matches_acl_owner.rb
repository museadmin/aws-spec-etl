
# Match acl_owner
class MatchesAclOwner
  def self.===(item)
      item.include?("its(:acl_owner) { should eq '' }")
    end
end
