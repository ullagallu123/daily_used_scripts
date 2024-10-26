#!/bin/bash
aws ec2 run-instances \
  --image-id ami-0a4408457f9a03be3 \
  --instance-type t3a.large \
  --key-name dev \
  --user-data file://docker-installation.sh \
  #--instance-market-options "MarketType=spot,SpotOptions={SpotInstanceType=one-time}" \
  --instance-market-options "MarketType=spot,SpotOptions={SpotInstanceType=persistent,InstanceInterruptionBehavior=stop}" \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=docker}]' \
  --block-device-mappings 'DeviceName=/dev/xvda,Ebs={VolumeSize=50,VolumeType=gp3,DeleteOnTermination=true}'