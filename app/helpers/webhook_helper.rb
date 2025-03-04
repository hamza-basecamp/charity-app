module WebhookHelper
  def self.verify_webhook(data, hmac_header)
    require 'active_support/security_utils'
    require 'base64'
    calculated_hmac = Base64.strict_encode64(OpenSSL::HMAC.digest('sha256', ENV['SHOPIFY_API_SECRET'], data))
    ActiveSupport::SecurityUtils.secure_compare(calculated_hmac, hmac_header)
  end
end
