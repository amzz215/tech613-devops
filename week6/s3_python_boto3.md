# Managing AWS S3 Using Python Boto3

## What Is Boto3?

Boto3 is the AWS Software Development Kit (SDK) for Python. It allows Python code to interact with AWS services, including S3. Previously, I used CLI to manipulate the AWS services and S3. 

I create six separate Python scripts to:

1. I list S3 buckets.
2. I create a bucket.
3. I upload a file.
4. I download a file.
5. I delete an object.
6. I delete the bucket.

## 1. Create a Project Folder

```bash
cd ~
mkdir -p s3-boto3-task
cd s3-boto3-task
```

| Command | Meaning | Why |
|---|---|---|
| `cd ~` | Moves to the current user’s home directory. | Gives me a known starting location. |
| `mkdir -p s3-boto3-task` | Creates the project folder if needed. | Keeps the task’s files together. |
| `cd s3-boto3-task` | Enters the folder. | Places subsequent files inside the project. |

## 2. Install Python and Virtual-Environment Support

```bash
sudo apt-get update
sudo apt-get install python3 python3-venv -y
```

| Part | Meaning |
|---|---|
| `sudo` | Runs with administrator permissions. |
| `apt-get update` | Refreshes available package information. |
| `python3` | Installs Python to run the scripts. |
| `python3-venv` | Provides Python virtual-environment support. |
| `-y` | Automatically answers yes to installation prompts. |

## 3. Create and Activate a Virtual Environment

```bash
python3 -m venv .venv
source .venv/bin/activate
```

### Why Is It Needed?

It keeps this project’s dependencies separate from Ubuntu’s system Python.

| Part | Meaning |
|---|---|
| `python3 -m venv` | Runs Python’s virtual-environment tool. |
| `.venv` | Names the environment directory. |
| `source .venv/bin/activate` | Makes the current terminal use the environment. |

The terminal prompt should now show `(.venv)`.

## 4. Install Boto3

```bash
python -m pip install boto3
```

- `python -m pip` runs the active environment’s package installer.
- `install boto3` installs Boto3 and its dependencies.

## 5. Configure AWS Authentication

If credentials are already configured for the same Ubuntu user, I reuse them. Otherwise, I run:

```bash
aws configure
```

## 6. List S3 Buckets

### Create the Script

```bash
nano list_buckets.py
```

```python
import boto3

s3 = boto3.client("s3")

response = s3.list_buckets()

for bucket in response["Buckets"]:
    print(bucket["Name"])
```

### Code Breakdown

| Code | Meaning |
|---|---|
| `import boto3` | Imports the AWS SDK. |
| `boto3.client("s3")` | Creates a client for making S3 requests. |
| `s3.list_buckets()` | Requests the account’s bucket list. |
| `response` | Stores the returned response dictionary. |
| `response["Buckets"]` | Accesses the list of buckets. |
| `for bucket in ...` | Loops through that list. |
| `bucket["Name"]` | Retrieves each bucket’s name. |
| `print(...)` | Displays the name. |

### Why Is It Needed?

It lists buckets through Python and tests whether the configured credentials permit the operation.

### Run

```bash
python list_buckets.py
```

## 7. Create an S3 Bucket

### Create the Script

```bash
nano create_bucket.py
```

```python
import boto3

s3 = boto3.client("s3", region_name="eu-west-1")

s3.create_bucket(
    Bucket="tech613-ameen-test-boto3",
    CreateBucketConfiguration={
        "LocationConstraint": "eu-west-1"
    }
)

print("Bucket created")
```

### Code Breakdown

| Code | Meaning |
|---|---|
| `region_name="eu-west-1"` | Configures the client to use Ireland. |
| `create_bucket(...)` | Requests a new bucket. |
| `Bucket` | Specifies the bucket name. |
| `CreateBucketConfiguration` | Supplies bucket-creation settings. |
| `LocationConstraint` | Specifies the bucket’s region. |

### Why Is It Needed?

A bucket must exist before I upload objects into it.

For this Ireland configuration, the creation request includes `LocationConstraint`.

I use an available bucket name. If it changes, I update every script that references it.

### Run and Verify

```bash
python create_bucket.py
python list_buckets.py
```
## 8. Upload a File

### Create a Test File

I run from the project folder:

```bash
echo "Hello from my Boto3 script." > test.txt
```

This creates the local file to upload.

### Create the Script

```bash
nano upload_file.py
```

```python
import boto3

s3 = boto3.client("s3")

s3.upload_file(
    "test.txt",
    "tech613-ameen-test-boto3",
    "test.txt"
)

print("File uploaded")
```

### Argument Breakdown

| Argument | Meaning |
|---|---|
| First `"test.txt"` | Source file on the EC2 instance. |
| `"tech613-ameen-test-boto3"` | Destination bucket. |
| Last `"test.txt"` | Object key used to identify the uploaded object. |

### Why Is It Needed?

It copies a local file into S3. The local original remains.

### Run and Verify

```bash
python upload_file.py

aws s3 ls s3://tech613-ameen-test-boto3/
```

## 9. Download the File

### Create the Script

```bash
nano download_file.py
```

```python
import boto3

s3 = boto3.client("s3")

s3.download_file(
    "tech613-ameen-test-boto3",
    "test.txt",
    "downloaded_test.txt"
)

print("File downloaded")
```

### Argument Breakdown

| Argument | Meaning |
|---|---|
| `"tech613-ameen-test-boto3"` | Source bucket. |
| `"test.txt"` | Object key to retrieve. |
| `"downloaded_test.txt"` | Destination filename on EC2. |

### Why Is It Needed?

It retrieves the stored object and saves a local copy.

The different destination name avoids overwriting my original `test.txt`.

### Run and Verify

```bash
python download_file.py
cat downloaded_test.txt
```

## 10. Delete the Object

### Create the Script

```bash
nano delete_file.py
```

```python
import boto3

s3 = boto3.client("s3")

s3.delete_object(
    Bucket="tech613-ameen-test-boto3",
    Key="test.txt"
)

print("File deletion requested")
```

### Code Breakdown

| Code | Meaning |
|---|---|
| `delete_object(...)` | Requests deletion of an S3 object. |
| `Bucket` | Identifies its bucket. |
| `Key` | Identifies the object. |

### Run and Verify

```bash
python delete_file.py

aws s3 ls s3://tech613-ameen-test-boto3/
```

## 11. Delete the Empty Bucket

### Create the Script

```bash
nano delete_bucket.py
```

```python
import boto3

s3 = boto3.client("s3")

s3.delete_bucket(Bucket="tech613-ameen-test-boto3")

print("Bucket deleted")
```

### What Does It Do?

`delete_bucket` removes the named bucket.

### Why Is It Needed?

It completes the exercise and removes the practice resource.

The bucket must be empty, which is why object deletion comes first.

### Run and Verify

```bash
python delete_bucket.py
python list_buckets.py
```

The practice bucket should no longer appear.

## Script Execution Order

I run from the project folder with the virtual environment active:

```bash
python list_buckets.py
python create_bucket.py
python upload_file.py
python download_file.py
python delete_file.py
python delete_bucket.py
```

I create `test.txt` before running the upload script.

The scripts use fixed names and are intended to be run in this order. They do not contain additional error handling.

