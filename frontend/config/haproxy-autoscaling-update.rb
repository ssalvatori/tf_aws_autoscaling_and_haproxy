require 'aws-sdk'
require 'pp'

# We use instance profile credentials to authenticate
# using the role attached to the instance
region = ENV['aws_region']
auto_scaling_group = ENV['aws_autoscaling']
credentials = Aws::Credentials.new(ENV['aws_access_key'].strip, ENV['aws_secret_key'].strip)

Aws.config.update(credentials: credentials)
Aws.config.update(region: region)

autoscaling = Aws::AutoScaling::Client.new(region: region)
ec2 = Aws::EC2::Client.new(region: region)

# Retrieve current autoscaling group instances
response = autoscaling.describe_auto_scaling_groups(auto_scaling_group_names: [auto_scaling_group])
instances = response.auto_scaling_groups.first.instances

hosts = []
instances.each do |instance|
  if instance.lifecycle_state == "InService"
    # We cannot access the private IP address of the
    # instance using Autoscaling API, so we have to
    # retrieve the instance object from the EC2 API.
    ec2_instance = ec2.describe_instances(instance_ids: [instance.instance_id]).reservations.first.instances.first
    if ec2_instance.state.name == "running"
      hosts << {ip: ec2_instance.private_ip_address, public_name: ec2_instance.public_dns_name}
    end
  end
end

# Copy template config to the config file
# and append hosts to backend configuration
FileUtils.cp("/etc/haproxy/haproxy.cfg.template", "/etc/haproxy/haproxy.cfg")

open("/etc/haproxy/haproxy.cfg", "a") do |f|
  hosts.each do |host|
    f << "\tserver #{host[:public_name]} #{host[:ip]}:80 check cookie #{host[:public_name]}\n"
  end
end

#  Check syntax
stdout = `haproxy -c -V -f /etc/haproxy/haproxy.cfg`
if /Configuration file is valid/ =~ stdout
  stdout = `service haproxy reload`
  puts " -> reloaded HAProxy: #{stdout}"
end