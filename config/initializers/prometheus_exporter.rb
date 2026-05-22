return unless ENV["PROMETHEUS_ENABLED"] == "1"

require "prometheus_exporter/middleware"
require "prometheus_exporter/instrumentation"

if ENV["PROMETHEUS_EXPORTER_SERVER"] == "1"
  require "prometheus_exporter/server"
  server = PrometheusExporter::Server::WebServer.new(
    port: ENV.fetch("PROMETHEUS_EXPORTER_PORT", 9394).to_i,
    bind: "0.0.0.0"
  )
  server.start
end

PrometheusExporter::Client.default = PrometheusExporter::Client.new(
  host: ENV.fetch("PROMETHEUS_EXPORTER_HOST", "localhost"),
  port: ENV.fetch("PROMETHEUS_EXPORTER_PORT", 9394).to_i
)

Rails.application.middleware.unshift PrometheusExporter::Middleware

PrometheusExporter::Instrumentation::Process.start(type: "web", frequency: 30)
PrometheusExporter::Instrumentation::ActiveRecord.start(
  custom_labels: { app: "sure" },
  config_labels: [ :database, :host ]
)
