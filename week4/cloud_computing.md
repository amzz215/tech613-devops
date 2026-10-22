## Cloud Computing

### What is Cloud Computing?

Cloud computing is accessing computing resources over a network, on demand, rather than buying and maintaining all the underlying hardware yourself.

| Resource | What it provides |
|---|---|
| Servers | Computing power to run applications |
| Storage | Space to store files |
| Databases | A system for storing and querying organised data |
| Networking | Connections between systems |

### Cloud vs on-premises

On-premises("on-prem") means an organisation runs infrasturcture at its own premises, such as servers in its office or data centre.

| | On-premises | Cloud |
|---|---|---|
| Physical hardware | Organisation typically buys and maintains it | Provider maintains it |
| Adding capacity | May require purchasing and installing hardware | Request more resources from the provider |
| Costs | Often substantial upfront hardware costs | Often ongoing usage charges |

Accessing something on the internet does not automatically make it cloud computing.

### Public cloud vs private cloud

Public and private clouds are example of cloud deployment models: these describe who the cloud infrastructure is available to.

| Model | Meaning | Analogy |
|---|---|---|
| **Public cloud** | A provider offers cloud resources to multiple customers, whose workloads may share physical hardware | Renting separate flats in the same building |
| **Private cloud** | A cloud environment is dedicated to one organisation | A building reserved for one organisation |

Tenancy describes who uses the infrastructure. 

### Hybrid cloud vs multi-cloud

| Model | Meaning | Example |
|---|---|---|
| **Hybrid cloud** | Connects private infrastructure, such as an on-premises environment or private cloud, with a public cloud | A company keeps its database on-premises and runs its website on AWS |
| **Multi-cloud** | Uses cloud services from more than one cloud provider | A company uses AWS for its website and Azure for another application |

| Group | Models | Why he grouped them this way |
|---|---|---|
| **Simple** | Public, private | Describe an individual cloud environment |
| **Complex** | Hybrid, multi-cloud | Combine environments or providers, adding management complexity |

### IaaS — Infrastructure as a Service

IaaS means renting computing infrastructure, such as virtual machines, storage and networking. The provider manages the physical hardware; I manage the operating system and applications running on your virtual machine. 

Essentially i rent the infrastructure, but still configure and maintain the system running on it. 

### PaaS — Platform as a Service

PaaS gives you managed enviornment to deploy and run your code. The provider manages the underlying infrastructure, operating system and runtime; you manage your application and date. 

Less system maintenance but less control also. 

### SaaS — Software as a Service

SaaS means using a complete application managed by a provider, usually through a browser or app. You use and configure the software instead of deploying is code or maintaining its servers. 

| Model | What you receive | Your main job |
|---|---|---|
| **IaaS** | Computing infrastructure | Configure the operating system and deploy your app |
| **PaaS** | A managed application platform | Deploy and manage your code and data |
| **SaaS** | A finished application | Use it and manage your settings, data and access |

### FaaS — Function as a Service

FaaS lets you provide a function that runs when an event triggers it. The provider manages the infrasturcture that executes your code. 

For example:
1. Someone uploads an image 
2. The upload triggers your function 
3. Your function creates a smaller version of the image

You manage the function’s code, permissions and configuration; the provider manages the servers used to run it.

### House Analogies for IaaS, PaaS, SaaS and FaaS:

| Model | House analogy |
|---|---|
| **IaaS** | You rent a basic house with essential utilities. You furnish it and maintain everything you install |
| **PaaS** | You rent a house whose utilities and maintenance are managed. You bring your furniture and belongings |
| **SaaS** | You rent a fully furnished, managed house. You move in and adjust the settings you’re allowed to change |
| **FaaS** | You provide instructions for a specific job, such as cleaning a room. When requested, the provider supplies the space and resources to perform that job |

### Scalability and Elasticity 

Scalability is the ability to increase or decrese a systems capacity/ requested resources to handle its workload. Elasticity means adjusting that capacity to match changing demand—adding resources when traffic rises and releasing them when it falls.

