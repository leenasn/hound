HireFire::Resource.configure do |config|
  
  config.dyno(:rescue) do
    HireFire::Macro::Resque.queue
  end
 
  config.dyno(:all_worker) do
    HireFire::Macro::Resque.queue
  end

  config.dyno(:mailer) do
    HireFire::Macro::Resque.queue(:email)
  end

  config.dyno(:encoder) do
    HireFire::Macro::Resque.queue(:encode)
  end

  config.dyno(:multi_queue) do
    HireFire::Macro::Resque.queue(:high, :medium, :low)
  end
end
