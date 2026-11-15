#!/bin/bash

set -e
cd /home/ubuntu

# Download cat and dog images
curl -fL https://cataas.com/cat -o cat.jpg

DOG_URL=$(curl -fsSL https://dog.ceo/api/breeds/image/random | python3 -c 'import json,sys; print(json.load(sys.stdin)["message"])')

curl -fL "$DOG_URL" -o dog.jpg

# Convert images to PNG
convert cat.jpg o.png
convert dog.jpg x.png

# Remove original images
rm cat.jpg dog.jpg

# Create S3 bucket if it does not exist
aws s3 ls s3://tech613-ameen-ttt-images/ >/dev/null 2>&1 || aws s3 mb s3://tech613-ameen-ttt-images

# Upload images
aws s3 cp o.png s3://tech613-ameen-ttt-images/
aws s3 cp x.png s3://tech613-ameen-ttt-images/

# Allow public bucket policies
aws s3api put-public-access-block \
--bucket tech613-ameen-ttt-images \
--public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=false,RestrictPublicBuckets=false"

# Create public read policy
cat > policy.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": [
        "arn:aws:s3:::tech613-ameen-ttt-images/o.png",
        "arn:aws:s3:::tech613-ameen-ttt-images/x.png"
      ]
    }
  ]
}
EOF

# Apply bucket policy
aws s3api put-bucket-policy --bucket tech613-ameen-ttt-images --policy file://policy.json

# Set environment variables
export USE_MARKER_IMAGES=true
export MARKER_IMAGES_PATH="https://tech613-ameen-ttt-images.s3.eu-west-1.amazonaws.com"

# Start the app without a database
unset MONGODB_URI STATEFUL_MODE
cd /home/ubuntu/app

pm2 delete tictactoe 2>/dev/null || true
pm2 start npm --name tictactoe -- start
pm2 save

echo "Custom S3 marker images configured."
