kafka-s3-consumer Cookbook for Amazon OpsWorks
===============================

Chef Cookbook that downloads the `crowdmob/kafka-s3-consumer` repository from GitHub, builds, and runs it using monit. Confirmed working with Amazon OpsWorks.

Dependencies
-----------------------------
This cookbook depends on the following:

- `deploy`: the base amazon deploy recipe at https://github.com/aws/opsworks-cookbooks/tree/master/deploy
- `golang`: the installation of go recipe at https://github.com/crowdmob/chef-golang
- `monit`: the monit package to ensure your server is running, and tries to restart it if not at https://github.com/crowdmob/chef-monit

Of course, it also depends on a Kafka server running.  There's a helpful Kafka chef recipe if you don't have a Kafka server running somewhere already

- `kafka`: an installation of kafka recipe at https://github.com/crowdmob/chef-kafka


Only Use 64 Bit EC2 Instances
-----------------------------
At this time, the `golang` cookbook mentioned doesn't dynamically choose the right binary at runtime, based on CPU.  That means that it assumes a 64 bit ec2 instance, which is a large instance or better.

Custom Chef Recipes Setup
-----------------------------
To deploy your app, you'll have to make sure 2 of the recipes in this cookbook are run.

1. `kafka-s3-consumer::install` should run during the setup phase of your node in OpsWorks
2. `kafka-s3-consumer::run` should run after kafka-s3-consumer::install, possibly in the Configure phase of your node in OpsWorks.

Databag Setup
-----------------------------
This cookbook relies on a databag, which you should set in Amazon OpsWorks as your Stack's "Custom Chef JSON", with the following parameters:

```json
{
  "service_realm": "production",
  "deploy": {
    "YOUR_APPLICATION_NAME": {
      ...
      "env": {
        "AWS_ACCESS_KEY_ID": "YOUR_AWS_ACCESS_KEY_CREDENTIALS",
        "AWS_SECRET_ACCESS_KEY": "YOUR_AWS_SECRET_KEY_CREDENTIALS",
        "AWS_REGION": "us-east-1",
        ...
      },
      "kafka": {
        "topics": [ "YOUR_TOPIC_1", "YOUR_TOPIC_2" ],
        "max_message_size": 4096
      }
    }
  }
}
```

Here's a little more about the ones you have to fill in:
- `YOUR_APPLICATION_NAME` is what you named your app, in the "Apps" section of OpsWorks
- `YOUR_AWS_ACCESS_KEY_CREDENTIALS` should be gotten from Amazon AWS
- `YOUR_AWS_SECRET_KEY_CREDENTIALS` should also be gotten from Amazon AWS
- `YOUR_TOPIC_1` and `YOUR_TOPIC_2` is an array of kafka topics the consumer for this app should consume

How it Works
-----------------------------
This cookbook builds and runs a go webapp in the following way:

- The `consumer.go` source file from https://github.com/crowdmob/kafka-s3-consumer is built using `go get .` followed by `go build -o /usr/local/kafka-s3-consumer consumer.go`.  That results in an executable of at  `/usr/local/kafka-s3-consumer`
- A `consumer.properties` file is created using your databag and output at `/etc/kafka-s3-consumer/kafka_s3_consumer_APPNAME.properties`
- A `kafka-s3-consumer-APPNAME-daemon` shell script is created and placed in  `/usr/local/`, which handles start and restart commands, by calling  `/usr/local/kafka-s3-consumer -c /etc/kafka-s3-consumer/kafka_s3_consumer_APPNAME.properties` and outputting logs to `/var/log/kafka-s3-consumer/kafka_s3_consumer_APPNAME.out`
- A `kafka_s3_consumer_APPNAME.monitrc` monit script is created, which utilizes the `kafka-s3-consumer-APPNAME-daemon` script for startup and shutdown, and is placed in `/etc/monit.d` or `/etc/monit/conf.d`, depending on your OS (defined in the `monit` cookbook)
- `monit` is restarted, which incorporates the the new files.


License and Author
===============================
Author:: Matthew Moore

Copyright:: 2013, CrowdMob Inc.


Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
