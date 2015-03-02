class LargeBuildJob < ActiveJob::Base
  include Buildable
  extend Retryable

  queue_as :low
end
