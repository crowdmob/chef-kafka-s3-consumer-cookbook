
default[:kafka_s3_consumer][:_application_defaults][:kafka_topic_array] = ["example-topic-set-by-chef"]
default[:kafka_s3_consumer][:_application_defaults][:kafka_max_message_size] = 4096
default[:kafka_s3_consumer][:_application_defaults][:debug] = false
default[:kafka_s3_consumer][:_application_defaults][:maxchunksizebytes] = 1048576
default[:kafka_s3_consumer][:_application_defaults][:maxchunkagemins] = 5
default[:kafka_s3_consumer][:_application_defaults][:filebufferpath_base] = "/mnt/tmp"
default[:kafka_s3_consumer][:_application_defaults][:pollsleepmillis] = 10

node[:deploy].each do |application, _|
  if node[:deploy][application][:environment]["HOME"] && node[:deploy][application][:env]
    default[:kafka_s3_consumer][application][:env] = {"HOME" => node[:deploy][application][:environment]["HOME"]}.merge(node[:deploy][application][:env])
  elsif node[:deploy][application][:environment]["HOME"]
    default[:kafka_s3_consumer][application][:env] = {"HOME" => node[:deploy][application][:environment]["HOME"]}
  elsif node[:deploy][application][:env]
    default[:kafka_s3_consumer][application][:env] = node[:deploy][application][:env]
  end

  default[:kafka_s3_consumer][application][:restart_command] = "monit restart kafka_s3_consumer_#{application}"
  default[:kafka_s3_consumer][application][:stop_command] = "monit stop kafka_s3_consumer_#{application}"
  default[:kafka_s3_consumer][application][:debug] = node[:kafka_s3_consumer][:_application_defaults][:debug]
  default[:kafka_s3_consumer][application][:maxchunksizebytes] = node[:kafka_s3_consumer][:_application_defaults][:maxchunksizebytes]
  default[:kafka_s3_consumer][application][:maxchunkagemins] = node[:kafka_s3_consumer][:_application_defaults][:maxchunkagemins]
  default[:kafka_s3_consumer][application][:filebufferpath] = "#{default[:kafka_s3_consumer][:_application_defaults][:filebufferpath_base]}/kafka_s3_consumer_#{application}"
  default[:kafka_s3_consumer][application][:pollsleepmillis] = node[:kafka_s3_consumer][:_application_defaults][:pollsleepmillis]
  default[:kafka_s3_consumer][application][:s3bucket] = "#{application}-kafka-sink-#{node[:service_realm]}"
  default[:kafka_s3_consumer][application][:config_file] = "#{node[:kafka_s3_consumer][:config_files_path]}/kafka_s3_consumer_#{application}.properties"
  default[:kafka_s3_consumer][application][:pid_file] = "#{node[:kafka_s3_consumer][:pid_files_path]}/kafka_s3_consumer_#{application}.pid"
  default[:kafka_s3_consumer][application][:output_file] = "#{node[:kafka_s3_consumer][:output_files_path]}/kafka_s3_consumer_#{application}.out"
  default[:kafka_s3_consumer][application][:kafka_topic_array] = node[:deploy][application][:kafka][:topics] || default[:kafka_s3_consumer][:_application_defaults][:topic_array]
  default[:kafka_s3_consumer][application][:kafka_max_message_size] = node[:deploy][application][:kafka][:max_message_size] || default[:kafka_s3_consumer][:_application_defaults][:kafka_max_message_size]
end
