class ShopifyService
  def generate_token(shop, client_id, client_secret, code)
    conn = Faraday.new(
      url: "https://#{shop}/admin/oauth/access_token",
      headers: { 'Content-Type' => 'application/json' }
    )
    conn.post do |req|
      req.body = { client_id: client_id, client_secret: client_secret, code: code }.to_json
    end
  end

  def get_collections(client)
    query = client.parse <<-'GRAPHQL'
    query($first: Int!) {
      collections(first: $first) {
        edges {
          node {
            id
            title
            descriptionHtml
          }
        }
      }
    }
    GRAPHQL

    response = client.query(query, variables: { first: 10 })
  end


  def get_collection_name(client, product_id)
    query = client.parse <<~GRAPHQL
      query($productId: ID!) {
        product(id: $productId) {
          collections(first: 10) {
            nodes {
              id
              title
            }
          }
        }
      }
    GRAPHQL
    variables = {
        productId: "gid://shopify/Product/#{product_id}"
      }

    client.query(query, variables: variables)
  end
end