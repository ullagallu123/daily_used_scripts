# This will stop the jenkins server and agent
#!/bin/bash

instances=("i-0cf43842a1e6a9bec" "i-09de590f13a7801c3")

# Stop EC2 instances
for instance_id in "${instances[@]}"; do
    echo "Stopping EC2 instance: $instance_id"
    aws ec2 stop-instances --instance-ids $instance_id
    aws ec2 wait instance-stopped --instance-ids $instance_id
    echo "$instance_id has been stopped."
done

# Verifying that the instances have stopped
for instance_id in "${instances[@]}"; do
    state=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[*].Instances[*].State.Name' --output text)
    echo "The state of instance $instance_id is: $state"
done
