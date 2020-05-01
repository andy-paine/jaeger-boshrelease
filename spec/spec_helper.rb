def get_process_from_bpm(config, job_name = 'jaeger-all-in-one')
  return config['processes'].select { |p| p['name'] == job_name }.first
end