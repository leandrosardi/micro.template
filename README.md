**>> THIS PROJECT IS UNDER CONSTRUCTION <<**

![MySaaS Micro-Services Logo](/public/core/images/micro/logo-100.png)

# DFY-Leads Appending Micro-Service

The **DFY-Leads Appending Micro-Service** (or **micro.dfyl.apppenidng**) has been development for the extenalization of the email appending and verificaiton tasks performed by [DFY-Leads](https://github.com/leandrosardi/dfy-leads) 

## 1. Abstract

Why **micro.dfyl.appending**?

### The Problem

As a [MySaaS](https://github.com/leandrosardi/mysaas) extension, DFY-Leads works over a [serverless CockroachDB instance](https://www.cockroachlabs.com/serverless/).

But as running too many backend-process, including a [Pampa dispatcher and many Pampa workers](https://github.com/leandrosardi/pampa), the databases expenses go high very quickly.

Even if the [Pampa](https://github.com/leandrosardi/pampa) architecture can scale with no limit when running over a distributed database like [CockroachDB](https://www.cockroachlabs.com/), it becomes very expensive.

![CockroachDB Expenses](/public/core/images/micro/crdb1.png)

### The Solution

The solution is to distrubute the backend processing into many different nodes (servers), each one running its own instance of [PostgreSQL](https://www.postgresql.org
).

## 2. Environment Installation

**micro.dfyl.appending** has been developed and tested on the following environment:

- Ubuntu 20.04
- Ruby 3.1.2
- Bundler 2.3.7

Follow the steps in this section to install the the environment for running the micro-service into an Ubuntu 20.04 instance.

### 2.1. Linux Packages

On a `bash` terminal, run the commands below for for installing the environment:

```bash
wget https://raw.githubusercontent.com/ConnectionSphere/ms.dfyl.appending/main/install.sh
bash install.sh
```

### 2.2. Database Instance

In the same `bash` terminal, create a new postgres user with superuser rights.

```bash
sudo -u postgres createuser --interactive
```

The output is like this.

```bash
Enter name of role to add: blackstack
Shall the new role be a superuser? (y/n) y
```

### 2.3. Database Password

In the same `bash` terminal, access the **postgres** terminal.

```bash
sudo -u postgres psql
```

And then run this **postgres** command to assign a new password to the **blackstack** user.

```psql
\password blackstack
```

## 3. Service Installation

Follow the steps in this section to install the micro-service and run it.

### 3.1. Source Code

```bash
cd ~/code
git clone https://github.com/ConnectionSphere/micro.dfyl.appedning
```

### 3.2. Configuration



### 3.3. Database Schema

```bash
cd ~/code/micro.dfyl.appending
ruby install.rb
```

## Running Micro-Service

```bash
cd ~/code/micro.dfyl.appending
ruby start.rb
```

## Access Ponts
