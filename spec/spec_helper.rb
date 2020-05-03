def get_process_from_bpm(config, job_name)
  return config['processes'].select { |p| p['name'] == job_name }.first
end

def es_config()
  {
    'span_storage_type' => 'elasticsearch',
    'es' => { 'server-urls' => ['http://10.0.0.1:9200', 'http://10.0.0.2:9200']}
  }
end

def get_default_config(job_name)
  case job_name
  when 'jaeger-all-in-one', 'jaeger-agent'
    {}
  when 'jaeger-collector', 'jaeger-query'
    es_config
  end
end