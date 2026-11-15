
# AWS S3 — Custom Images for Tic Tac Toe

## Introduction

Amazon S3 (Simple Storage Service) is an object storage service that allows files such as images, documents and backups to be stored inside buckets. Each file is stored as an object and identified by an object key.

Instead of storing the marker images inside my application's directory, I will store them in S3 and configure the application to retrieve them using HTTPS URLs.

## EC2 and Application Setup

I used an existing custom AMI containing my Tic Tac Toe application, Node.js, npm, Nginx and PM2. This avoided having to install the application dependencies again.

The application is located in `/home/ubuntu/app`. Nginx was already configured as a reverse proxy, forwarding HTTP requests from port 80 to my Node.js application on port 3000.

I connected to my EC2 instance using SSH and verified the main dependencies:

```bash
node -v
npm -v
pm2 -v
nginx -v
```

These commands confirm that the tools required to run and manage my application are available.

## Installing and Configuring AWS CLI

AWS CLI allows me to interact with AWS services directly through terminal commands. This is particularly useful for automation because I can create buckets, upload files and configure permissions without navigating the AWS Console.

I installed AWS CLI v2 using the official Linux installer:

```bash
sudo apt-get update
sudo apt-get install -y curl unzip

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

unzip awscliv2.zip

sudo ./aws/install
```

`curl` downloads the installer, `unzip` extracts it and `sudo ./aws/install` installs AWS CLI.

I then configured my AWS credentials:

```bash
aws configure
```

I entered my IAM access key, secret key, default region (`eu-west-1`) and output format (`json`). This allows AWS CLI to authenticate requests using my configured IAM identity.

I can verify the authentication using:

```bash
aws sts get-caller-identity
```

This displays the AWS account and IAM identity being used. Authentication alone does not guarantee permission to access every AWS resource.

## Downloading and Preparing the Images

I worked from my home directory because the downloaded images and S3 configuration files do not need to be stored inside the application folder.

```bash
cd ~
sudo apt-get install -y imagemagick
```

ImageMagick allows me to convert images into the required PNG format.

I downloaded a random cat image using:

```bash
curl -fL https://cataas.com/cat -o cat.jpg
```

For the dog image, the Dog API returns a JSON response containing an image URL. I extracted that URL and downloaded the image:

```bash
DOG_URL=$(curl -fsSL https://dog.ceo/api/breeds/image/random | python3 -c 'import json,sys; print(json.load(sys.stdin)["message"])')

curl -fL "$DOG_URL" -o dog.jpg
```

I then converted the images and removed the original downloads:

```bash
convert cat.jpg o.png
convert dog.jpg x.png

rm cat.jpg dog.jpg
```

`convert` changes the image format to PNG. `rm` removes the original files because they are no longer needed.

The filenames are important because the application expects `o.png` and `x.png` when custom markers are enabled.

To check their formats:

```bash
file o.png x.png
```

This identifies the actual file types rather than relying on their filename extensions.

## Creating the S3 Bucket and Uploading Images

I created a dedicated S3 bucket using:

```bash
aws s3 mb s3://tech613-ameen-ttt-images
```

`mb` means **make bucket**. It creates the storage container that will hold my images. The bucket uses my configured AWS region, `eu-west-1`.

I uploaded both images:

```bash
aws s3 cp o.png s3://tech613-ameen-ttt-images/

aws s3 cp x.png s3://tech613-ameen-ttt-images/
```

`cp` copies the local files from EC2 to S3. The original files remain on the VM.

To verify the objects were uploaded:

```bash
aws s3 ls s3://tech613-ameen-ttt-images/
```

Unlike `aws s3 ls`, which lists buckets, specifying a bucket path lists the objects inside that bucket.

## Configuring Public Access

By default, my S3 images are private. Even though the application knows their URLs, it cannot retrieve them publicly unless the correct permissions are configured.

I needed to allow public bucket policies and grant permission to read the two images.

### Allowing Public Bucket Policies

```bash
aws s3api put-public-access-block \
--bucket tech613-ameen-ttt-images \
--public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=false,RestrictPublicBuckets=false"
```

This allows the bucket to use a public bucket policy while continuing to block public ACL-based access.

The four settings control different aspects of S3 public access. Setting `BlockPublicPolicy=false` permits public bucket policies, while `RestrictPublicBuckets=false` prevents that restriction from overriding them.

This command does not itself make the images public; a bucket policy is still required. Account-level restrictions can also override these settings.

### Creating the Bucket Policy

I created a JSON policy file in my home directory:

```bash
nano policy.json
```

I added:

```json
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
```

The policy contains three important parts:

- **Principal `"*"`** — Applies the permission to everyone, including unauthenticated users.
- **Action `s3:GetObject`** — Allows the specified objects to be read or downloaded.
- **Resource** — Restricts the permission to `o.png` and `x.png`.

This allows people to view the two images without granting public permission to upload or delete objects.

I applied the policy using:

```bash
aws s3api put-bucket-policy --bucket tech613-ameen-ttt-images --policy file://policy.json
```

