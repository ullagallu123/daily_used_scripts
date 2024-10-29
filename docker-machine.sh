#!/bin/bash

AMI_ID=$(aws ec2 describe-images \
    --owners "amazon" \
    --filters "Name=name,Values=amzn3-ami-hvm-*-x86_64-gp3" \
              "Name=state,Values=available" \
    --query "Images | sort_by(@, &CreationDate) | [-1].ImageId" \
    --output text)

if [ -z "$AMI_ID" ]; then
  echo "Error: Failed to retrieve the latest Amazon Linux 3 AMI ID."
  exit 1
fi

aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --instance-type t3a.large \
  --key-name dev \
  --user-data file://docker-installation.sh \
  --instance-market-options "MarketType=spot,SpotOptions={SpotInstanceType=one-time}" \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=docker}]' \
  --block-device-mappings 'DeviceName=/dev/xvda,Ebs={VolumeSize=50,VolumeType=gp3,DeleteOnTermination=true}'
