def get_process_from_bpm(config)
  return config['processes'].select { |p| p['name'] == 'jaeger-all-in-one' }.first
end