#!/bin/bash
HOSTED_ZONE_ID="Z08801502JQFVUXR02K9R"
INSTANCE_ID="i-09de590f13a7801c3"
DNS_NAME="ws.ullagallu.cloud"

# Start EC2 instance for WorkStation
echo "Starting EC2 instance for WorkStation..."
aws ec2 start-instances --instance-ids $INSTANCE_ID
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

# Get the public IPv4 address
ipv4_address=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
echo "Instance ID: $INSTANCE_ID, IPv4: $ipv4_address"

# Construct the payload to update Route 53 DNS records
payload='{"Changes": [{"Action": "UPSERT","ResourceRecordSet": {"Name": "'"$DNS_NAME"'","Type": "A","TTL": 1,"ResourceRecords": [{"Value": "'"$ipv4_address"'"}]}}]}'

# Update Route 53 DNS record
echo "Updating DNS record for WorkStation..."
if aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch "$payload"; then
    echo "DNS update for WorkStation was successful."
else
    echo "Failed to update DNS record for WorkStation."
fi

# Verify the updated Route 53 record
echo "Verifying DNS record..."
updated_record=$(aws route53 list-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --query "ResourceRecordSets[?Type == 'A' && Name == 'ws.ullagallu.cloud.'].[Name, ResourceRecords[0].Value]" --output text)
echo "Updated record: $updated_record"
