# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

use Rack::Static,
    urls: ["/images"],
    root: "public"

run Rails.application
Rails.application.load_server
