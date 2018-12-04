
# Match mfa_serial
class MatchesMfaSerial
  def self.===(item)
    item.include?('mfa_serial')
  end
end