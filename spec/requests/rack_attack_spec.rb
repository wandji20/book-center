require 'rails_helper'
require 'rack/attack'

RSpec.describe "Rack::Attack" do
  include Rack::Test::Methods

  # Define a simple Rack app that includes Rack::Attack
  def app
    Rack::Builder.new do
      use Rack::Attack
      run ->(env) { [200, {}, ["Running"]] }
    end.to_app
  end

  describe "throttle excessive root path requests by IP" do
    let(:limit) { 2 }
    let(:period) { 1 } # in seconds

    before do
      # Use memory store for testing (resets between tests)
      Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
      # Clear the Rack::Attack cache between tests
      Rack::Attack.cache.store.clear
    end

    it "allows requests below the throttle limit" do
      limit.times do
        get "/", {}, "REMOTE_ADDR" => "1.2.3.4"
        expect(last_response.status).not_to eq(429)
      end
    end

    it "throttles requests exceeding the limit" do
      (limit + 1).times do |i|
        get "/", {}, "REMOTE_ADDR" => "1.2.3.4"
      end

      expect(last_response.status).to eq(429)
      expect(last_response.body).to include("Too many requests. Slow down!")
    end

    it "tracks different IPs separately" do
      # First IP under limit
      limit.times do
        get "/", {}, "REMOTE_ADDR" => "1.2.3.4"
        expect(last_response.status).not_to eq(429)
      end

      # Second IP under limit
      limit.times do
        get "/", {}, "REMOTE_ADDR" => "5.6.7.8"
        expect(last_response.status).not_to eq(429)
      end

      # First IP over limit
      get "/", {}, "REMOTE_ADDR" => "1.2.3.4"
      expect(last_response.status).to eq(429)
    end
  end
end