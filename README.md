
# F5 CIS with EKS

Demo deployment of CIS (in HA configuration) alongside EKS 


---

## Table of Contents



- [Introduction](#introduction)
- [Installation](#installation)
- [Support](#support)

## Introduction

This repository is split into two demos that show different use cases on how CIS can be used to publish resources that are deployed in EKS.<br>
In first demo the clients will be connecting through the internet to the public IPs that are created on the BIGIP and BIGIP will SNAT the client IP when it sends the connection back to EKS.<br>
With the use of a Terraform script we will deploy the following infrastructure in AWS:
* VPC with 6 subnets
* EKS with 2 nodes
* 2xBIGIP devices in HA configuration (PAYG License)

[![Network Diagram](https://github.com/skenderidis/f5-eks-demo/blob/main/images/F5-EKS-demo1.png?raw=true)]()

In the second demo the clients will be connecting through another VPC and BIGIP will NOT change the source IP address. To achieve symmetric traffic between F5 and EKS, we have configured a route on the EKS subnet to send the client's VPC traffic through the BIGIP devices.<br>
With the use of a Terraform script we will deploy the following infrastructure in AWS:
* VPC with 6 subnets
* EKS with 2 nodes
* 2xBIGIP devices in HA configuration (PAYG License)

[![Network Diagram](https://github.com/skenderidis/f5-eks-demo/blob/main/images/F5-EKS-demo2.png?raw=true)]()


> In both demos CFE and DO will be deployed with `run-time init` during the terraform deployment of the F5 devices.

Some of the use-cases that will be deployed for this demo are:
* Publish an web appplication that runs on EKS with the use of Virtual Server CRDs (Layer 7)
* Publish a TCP appplication that runs on EKS with the use of Transport Server CRDs (Layer 4)
* Publish a UDP appplication that runs on EKS with the use of Transport Server CRDs (Layer 4)
* Publish a STCP appplication that runs on EKS with the use of Transport Server CRDs (Layer 4)

The full list of use-cases can be found under kube/ingress. These are a combination of Ingress/CRDs/ConfigMaps that CIS supports


## Installation

- All the `code` required to get started
- Images of what it should look like




Once the infrastrucutre is deployed you 
* Declerative Onboarding 
 author, validate and maintain as code (vs. bigip.conf files)
* renders secre
 we have 2 


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


