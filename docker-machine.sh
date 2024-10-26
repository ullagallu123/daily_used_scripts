#!/bin/bash
aws ec2 run-instances \
  --image-id ami-0a4408457f9a03be3 \
  --instance-type t3a.large \
  --key-name siva \
  --user-data file://docker-installation.sh \
  --instance-market-options "MarketType=spot,SpotOptions={SpotInstanceType=one-time}" \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=docker}]' \
  --block-device-mappings 'DeviceName=/dev/xvda,Ebs={VolumeSize=40,VolumeType=gp3,DeleteOnTermination=true}'