`put-bucket-policy` attaches the JSON permissions to my bucket. `file://policy.json` tells AWS CLI to read the policy from my local file.

### Testing Public Access

```bash
curl -I https://tech613-ameen-ttt-images.s3.eu-west-1.amazonaws.com/o.png

curl -I https://tech613-ameen-ttt-images.s3.eu-west-1.amazonaws.com/x.png
```

`curl -I` requests the HTTP response headers without downloading the image body.

`HTTP 200` indicates the object is accessible, whereas `403 Forbidden` indicates the request was denied.

I initially encountered a `403 Forbidden` response because the images were private. I also encountered a `MalformedPolicy` error when applying the bucket policy due to its formatting.

I inspected the policy with `cat policy.json` and corrected it using Nano. The JSON file must contain valid JSON, with `{` as its first byte for this AWS CLI operation.

## Configuring Tic Tac Toe to Use S3 Images

My application must support custom marker images. I can check its package version and run its tests from the application directory:

```bash
cd ~/app
npm pkg get version
npm test
```

My package identified itself as version `1.2.0`, although the test run returned 105 passing tests rather than the count described in the assignment.

I also checked the application code for `USE_MARKER_IMAGES` and confirmed the feature was implemented.

### Setting Environment Variables

I configured two environment variables before starting the application:

```bash
export USE_MARKER_IMAGES=true

export MARKER_IMAGES_PATH="https://tech613-ameen-ttt-images.s3.eu-west-1.amazonaws.com"
```

`USE_MARKER_IMAGES=true` enables the custom image functionality.

`MARKER_IMAGES_PATH` specifies the base HTTPS URL of the S3 bucket. The application uses this path to retrieve `o.png` and `x.png`.

`export` makes these variables available to processes launched from the current shell, including PM2 when it starts the application.

### Starting the Application

The assignment requires the app to run without a database. I can ensure the database environment variables are unset:

```bash
unset MONGODB_URI STATEFUL_MODE
```

I then start the application from its directory:

```bash
cd ~/app

pm2 start npm --name tictactoe -- start
```

PM2 manages the Node.js application process. `--name tictactoe` gives the process a recognisable name, and `-- start` tells npm to execute the application's start script.

If the application is already running through PM2, I can remove the old process before starting it with the new environment variables:

```bash
pm2 delete tictactoe
pm2 start npm --name tictactoe -- start
```

I can check and save the process configuration using:

```bash
pm2 list
pm2 save
```

`pm2 list` shows the process status, while `pm2 save` saves the process list for later restoration.

Because Nginx forwards traffic from port 80 to port 3000, I can access my application using:

`http://EC2_PUBLIC_IP`

When playing Tic Tac Toe, the board displays the cat and dog images instead of the normal X and O markers.

## Automating the Process with Bash

The manual commands can be reused in two Bash scripts.

### Enabling Custom Images

The first script, `use-s3-image-on-homepage.sh`, is designed to download the images, convert them to PNG, create the S3 bucket, upload the images, apply public permissions and start the app with the correct environment variables.

I store the script in `/home/ubuntu` so that it can be executed independently of the application directory.

The key difference between running commands manually and running them in a script is that the script must create the policy file automatically rather than requiring me to open Nano.

A Bash heredoc can write the JSON policy:

```bash
cat > policy.json <<'EOF'
POLICY_JSON_CONTENT
EOF
```

`POLICY_JSON_CONTENT` represents the complete valid bucket policy shown earlier. The `EOF` markers identify the beginning and end of the content written to the file.

The script must also account for the bucket potentially already existing.

### Reverting to Normal Markers

The second script, `revert-to-normal-homepage.sh`, reverses the configuration.

First, I remove the image-related environment variables and restart the application:

```bash
unset USE_MARKER_IMAGES
unset MARKER_IMAGES_PATH

cd ~/app

pm2 delete tictactoe
pm2 start npm --name tictactoe -- start
```

I remove both variables so the restarted application does not use the S3 images. When restarting, I also ensure the database variables remain unset.

After confirming the application uses its normal markers, I remove the S3 images:

```bash
aws s3 rm s3://tech613-ameen-ttt-images/o.png

aws s3 rm s3://tech613-ameen-ttt-images/x.png
```

Finally, I delete the empty bucket:

```bash
aws s3 rb s3://tech613-ameen-ttt-images
```

`rm` removes individual objects, while `rb` means **remove bucket**.

The bucket must be empty before it can be removed using this command.

**The order is important:** I disable the image functionality and restart the app before deleting its S3 images. Otherwise, the running application could continue requesting files that no longer exist, resulting in broken marker images.

### Running the Scripts

After saving each script, I make it executable:

```bash
chmod +x ~/use-s3-image-on-homepage.sh
chmod +x ~/revert-to-normal-homepage.sh
```

`chmod +x` grants execute permission.

I can then execute the scripts sequentially:

```bash
~/use-s3-image-on-homepage.sh

~/revert-to-normal-homepage.sh
```

Running them repeatedly helps test whether the automation correctly recreates, configures and removes the S3 resources without relying on manual intervention.