Scalability is elasticity but for a semi-permanent amount of time to handle a new workload. 

| Method | What changes | Example |
|---|---|---|
| **Vertical scaling** | The size of a machine | Give a server more CPU and RAM |
| **Horizontal scaling** | The number of machines | Run the website across more servers |

### CapEx vs OpEx

| Term | Meaning | Infrastructure example |
|---|---|---|
| **CapEx — capital expenditure** | Spending to acquire or improve long-term assets | Buying physical servers |
| **OpEx — operating expenditure** | Spending on ongoing operations | Paying for cloud resources you use |

### SLA — Service Level Agreement

An SLA is an agreement between a service provider and its customer defining the promised level of service and what happens if its isn't met. 

### SLO — Service Level Objective

An SLO is a measurable target for how well a service should perform. 

The Team will usual target an objective higher than what was promised to the customer to provide a buffer.

### SLI — Service Level Indicator

An SLI is a measurement of how well a service is actually performing, such as its availability, response time or error rate. 

So this is what the service is actually doing

### Cloud providers and USPs

A USP stands for a Unique Selling Point-a feature or strength that give customers a reson to choose one provider over another.

For most cloud providers it will either b experience within the field such is the case for AWS, or integration into that providers specific eco-system like microsoft or google. 

| Provider | Strengths Luke highlighted |
|---|---|
| **AWS — Amazon Web Services** | Long-established cloud offering, broad range of services, extensive documentation and experienced users |
| **Microsoft Azure** | Integration with Microsoft accounts, identity systems and existing Microsoft products |
| **Google Cloud — GCP** | Data analytics, containers and support for open-source technologies |

### EC2 instances — virtual machines

Amazon EC2 stands for Elastic Compute Cloud. An EC2 instance is a virtual machine—a computer provided through AWS’s infrastructure.

### Ports 

A port is a numbered network endpoint that helps direct traffic to the correct application or service on a machine 

Using a door analogy: the IP address identifies the machine, and the port identifies which service you want to reach on it.

| Port | Typical use |
|---|---|
| **22** | SSH — securely access a remote shell |
| **80** | HTTP — web traffic |
| **443** | HTTPS — encrypted web traffic |
| **3000** | Your Tic-Tac-Toe app’s configured listening port |

`http://63.33.51.229:3000`:
- `63.33.51.229` - identifies the server 
- `3000` - tells the browser where to direct web traffic

Ports are numbered 0 - 65,536

"Opening a port" allows traffic through a firewall or secruity group. The application must also be running and listening on that port for the connection to work. 

### SSH — Secure Shell and Key Pairs 

SSH lets your securely connect to another computer/VM and run commands on it. The connection is encrypted. 

An SSH key pair contains a public and a private key. They work together to authenticate your connection. 

| Part | Analogy | Where it is used |
|---|---|---|
| **Public key** | Padlock | Registered on the VM |
| **Private key** | Matching key | Kept securely on your laptop |

### Security groups — controlling network access

An AWS security group acts as a virtual firewall for your EC2 instance. Its rules control which network traffic is allowed. 

| Direction | Meaning | Example |
|---|---|---|
| **Inbound** | Traffic coming **into** your VM | Your laptop connecting through SSH |
| **Outbound** | Traffic going **from** your VM | Your VM downloading software |

Each rule has source: who may connect. For example, your public IP limits access to that address. But if we make the source all 0s this allows connections for all IP addresses. 

SCP securely transfers files over an SSH connection. 

### Availability regions and Zones

AWS Regions:
A region is a geographical area where AWS operates infrastructure, such as Europe(ireland) or Europe(London). When I run an instance I choose which regions that instance runs in. 

Availability Zones: 
A region contains multiple zones and each zone has multiple centres with separate power, networking, and connectivity, designed to isolate failures. If one centre goes offline for whatever reason. 





