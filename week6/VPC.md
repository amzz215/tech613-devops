## Networking 

### VPC: Virtual Private Cloud 

A VPC is a logically isolated virtual network in AWS. With network being a place where cloud machines can communicate.

#### Why do I need it?
My app and database need a network to communicate over. The VPC also lets me organise their address space, subnets and routing.

Within my task both instances belong to the same custom VPC, but sit in different subnets. 

### Default versus custom VPC

- Default VPC: the network already available that I used for my earlier EC2 deployments.
- Custom VPC: a network I create and configure for my own requirements.

#### Why create a custom one?

Everyone shares the default VPC, so changing its routing or tightening its network configuration could disrupt other people. 

My own VPC lets me control the network for this application without changing the shared setup.

| Analogy | What it represents |
|---|---|
| Building | AWS |
| My allocated section of the building | My AWS account |
| Apartment | A VPC |
| Rooms inside the apartment | Subnets |
| Furniture or appliances placed in rooms | Virtual machines |

### Subnets and Availability Zones

**What is the relationship?**

Each subnet belongs entirely to one Availability Zone. When I launch an instance into that subnet, I also determine its AZ.

#### Why is this needed?

It lets me choose where instances run. To spread instances across AZs for availability, I need subnets in those different AZs.

### IPv4 and private address space

### CIDR notation

| Component | CIDR | Full address range |
|---|---|---|
| VPC | `10.0.0.0/16` | `10.0.0.0`–`10.0.255.255` |
| Public subnet | `10.0.2.0/24` | `10.0.2.0`–`10.0.2.255` |
| Private subnet | `10.0.3.0/24` | `10.0.3.0`–`10.0.3.255` |

### Subnets

A subnet is a smaller section of my VPC's IP address range, where I place instances. 

#### Why divide the VPC?

So different groups of instances can use different routing arrangements. For example, internet connectivity for the app while keeping the database private.

A public subnet has direct route to an internet gateway. A private subnet does not. 

### Internet Gateway 

An internet gateway is a VPC component that supports communication between the VPC and the internet. Essentially an entry point from the outside. 

This is needed so that users outside of AWS have a way to reach the public-facing parts of the app. 

However, for the internet table to be functioning I have to also configure the public subnet's route table. 

### Route tables

A set of rules that tells the VPC where to send traffic according to its destination. 

| Part | Meaning |
|---|---|
| Destination | The address range the traffic is trying to reach. |
| Target | Where to send that traffic next. |

This is needed so that the network is able to reach its destination. 

### Subnet associations

It links a subnet to the route table it uses. 

This ensures that the intended subnet uses its routes. 

A security group is created within a particular VPC. The old security group belongs to the default VPC, so I cannot attach it to an instance in the new custom VPC.

### Sources 

The address or group of instances from which an incoming connection is allowed.

A security-group rule specifies both which traffic is allowed and where it may come from.

| Traffic | Port | Allowed source |
|---|---:|---|
| SSH | 22 | `10.0.2.0/24` |
| MongoDB | 27017 | `10.0.2.0/24` |

### Jump boxes and bastion hosts

A jump box is a machine I connect through to reach another machine that is not directly accessible from my computer. A bastion host is a machine secured specifically for that access role.

#### Why are they useful?

They let me access a private database instance without giving that database a public IP.



