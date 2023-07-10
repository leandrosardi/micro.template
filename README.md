This project is a template for the development of any micro-service.

# Getting Started

Create a new project using this one as a template, and then:

1. Replace `micro.template` by the name of your micro-service (e.g.: `micro.payments-processing`)

2. Write your **postgres** script for DDL installtion in the file `/sql/0.ddl.sql`.

3. Write your **postgres** script for inserting seed data in the file `/sql/1.seed.sql`.

4. Add your [Sequel](https://sequel.jeremyevans.net/) classes in the folder `/models/skeletons`.

5. Edit the file `/lib/skeletons.rb` requiring all the files in the folder `/models/skeletons`.

6. Add your additonal required gems in the `Gemfile`.

7. Require your additional gems in `/workmesh.rb`

8. Copy the file `config.template.rb` as `config.rb` and edit it.

9. Define [Pampa](https://github.com/leandrosardi/pampa) in the `config.rb` file, in order to run multi-threaded processing.

10. Write documentation of your access points and protocol in the last section (Access Points).

11. Follow the steps below to install your local environment.


Also, 

12. [How to pull changes from a template repository](https://stackoverflow.com/questions/56577184/github-pull-changes-from-a-template-repository)

-----

![MySaaS Micro-Services Logo](/public/core/images/micro/logo-100.png)

# micro.template

The **micro.template** has been development for the extenalization of the email appending and verificaiton tasks performed by [DFY-Leads](https://github.com/leandrosardi/dfy-leads) 

## 1. Abstract

Why **micro.template**?

### 1.1. The Problem

As a [MySaaS](https://github.com/leandrosardi/mysaas) extension, DFY-Leads works over a [serverless CockroachDB instance](https://www.cockroachlabs.com/serverless/).

But as running too many backend-process, including a [Pampa dispatcher and many Pampa workers](https://github.com/leandrosardi/pampa), the databases expenses go high very quickly.

Even if the [Pampa](https://github.com/leandrosardi/pampa) architecture can scale with no limit when running over a distributed database like [CockroachDB](https://www.cockroachlabs.com/), it becomes very expensive.

![CockroachDB Expenses](/public/core/images/micro/crdb1.png)

### 1.2. The Solution

The solution is to distrubute the backend processing into many different nodes (servers), each one running its own instance of [PostgreSQL](https://www.postgresql.org
).

## 2. Environment Installation

**micro.template** has been developed and tested on the following environment:

- Ubuntu 20.04
- Ruby 3.1.2
- Bundler 2.3.7

Follow the steps in this section to install the the environment for running the micro-service into an Ubuntu 20.04 instance.

### 2.1. Linux Packages

On a `bash` terminal, run the commands below for for installing the environment:

```bash
wget https://raw.githubusercontent.com/ConnectionSphere/micro.template/main/install.sh
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

### 2.4. Accepting Incoming Connections

```bash
cd /etc/postgresql/9.x/main/
```

Open file named `postgresql.conf`,

```bash
sudo nano postgresql.conf
```

and add this line to that file

```
listen_addresses = '*'
```

Then open file named `pg_hba.conf`,

```bash
sudo vi pg_hba.conf
```

and add this line to that file:

```
host  all  all 0.0.0.0/0 md5
```

Also, increase the number of max allowed connections:

```
max_connections = 250
```

It allows access to all databases for all users with an encrypted password.

Finally, restart your server

```
sudo /etc/init.d/postgresql restart
```

## 3. Service Installation

Follow the steps in this section to install the micro-service and run it.

### 3.1. Source Code

```bash
cd ~/code
git clone https://github.com/ConnectionSphere/micro.dfyl.appedning
```

### 3.2. Configuration

Copy `config.template.rb` as `config.rb` and edit it properly.

### 3.3. Database Schema

- Find the DDL in the file `/sql/0.ddl.sql`.
- Find the seed data in the file `/sql/1.seed.sql`.

## 4. Running Micro-Service

Run the listener.

```bash
cd ~/code/micro.template
ruby app.rb
```

Run the [Pampa](https://github.com/leandrosardi/pampa) dispatcher.

```bash
cd ~/code/micro.template/p
ruby dispatcher.rb
```

Run the [Pampa](https://github.com/leandrosardi/pampa) worker.

```bash
cd ~/code/micro.template/p
ruby worker.rb id=localhost.1
```

_NOTE: It is pending to add a command for running listenr, dispatcher and workers in background_

## 5. Access Points

_TODO: Write documentation the specific access points of your micro-service here._ 