
# F5 CIS with EKS

Providing Ingress Services for EKS with F5 CIS (in HA configuration) 


---

## Table of Contents



- [Introduction](#introduction)
- [Pre-requisites](#pre-requisites)
- [Support](#support)

## Introduction

This repository is split into two demos that show different use cases on how CIS can be used to publish ingress services for EKS.<br>
In first demo the clients will be connecting through the internet to the public IPs that are created on the BIGIP and BIGIP will SNAT the client IP when it sends the connection back to EKS.<br>
With the use of a Terraform script we will deploy the following infrastructure in AWS:
* Main VPC with 6 subnets
* EKS with 2 nodes
* 2xBIGIP devices in HA configuration (PAYG License)
* Routes, ENIs, EIPs, Security Groups, IGW, NAT Gateways, etc
* Initial configuration of F5 devices with DO and CFE 

[![Network Diagram](https://github.com/skenderidis/f5-eks-demo/blob/main/images/F5-EKS-demo1.png?raw=true)]()

In the second demo the clients will be connecting through another VPC and BIGIP will NOT change the source IP address. To achieve symmetric traffic between F5 and EKS, we have configured a route on the EKS subnet to send the client's VPC traffic through the BIGIP devices.<br>
With the use of a Terraform script we will deploy the following infrastructure in AWS:
* Main VPC with 6 subnets
* EKS with 2 nodes
* 2xBIGIP devices in HA configuration (PAYG License)
* Clients VPC devices in HA configuration (PAYG License)
* Test PC on clients VPC
* Routes, ENIs, EIPs, Security Groups, IGW, NAT Gateways, etc
* Initial configuration of F5 devices with DO and CFE 

[![Network Diagram](https://github.com/skenderidis/f5-eks-demo/blob/main/images/F5-EKS-demo2.png?raw=true)]()

> In both demos CFE and DO will be deployed with `run-time init` during the terraform deployment of the F5 devices.

Some of the ingress services that will be deployed during this demo are:
* Virtual Server CRDs (Layer 7) to publish an web appplication that runs on EKS
* Transport Server CRDs (Layer 4) to publish a TCP appplication that runs on EKS
* Transport Server CRDs (Layer 4) to publish a UDP appplication that runs on EKS
* ConfigMap tp publish a STCP appplication that runs on EKS.

The full list of ingress serfvices can be found on the directory Demo-*/kube/ingress.


## Pre-requisistes

- Terraform installed
- AWS credentials for programmatic access
- For the demo we are using a PAYG License of BIGIP 200 Best Bundle. In order for Terraform to able to deploy this instance you would need to "Accept Terms" on the AWS Marketplace. 
Go to "AWS Marketplace subscriptions" page and select “Discover products” from the left column. Then type “BIGIP 200Mbps Best” in the search box. Select the BIGIP 200Mbps => “Continue to Subscribe” => “Accept Terms”
> This might take some time to be approved


## Installation

Use git pull to make a local copy of the Terraform code.
```shell
git clone https://github.com/dudesweet/f5_terraform.git
```

Navigate to directory "Demo-1" or "Demo-2" depending on your requirements. This is example we will navigate to Demo-1 directory
```shell
cd f5-eks-demo/Demo-1
```
Run the following command to initialize Terraform
```shell
terraform init 
```

Run the command `terraform plan` to see the changes that are going to be made.
```shell
terraform plan 
```

To build the Lab infrastructure run the command `terraform apply`.
```shell
terraform apply
```
> "terraform apply" will prompt you with a yes/no to confirm if you want to go ahead and make the changes.



## Installation

- All the `code` required to get started
- Images of what it should look like

### Clone

- Clone this repo to your local machine using `https://github.com/fvcproductions/SOMEREPO`

### Setup

- If you want more syntax highlighting, format your code like this:

> update and install this package first

```shell
$ brew update
$ brew install fvcproductions
```

> now install npm and bower packages

```shell
$ npm install
$ bower install
```

- For all the possible languages that support syntax highlithing on GitHub (which is basically all of them), refer <a href="https://github.com/github/linguist/blob/master/lib/linguist/languages.yml" target="_blank">here</a>.

---

## Features

## Support


