#!/usr/bin/env bash
# Install updates and Node.js, then run the app
yum update -y
curl -sL https://rpm.nodesource.com/setup_21.x | bash -
yum install -y nodejs
# Download the sample app (assuming it's hosted somewhere accessible)

curl -o /home/ec2-user/app.js https://raw.githubusercontent.com/your-repo/sample-
app/main/app.js

# Start the Node.js app
nohup node /home/ec2-user/app.js &