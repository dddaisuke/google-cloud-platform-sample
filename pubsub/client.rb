require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'
require 'base64'

client = Google::APIClient.new(
  :application_name => 'Example Ruby application',
  :application_version => '1.0.0'
)

# use pkc12
key = Google::APIClient::KeyUtils.load_from_pkcs12('client.p12', '[PASSWORD]')
client.authorization = Signet::OAuth2::Client.new(
  :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
  :audience => 'https://accounts.google.com/o/oauth2/token',
  :scope => ['https://www.googleapis.com/auth/pubsub','https://www.googleapis.com/auth/cloud-platform'],
  :issuer => '[YOU]@developer.gserviceaccount.com',
  :signing_key => key)
client.authorization.fetch_access_token!

# use OAuth 2.0
# client_secrets = Google::APIClient::ClientSecrets.load
#
# flow = Google::APIClient::InstalledAppFlow.new(
#   :client_id => client_secrets.client_id,
#   :client_secret => client_secrets.client_secret,
#   :scope => ['https://www.googleapis.com/auth/pubsub','https://www.googleapis.com/auth/cloud-platform']
# )
#
# client.authorization = flow.authorize

pubsub = client.discovered_api('pubsub', 'v1beta2')

# Make an API call.
result = client.execute(
  :api_method => pubsub.projects.topics.publish,
  :parameters => {
    'topic' => 'projects/[PROJECT_NAME]/topics/[TOPIC_NAME]'
  },
  :body_object => {
    'messages' => [
      {
        'data' => Base64.encode64('message from app'),
        'attributes' => {
          'data1' => 'good',
          'data2' => 'bad',
        }
      }
    ]
  }
)

puts result.data.to_json
