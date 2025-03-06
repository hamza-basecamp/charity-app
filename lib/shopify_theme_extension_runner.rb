class ShopifyThemeExtensionRunner
  def self.run
    system("shopify theme serve --host=#{ENV['BASE_URL']}")
  end
end
