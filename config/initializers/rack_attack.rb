class Rack::Attack
  # Throttle root path requests (3 requests per 1s)
  throttle('root/ip', limit: 2, period: 1.second) do |req|
    req.ip if req.path == '/' && !req.path.start_with?('/assets')
  end

  # Custom blocked response (HTTP 429)
  self.throttled_responder = ->(env) {
    [
      429,
      { 'Content-Type' => 'application/json' },
      [{ error: "Too many requests. Slow down!" }.to_json]
    ]
  }
end