group node[:kafka_s3_consumer][:group]

user node[:kafka_s3_consumer][:user] do
  comment "kafkas3consumer user"
  gid node[:kafka_s3_consumer][:group]
  home "/home/#{node[:kafka_s3_consumer][:user]}"
  shell "/bin/noshell"
  supports :manage_home => false
end

bash "install-kafka-s3-consumer-master" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    rm -rf kafka-s3-consumer
    rm -rf /usr/local/kafka-s3-consumer
    tar -xzvf kafka-s3-consumer-master.tar.gz
    #{node['go']['install_dir']}/go/bin/go get ./kafka-s3-consumer-master
    #{node['go']['install_dir']}/go/bin/go build -o /usr/local/kafka-s3-consumer kafka-s3-consumer-master/consumer.go
  EOH
  action :nothing
end

remote_file File.join(Chef::Config[:file_cache_path], "kafka-s3-consumer-master.tar.gz") do
  source          node[:kafka_s3_consumer][:remote_tgz]
  owner           "root"
  mode            0644
  notifies        :run, resources(:bash => "install-kafka-s3-consumer-master"), :immediately
  not_if          "/usr/local/kafka-s3-consumer -v | grep #{node[:kafka_s3_consumer][:version]}"
end

[node[:kafka_s3_consumer][:pid_files_path], node[:kafka_s3_consumer][:config_files_path], node[:kafka_s3_consumer][:output_files_path]].each do |my_dir|
  directory my_dir do
    group      "root"
    owner      "root"
    mode       0770
    action     :create
    recursive  true
  end
end
