**>> THIS PROJECT IS UNDER CONSTRUCTION <<**

# DFY-Leads Appending Micro-Service

The **DFY-Leads Appending Micro-Service** (or **micro.dfyl.apppenidng**) has been development for the extenalization of the email appending and verificaiton tasks performed by [DFY-Leads](https://github.com/leandrosardi/dfy-leads) 

## 1. Abstract

Why **micro.dfyl.appending**?

### The Problem

As a [MySaaS](https://github.com/leandrosardi/mysaas) extension, DFY-Leads works over a [serverless CockroachDB instance](https://www.cockroachlabs.com/serverless/).

But as running too many backend-process, including a [Pampa dispatcher and many Pampa workers](https://github.com/leandrosardi/pampa), the databases expenses go high very quickly.

Even if the [Pampa](https://github.com/leandrosardi/pampa) architecture can scale with no limit when running over a distributed database like [CockroachDB](https://www.cockroachlabs.com/), it becomes very expensive.

![CockroachDB Expenses](/docu/crdb1.png)

### The Solution

The solution is to distrubute the backend processing into many different nodes (servers), each one running its own instance of [PostgreSQL](https://www.postgresql.org
).

## 2. Installation

### 2.1. Environment

**micro.dfyl.appending** has been developed and tested on the following environment:

- Ubuntu 20.04
- Ruby 3.1.2
- Bundler 2.3.7


On a `bash` terminal, run the commands below for for installing the environment:

```
wget https://raw.githubusercontent.com/ConnectionSphere/ms.dfyl.appending/main/cli/install.sh
bash install.sh
```

### 2.2. Database


## Configuration

## Running Micro-Service

## Access Ponts
