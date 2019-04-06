#!/bin/bash

ro_access_key=$1
ro_secret_key=$2
autoscaling_group=$3
region=$4

(crontab -l 2>/dev/null; echo "*/3 * * * * sudo aws_access_key=${ro_access_key} aws_secret_key=${ro_secret_key} aws_autoscaling=${autoscaling_group} aws_region=${region} ruby /usr/bin/haproxy-autoscaling-update.rb") | crontab -