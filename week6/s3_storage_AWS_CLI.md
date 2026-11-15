# AWS S3 Storage Using AWS CLI 

## What is Amazon S3?

Amazon S3 stands for **Amazon Simple Storage Service**.

It is an object storage service used to store and retrieve data, such as documents, images, application files and backups.

I can access it through:
- The AWS Management Console.
- AWS CLI.
- Code using an AWS SDK, such as Python Boto3.

Internet connectivity alone does not give someone access to my files. The appropriate permissions are also required.

## Why Use S3?

- Store files without managing a storage server.
- I upload and retrieve data over the internet with authorised access.
- Store backups and application assets.
- Host static website files, such as HTML, CSS and JavaScript.

**S3 Standard** stores data redundantly across at least three Availability Zones in a region. Some other storage classes use only one Availability Zone.

## How Is Data Stored?

Data is stored as **objects inside buckets**.

| Term | Meaning |
|---|---|
| Bucket | A container for objects. |
| Object | The stored data and its metadata. |
| Object key | The name identifying an object within its bucket. |

## What Is AWS CLI?

AWS CLI stands for **AWS Command Line Interface**.

It lets me interact with AWS services through terminal commands.

Commands allow me to repeat and automate tasks instead of performing each action manually through the console.

### Download AWS CLI

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
```

| Part | Meaning |
|---|---|
| `curl` | Downloads the installer. |
| URL | Official AWS CLI installer for Linux x86-64. |
| `-o "awscliv2.zip"` | Saves the download under this filename. |

### Extract the Installer

```bash
unzip awscliv2.zip
```

This extracts the installation files.

### Run the Installer

```bash
sudo ./aws/install
```

- `sudo` provides administrator permissions.
- `./aws/install` runs the installer extracted into the `aws` directory.

## 2. Configure Authentication

```bash
aws configure
```

I enter the training credentials and settings when prompted:

| Prompt | Value |
|---|---|
| AWS Access Key ID | My supplied access key ID |
| AWS Secret Access Key | My matching secret access key |
| Default region name | `eu-west-1` |
| Default output format | `json` |

### What Does This Do?

It saves the credentials and configuration that AWS CLI uses for requests.

- The access key ID identifies the credentials.
- The secret access key is used to sign requests.
- `eu-west-1` selects Ireland as the default region.
- `json` sets the output format for commands that support it.

### Why Is It Needed?

Installing AWS CLI does not automatically give it access to AWS resources.

**I do not include credentials in documentation, screenshots or GitHub.**

## 3. List S3 Buckets

```bash
aws s3 ls
```

| Part | Meaning |
|---|---|
| `aws` | Runs AWS CLI. |
| `s3` | Selects the S3 commands. |
| `ls` | Lists buckets. |

This makes an actual AWS request to check that the configured credentials have permission to list buckets.

## 4. Create a Bucket

```bash
aws s3 mb s3://tech613-ameen-first-bucket
```

| Part | Meaning |
|---|---|
| `mb` | Make bucket. |
| `s3://tech613-ameen-first-bucket` | The bucket to create. |

The command uses the configured default region, `eu-west-1`.

Objects must be stored inside a bucket, so the bucket must exist before uploading files.

The name must be available. If a different name is required, I use it consistently in subsequent commands.

## 5. Create a Test File

```bash
echo "This is the first line in a test file." > test.txt
```

| Part | Meaning |
|---|---|
| `echo` | Outputs the supplied text. |
| Quoted text | Content to write. |
| `>` | Redirects output into a file, replacing its existing contents. |
| `test.txt` | Local filename on the EC2 instance. |

## 6. Upload the File

```bash
aws s3 cp test.txt s3://tech613-ameen-first-bucket/
```

| Part | Meaning |
|---|---|
| `cp` | Copies data. |
| `test.txt` | Source file on EC2. |
| Bucket address | Destination in S3. |

This stores a copy of the local file in S3. The original remains on EC2.

## 7. List Objects in the Bucket

```bash
aws s3 ls s3://tech613-ameen-first-bucket/
```

### What Does This Do?

Lists objects inside the specified bucket.

It verifies that `test.txt` was uploaded.

**Difference:**

```bash
aws s3 ls
```
Lists buckets.

```bash
aws s3 ls s3://tech613-ameen-first-bucket/
```
Lists objects inside that bucket.

## 9. Download the Bucket Contents

### Create a Separate Download Folder

```bash
mkdir downloads
cd downloads
```

- `mkdir` creates the folder.
- `cd` enters it.

### Download Using Sync

```bash
aws s3 sync s3://tech613-ameen-first-bucket/ .
```

| Part | Meaning |
|---|---|
| `sync` | Copies new or changed files from source to destination. |
| Bucket address | Source. |
| `.` | Destination: the current directory. |

This is a one-way operation for this command, not continuous automatic synchronisation.

## Delete Objects

```bash
aws s3 rm s3://tech613-ameen-first-bucket/test.txt
```

| Part | Meaning |
|---|---|
| `rm` | Removes an object. |
| Bucket address and object key | Identify the object to remove. |

## Delete All Objects in the Practice Bucket

Then I remove the bucket’s objects:

```bash
aws s3 rm s3://tech613-ameen-first-bucket/ --recursive
```

| Part | Meaning |
|---|---|
| `rm` | Removes objects. |
| Bucket address | Selects the bucket contents. |
| `--recursive` | Applies removal to all objects under that path. |

**This deletes the practice bucket’s current objects without prompting. It keeps the bucket itself.**

### Try Removing the Bucket

```bash
aws s3 rb s3://tech613-ameen-first-bucket
```

- `rb` means remove bucket.
- This fails while the bucket contains the test object.

```bash
aws s3 rb s3://tech613-ameen-first-bucket --force
```

- `--force` removes the objects before attempting bucket deletion.
- I check the bucket name carefully before running it.
- The downloaded files on EC2 remain.


