require "configcat-openfeature-provider"
require "date"

# Info level logging helps to inspect the feature flag evaluation process.
# Use the default Warning level to avoid too detailed logging in your application.
ConfigCat.logger.level = Logger::INFO

# Configure the OpenFeature API with the ConfigCat provider.
OpenFeature::SDK.configure do |config|
  config.set_provider(ConfigCat::OpenFeature::Provider.new(
    sdk_key: "PKDVCLf-Hq-h-kCzMp-L7Q/HhOWfwVtZ0mb30i9wi17GQ",
    # Configure the ConfigCat SDK.
    options: ConfigCat::ConfigCatOptions.new(
      polling_mode: ConfigCat::PollingMode.auto_poll(poll_interval_seconds: 5),
      offline: false
    )
  ))
end

# Create a client.
client = OpenFeature::SDK.build_client

# Create evaluation context.
evaluation_context = OpenFeature::SDK::EvaluationContext.new(
  OpenFeature::SDK::EvaluationContext::TARGETING_KEY => "<SOME USERID>",
  "Email" => "configcat@example.com",
  "Country" => "CountryID",
  "Version" => "1.0.0"
)

# Evaluate feature flag.
flag_details = client.fetch_boolean_details(
  flag_key: "isPOCFeatureEnabled",
  default_value: false,
  evaluation_context: evaluation_context
)

puts(JSON.dump(flag_details))
