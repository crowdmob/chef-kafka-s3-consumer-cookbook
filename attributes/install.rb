default[:kafka_s3_consumer][:remote_tgz] = "https://github.com/crowdmob/kafka-s3-consumer/archive/master.tar.gz"
default[:kafka_s3_consumer][:version] = "0.1"

default[:kafka_s3_consumer][:user] = "kafka_s3_consumer"
default[:kafka_s3_consumer][:group] = "kafka_s3_consumer"

default[:kafka_s3_consumer][:pid_files_path] = "/var/run/kafka-s3-consumer"
default[:kafka_s3_consumer][:output_files_path] = "/var/log/kafka-s3-consumer"
default[:kafka_s3_consumer][:config_files_path] = "/etc/kafka-s3-consumer"
