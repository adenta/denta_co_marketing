class Ahoy::Store < Ahoy::DatabaseStore
end

# accept events from ahoy.js
Ahoy.api = true

# keep location lookups off until we decide on a local geocoding strategy
Ahoy.geocode = false

# use the server as the source of truth for visits
Ahoy.server_side_visits = true

# mask raw IPs in stored analytics data
Ahoy.mask_ips = true

# test requests often look bot-like to the detector and would otherwise be dropped
Ahoy.track_bots = Rails.env.test?
