node[:deploy].each do |application, _|
  service 'monit' do
    action :nothing
  end

  template node[:kafka_s3_consumer][application][:config_file] do
    source  'consumer.properties.erb'
    mode    '0660'
    owner   node[:kafka_s3_consumer][:user]
    group   node[:kafka_s3_consumer][:group]
    variables(
      :application_settings => node[:kafka_s3_consumer][application],
      :kafka_topic_array => node[:kafka_s3_consumer][application][:kafka_topic_array],
      :kafka_maxmessagesize => node[:kafka_s3_consumer][application][:kafka_max_message_size],
      :env_vars => node[:kafka_s3_consumer][application][:env],
      :kafka_settings => node[:kafka],
      :kafka_partition => (node[:hostname].match(/(\d+)(?!.*\d)/)[0].to_i - 1)
    )
  end
  
  template "/usr/local/kafka-s3-consumer-#{application}-daemon" do
    source   'kafka-s3-consumer-daemon.erb'
    owner    'root'
    group    'root'
    mode     '0751'
    variables(
      :pid_file => node[:kafka_s3_consumer][application][:pid_file],
      :config_file => node[:kafka_s3_consumer][application][:config_file],
      :output_file => node[:kafka_s3_consumer][application][:output_file],
      :application_name => application
    )
  end
  
  template "#{node[:monit][:conf_dir]}/kafka_s3_consumer_#{application}.monitrc" do
    source   'kafka-s3-consumer.monitrc.erb'
    owner    'root'
    group    'root'
    mode     '0644'
    variables(
      :pid_file => node[:kafka_s3_consumer][application][:pid_file],
      :application_name => application
    )
    notifies :restart, resources(:service => 'monit'), :immediately
  end
  
  
end