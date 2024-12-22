#!/bin/bash

HOSTED_ZONE_ID="Z04410211MZ57SQOXFNI3"  
RECORD_NAME="docker.bapatlas.site"   
INSTANCE_TAG="Name=docker"

# Step 1: Prompt for the instance type
echo "Please enter the instance type (e.g., t3a.medium, t3.medium): "
read INSTANCE_TYPE

# Ensure the input is not empty
if [ -z "$INSTANCE_TYPE" ]; then
  echo "Error: Instance type cannot be empty."
  exit 1
fi

# Step 2: Retrieve the latest Amazon Linux 2023 AMI ID
AMI_ID=$(aws ec2 describe-images \
    --owners "amazon" \
    --region ap-south-1 \
    --filters "Name=name,Values=al2023-ami-2023*" "Name=state,Values=available" "Name=architecture,Values=x86_64" \
    --query "Images | sort_by(@, &CreationDate)[-1].ImageId" \
    --output text)

if [ -z "$AMI_ID" ]; then
  echo "Error: Failed to retrieve the latest Amazon Linux 3 AMI ID."
  exit 1
fi

# Step 3: Check if there is already a running instance with the tag "Name=docker"
INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=$INSTANCE_TAG" "Name=instance-state-name,Values=running" \
  --query "Reservations[0].Instances[0].InstanceId" \
  --output text)

if [ -z "$INSTANCE_ID" ]; then
  # Instance not found, create a new one
  echo "No running instance found, creating a new one..."

  INSTANCE_ID=$(aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --instance-type "$INSTANCE_TYPE" \
    --key-name dev \
    --user-data file://docker-installation.sh \
    --instance-market-options "MarketType=spot,SpotOptions={SpotInstanceType=one-time}" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=docker}]" \
    --block-device-mappings 'DeviceName=/dev/xvda,Ebs={VolumeSize=20,VolumeType=gp3,DeleteOnTermination=true}' \
    --query 'Instances[0].InstanceId' \
    --output text)

  if [ -z "$INSTANCE_ID" ]; then
    echo "Error: Failed to launch instance."
    exit 1
  fi

  # Wait for the instance to be running
  aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"
  echo "Instance $INSTANCE_ID launched successfully."
else
  echo "Using existing running instance with ID $INSTANCE_ID."
fi

# Step 4: Get the public IP of the instance
PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

if [ -z "$PUBLIC_IP" ]; then
  echo "Error: Failed to retrieve the public IP address for instance $INSTANCE_ID."
  exit 1
fi

# Step 5: Check if the Route 53 record already exists with the same IP
EXISTING_IP=$(aws route53 list-resource-record-sets \
  --hosted-zone-id "$HOSTED_ZONE_ID" \
  --query "ResourceRecordSets[?Name=='$RECORD_NAME'].ResourceRecords[0].Value" \
  --output text)

if [ "$EXISTING_IP" == "$PUBLIC_IP" ]; then
  echo "DNS record for $RECORD_NAME already points to the correct IP ($PUBLIC_IP). No update needed."
else
  # Update the Route 53 record
  echo "Updating DNS record $RECORD_NAME to point to $PUBLIC_IP..."
  aws route53 change-resource-record-sets \
    --hosted-zone-id "$HOSTED_ZONE_ID" \
    --change-batch "{
        \"Changes\": [{
            \"Action\": \"UPSERT\",
            \"ResourceRecordSet\": {
                \"Name\": \"$RECORD_NAME\",
                \"Type\": \"A\",
                \"TTL\": 60,
                \"ResourceRecords\": [{\"Value\": \"$PUBLIC_IP\"}]
            }
        }]
    }"
  echo "DNS record $RECORD_NAME updated to IP: $PUBLIC_IP"
fi

echo "Instance $INSTANCE_ID with IP $PUBLIC_IP is ready and DNS record updated."
