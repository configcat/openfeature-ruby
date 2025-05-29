# frozen_string_literal: true

require "open_feature/sdk"
require "configcat"

module ConfigCat
  module OpenFeature
    class Provider
      PROVIDER_NAME = "ConfigCatProvider"
      attr_reader :metadata

      def initialize(sdk_key:, options: ConfigCatOptions.new)
        @metadata = ::OpenFeature::SDK::Provider::ProviderMetadata.new(name: PROVIDER_NAME)
        @client = ConfigCatClient.get(sdk_key, options)
      end

      def fetch_boolean_value(flag_key:, default_value:, evaluation_context: nil)
        user = ctx_to_user(evaluation_context)
        evaluation_detail = @client.get_value_details(flag_key, default_value, user)

        unless [true, false].include?(evaluation_detail.value)
          return type_mismatch(default_value)
        end

        produce_result(evaluation_detail, default_value)
      end

      def fetch_string_value(flag_key:, default_value:, evaluation_context: nil)
        user = ctx_to_user(evaluation_context)
        evaluation_detail = @client.get_value_details(flag_key, default_value, user)

        unless evaluation_detail.value.is_a?(String)
          return type_mismatch(default_value)
        end

        produce_result(evaluation_detail, default_value)
      end

      def fetch_number_value(flag_key:, default_value:, evaluation_context: nil)
        user = ctx_to_user(evaluation_context)
        evaluation_detail = @client.get_value_details(flag_key, default_value, user)

        unless evaluation_detail.value.is_a?(Numeric)
          return type_mismatch(default_value)
        end

        produce_numeric_result(evaluation_detail, default_value, Numeric)
      end

      def fetch_integer_value(flag_key:, default_value:, evaluation_context: nil)
        user = ctx_to_user(evaluation_context)
        evaluation_detail = @client.get_value_details(flag_key, default_value, user)

        unless evaluation_detail.value.is_a?(Numeric)
          return type_mismatch(default_value)
        end

        produce_numeric_result(evaluation_detail, default_value, Integer)
      end

      def fetch_float_value(flag_key:, default_value:, evaluation_context: nil)
        user = ctx_to_user(evaluation_context)
        evaluation_detail = @client.get_value_details(flag_key, default_value, user)

        unless evaluation_detail.value.is_a?(Numeric)
          return type_mismatch(default_value)
        end

        produce_numeric_result(evaluation_detail, default_value, Float)
      end

      def fetch_object_value(flag_key:, default_value:, evaluation_context: nil)
        user = ctx_to_user(evaluation_context)
        evaluation_detail = @client.get_value_details(flag_key, "", user)

        unless evaluation_detail.value.is_a?(String)
          return type_mismatch(default_value)
        end

        result = produce_result(evaluation_detail, default_value)
        begin
          result.value = JSON.parse(result.value)
        rescue JSON::ParserError, TypeError
          return ::OpenFeature::SDK::Provider::ResolutionDetails.new(
            value: default_value,
            error_message: "Could not parse '#{result.value}' as JSON",
            reason: ::OpenFeature::SDK::Provider::Reason::ERROR
          )
        end
        result
      end

      # @param evaluation_context [::OpenFeature::SDK::EvaluationContext, nil]
      #
      # @return [ConfigCat::User, nil]
      private def ctx_to_user(evaluation_context)
        if evaluation_context.nil? || evaluation_context.fields.nil? || evaluation_context.fields.empty?
          return nil
        end

        email = evaluation_context.field("Email")
        country = evaluation_context.field("Country")

        ConfigCat::User.new(evaluation_context.targeting_key, email: email, country: country, custom: evaluation_context.fields)
      end

      private def type_mismatch(default_value)
        ::OpenFeature::SDK::Provider::ResolutionDetails.new(
          value: default_value,
          reason: ::OpenFeature::SDK::Provider::Reason::ERROR,
          error_code: ::OpenFeature::SDK::Provider::ErrorCode::TYPE_MISMATCH
        )
      end

      # @param evaluation_detail [ConfigCat::EvaluationDetails]
      # @param default_value [any]
      #
      # @return [::OpenFeature::SDK::ResolutionDetails]
      private def produce_result(evaluation_detail, default_value)
        unless evaluation_detail.error.nil?
          error_code = evaluation_detail.error.include?("key was not found in config JSON") ? ::OpenFeature::SDK::Provider::ErrorCode::FLAG_NOT_FOUND : ::OpenFeature::SDK::Provider::ErrorCode::GENERAL
          return ::OpenFeature::SDK::Provider::ResolutionDetails.new(
            value: default_value,
            reason: ::OpenFeature::SDK::Provider::Reason::ERROR,
            error_code: error_code,
            error_message: evaluation_detail.error
          )
        end

        ::OpenFeature::SDK::Provider::ResolutionDetails.new(
          value: evaluation_detail.value,
          variant: evaluation_detail.variation_id,
          reason: produce_reason(evaluation_detail)
        )
      end

      # @param evaluation_detail [ConfigCat::EvaluationDetails]
      # @param default_value [any]
      #
      # @return [::OpenFeature::SDK::ResolutionDetails]
      private def produce_numeric_result(evaluation_detail, default_value, type)
        result = produce_result(evaluation_detail, default_value)
        unless result.error_code.nil?
          return result
        end

        if type == Integer
          result.value = result.value.to_i
        elsif type == Float
          result.value = result.value.to_f
        end

        result
      end

      # @param evaluation_detail [ConfigCat::EvaluationDetails]
      #
      # @return [String]
      private def produce_reason(evaluation_detail)
        unless evaluation_detail.error.nil?
          return ::OpenFeature::SDK::Provider::Reason::ERROR
        end

        if !evaluation_detail.matched_targeting_rule.nil? || !evaluation_detail.matched_percentage_option.nil?
          return ::OpenFeature::SDK::Provider::Reason::TARGETING_MATCH
        end

        ::OpenFeature::SDK::Provider::Reason::DEFAULT
      end
    end
  end
end
