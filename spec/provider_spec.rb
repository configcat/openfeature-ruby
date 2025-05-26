# frozen_string_literal: true

RSpec.describe ConfigCat::OpenFeature::Provider do
  opts = ConfigCat::ConfigCatOptions.new(flag_overrides: ConfigCat::LocalFileFlagOverrides.new(
    File.join(File.dirname(__FILE__), "data/test_json_complex.json"),
    ConfigCat::OverrideBehaviour::LOCAL_ONLY
  ))
  provider = described_class.new(sdk_key: "localhost", options: opts)

  context "metadata" do
    it "metadata is defined" do
      expect(provider).to respond_to(:metadata)
      expect(provider.metadata).to respond_to(:name)
      expect(provider.metadata.name).to eq("ConfigCatProvider")
    end
  end

  context "eval" do
    it "boolean" do
      result = provider.fetch_boolean_value(flag_key: "enabledFeature", default_value: false)

      expect(result.value).to eq(true)
      expect(result.variant).to eq("v-enabled")
      expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::DEFAULT)
    end

    it "int" do
      result = provider.fetch_integer_value(flag_key: "intSetting", default_value: 0)

      expect(result.value).to eq(5)
      expect(result.variant).to eq("v-int")
      expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::DEFAULT)
    end

    it "numeric-int" do
      result = provider.fetch_number_value(flag_key: "intSetting", default_value: 0)

      expect(result.value).to eq(5)
      expect(result.variant).to eq("v-int")
      expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::DEFAULT)
    end

    it "double" do
      result = provider.fetch_float_value(flag_key: "doubleSetting", default_value: 0.0)

      expect(result.value).to eq(1.2)
      expect(result.variant).to eq("v-double")
      expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::DEFAULT)
    end

    it "numeric-double" do
      result = provider.fetch_number_value(flag_key: "doubleSetting", default_value: 0.0)

      expect(result.value).to eq(1.2)
      expect(result.variant).to eq("v-double")
      expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::DEFAULT)
    end

    it "string" do
      result = provider.fetch_string_value(flag_key: "stringSetting", default_value: "")

      expect(result.value).to eq("test")
      expect(result.variant).to eq("v-string")
      expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::DEFAULT)
    end

    it "object" do
      result = provider.fetch_object_value(flag_key: "objectSetting", default_value: {})

      expect(result.value).to eq({"bool_field" => true, "text_field" => "value"})
      expect(result.variant).to eq("v-object")
      expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::DEFAULT)
    end

    it "targeting" do
      ctx = OpenFeature::SDK::EvaluationContext.new(OpenFeature::SDK::EvaluationContext::TARGETING_KEY => "example@matching.com")
      result = provider.fetch_boolean_value(flag_key: "disabledFeature", default_value: false, evaluation_context: ctx)

      expect(result.value).to eq(true)
      expect(result.variant).to eq("v-disabled-t")
      expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::TARGETING_MATCH)
    end

    it "targeting-custom" do
      ctx = OpenFeature::SDK::EvaluationContext.new(
        OpenFeature::SDK::EvaluationContext::TARGETING_KEY => "example@matching.com",
        "custom-anything" => "something"
      )
      result = provider.fetch_boolean_value(flag_key: "disabledFeature", default_value: false, evaluation_context: ctx)

      expect(result.value).to eq(true)
      expect(result.variant).to eq("v-disabled-t")
      expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::TARGETING_MATCH)
    end

    it "key not found" do
      result = provider.fetch_boolean_value(flag_key: "non-existing", default_value: false)

      expect(result.value).to eq(false)
      expect(result.error_code).to eq(OpenFeature::SDK::Provider::ErrorCode::FLAG_NOT_FOUND)
      expect(result.error_message).to include("Failed to evaluate setting 'non-existing' (the key was not found in config JSON)")
      expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::ERROR)
    end

    it "type mismatch" do
      result = provider.fetch_boolean_value(flag_key: "stringSetting", default_value: false)

      expect(result.value).to eq(false)
      expect(result.error_code).to eq(OpenFeature::SDK::Provider::ErrorCode::TYPE_MISMATCH)
      expect(result.reason).to eq(OpenFeature::SDK::Provider::Reason::ERROR)
    end
  end
end
