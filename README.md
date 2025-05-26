# ConfigCat OpenFeature Provider for Ruby

[![Build Status](https://github.com/configcat/openfeature-ruby/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/configcat/openfeature-ruby/actions/workflows/ci.yml)
[![Gem version](https://badge.fury.io/rb/configcat-openfeature-provider.svg)](https://rubygems.org/gems/configcat-openfeature-provider)

This repository contains an OpenFeature provider that allows [ConfigCat](https://configcat.com) to be used with the [OpenFeature Ruby SDK](https://github.com/open-feature/ruby-sdk).

## Requirements
- Ruby >= 3.1

## Installation

```sh
gem install configcat-openfeature-provider
```

## Usage

The initializer of `ConfigCat::OpenFeature::Provider` takes the SDK key and an optional `ConfigCat::ConfigCatOptions` argument containing the additional configuration options for the [ConfigCat Ruby SDK](https://github.com/configcat/ruby-sdk):

```ruby
require "configcat-openfeature-provider"

# Configure the OpenFeature API with the ConfigCat provider.
OpenFeature::SDK.configure do |config|
  config.set_provider(ConfigCat::OpenFeature::Provider.new(
    sdk_key: "<YOUR-CONFIGCAT-SDK-KEY>",
    # Build options for the ConfigCat SDK.
    options: ConfigCat::ConfigCatOptions.new(
      polling_mode: ConfigCat::PollingMode.auto_poll,
      offline: false
    )))
end

# Create a client.
client = OpenFeature::SDK.build_client

# Evaluate feature flag.
flag_value = client.fetch_boolean_value(
  flag_key: "isMyAwesomeFeatureEnabled",
  default_value: false
)
```

For more information about all the configuration options, see the [Ruby SDK documentation](https://configcat.com/docs/sdk-reference/ruby/#creating-the-configcat-client).

## Need help?
https://configcat.com/support

## Contributing
Contributions are welcome. For more info please read the [Contribution Guideline](CONTRIBUTING.md).

## About ConfigCat
ConfigCat is a feature flag and configuration management service that lets you separate releases from deployments. You can turn your features ON/OFF using <a href="https://app.configcat.com" target="_blank">ConfigCat Dashboard</a> even after they are deployed. ConfigCat lets you target specific groups of users based on region, email or any other custom user attribute.

ConfigCat is a <a href="https://configcat.com" target="_blank">hosted feature flag service</a>. Manage feature toggles across frontend, backend, mobile, desktop apps. <a href="https://configcat.com" target="_blank">Alternative to LaunchDarkly</a>. Management app + feature flag SDKs.

- [Official ConfigCat SDKs for other platforms](https://github.com/configcat)
- [Documentation](https://configcat.com/docs)
- [Blog](https://configcat.com/blog)