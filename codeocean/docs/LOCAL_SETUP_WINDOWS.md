# Local Setup CodeOcean with Poseidon for Windows

**This native setup guide for CodeOcean with Windows is largely based on the already existing [Local Setup CodeOcean with Poseidon](https://gitlab.tu-ilmenau.de/mawe5834/swp2023-thema14/-/blob/master/codeocean/docs/LOCAL_SETUP.md) for Linux. The following version has been supplemented with some remarks and describes how the installation on Windows is possible without a virtual machine. The Windows subsystem for Linux (WSL) is used for this.** 

&nbsp;

CodeOcean is built as a micro service architecture and requires multiple components to work. Besides the main CodeOcean web application with a PostgreSQL database, a custom-developed Go service called [Poseidon](https://github.com/openHPI/poseidon) is required to allow code execution. Poseidon manages so-called Runners, which are responsible for running learners code. It is executed in (Docker) containers managed through Nomad. The following document will guide you through the setup of CodeOcean with all aforementioned components.

&nbsp;

We recommend using the **native setup** as described below. We also prepared a setup with Vagrant using a virtual machine as [described in this guide](./LOCAL_SETUP_VAGRANT.md). However, the Vagrant setup might be outdated and is not actively maintained (PRs are welcome though!)

&nbsp;

## Native setup for CodeOcean

Follow these steps to set up CodeOcean on **Windows** for development purposes:

&nbsp;

## Windows Subsystem for Linux (WSL)

For the following steps WSL will be required.

WSL can be installed with: 
```shell
wsl --install -d <DistroName>
````

Notice that you will need version 2 of wsl. in order to change the version, use the command: 
```shell 
wsl --set-version <DistroName> 2
````

Replace `<DistroName>` with the name of the Linux distribution you use (for Example Ubuntu).

Another (possibly easier) way to install WSL is to download a Linux distribution from the Microsoft Store. In case you do not need the introductions above.

An Ubuntu distribution is assumed in the following steps.


&nbsp;

### Install required dependencies 


```bash
sudo apt-get update

sudo apt-get -y install git ca-certificates curl libpq-dev libicu-dev
```

&nbsp;

### Install PostgreSQL 15:


```bash
curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null

echo "deb [arch=$(dpkg --print-architecture)] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list

sudo apt-get update && sudo apt-get -y install postgresql-15 postgresql-client-15

sudo service postgresql start

sudo -u postgres createuser $(whoami) -ed
```

**Check with:**

```bash
pg_isready
```

&nbsp;

### Install RVM:

We recommend using the [Ruby Version Manager (RVM)](https://www.rvm.io) to install Ruby.

```shell
gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

curl -sSL https://get.rvm.io | bash -s stable

source ~/.rvm/scripts/rvm
```

Ensure that your Terminal is set up to launch a login shell. You may check your current shell with the following commands:



```bash
shopt -q login_shell && echo 'Login shell' || echo 'Not login shell'
```

If you are not in a login shell, RVM will not work as expected. Follow the [RVM guide on gnome-terminal](https://rvm.io/integration/gnome-terminal) to change your terminal settings.



**Check with:**

```bash
rvm -v
```

&nbsp;

### Install NVM:

We recommend using the [Node Version Manager (NVM)](https://github.com/creationix/nvm) to install Node.

```bash
source ~/.bashrc
```

```shell
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
```

**Check with:**

```bash
nv -v
```

&nbsp;

### Install NodeJS 18 and Yarn:

Reload your shell (e.g., by closing and reopening the terminal) and continue with installing Node:

```bash
nvm install lts/hydrogen

corepack enable 
```

**Check with:**

```bash
node -v

yarn -v
```

If you have several Node versions installed, check that you are using the correct version. To view your installed versions, run:
```shell 
 nvm list
```

`lts/hydrogen` should be the current and default version. You can adjust this by running: 

``` shell
nvm alias default lts/hydrogen
```

&nbsp;

### Clone the repository:

You may either clone the repository via SSH (recommended) or HTTPS (hassle-free for read operations). If you haven't set up GitHub with your SSH key, you might follow [their official guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh).



**SSH (recommended, requires initial setup):**

```shell
git clone git@github.com:openHPI/codeocean.git
```



**HTTPS (easier for read operations):**

```shell
git clone https://github.com/openHPI/codeocean.git
```

&nbsp;

### Switch current working directory

This guide focuses on CodeOcean, as checked out in the previous step. Therefore, we are switching the working directory in the following. For Poseidon, please follow the [dedicated setup guide for Poseidon](https://github.com/openHPI/poseidon/blob/main/docs/development.md).



```bash
cd codeocean
```

### Install Ruby:

```shell
rvm install $(cat .ruby-version)
```

**Check with:**

```shell
ruby -v
```

If you have several Ruby versions installed, check that you are using the latest version. To view your installed versions, run `rvm list`. The most recent should be the current and default version. You can adjust this by running `rvm use <version_nr> --default`.

&nbsp;

### Create all necessary config files:

```shell
for f in action_mailer.yml code_ocean.yml content_security_policy.yml database.yml docker.yml.erb mnemosyne.yml secrets.yml

do

  if [ ! -f config/$f ]

  then

    cp config/$f.example config/$f

  fi

done
```



Then, you should check all config files manually and adjust settings where necessary for your environment.

For the basic setup you only need to 

- generate a secret with e.g. `rails secret` and then add it into the three CHANGE_ME fields in `secrets.yml`.

- add your username for the database in `database.yml`. For macOS, it is the same as your mac username.

&nbsp;

### Install required project libraries:

&nbsp;

```bash
bundle install

yarn install
```

&nbsp;

### Initialize the database:

The following command will create a database for the development and test environments, setup tables, and load seed data.

```bash
rake db:setup
```

&nbsp;

### Start CodeOcean:

For the development environment, two server processes are required: the Rails server for the main application and a Webpack server providing JavaScript and CSS assets.



1. **Webpack dev server:**



This project uses [shakapacker](https://github.com/shakacode/shakapacker) to integrate Webpack with Rails to deliver Frontend assets. During development, the `webpack-dev-server` automatically launches together with the Rails server if not specified otherwise. In case of missing JavaScript or stylesheets and for Hot Module Reloading in the browser, you might want to start the `webpack-dev-server` manually *before starting Rails*:

  ```shell
  yarn run webpack-dev-server
  ```



This will launch a dedicated server on port 3035 (default setting) and allow incoming WebSocket connections from your browser.



2. **Rails application:**



  ```shell
  bundle exec rails server
  ```



This will launch the CodeOcean web application server on port 7000 (default setting) and allow incoming connections from your browser.

&nbsp;

**Check with:**  

Open your web browser at <http://localhost:7000>



The default credentials for the internal users are the following:

- Administrator:  
  email: `admin@example.org`  
  password: `admin`
- Teacher:  
  email: `teacher@example.org`  
  password: `teacher`
- Learner:  
  email: `learner@example.org`  
  password: `learner`

Additional internal users can be created using the web interface. In development, the activation mail is automatically opened in your default browser. Use the activation link found in that mail to set a password for a new user.

&nbsp;

### Execution Environments

Every exercise is executed in an execution environment which is based on a docker image. In order to install a new image, have a look at the container images of the openHPI team on [GitHub](https://github.com/openHPI/dockerfiles) or [DockerHub](https://hub.docker.com/u/openhpi). You may change execution environments by signing in to your running CodeOcean server as an administrator and select `Execution Environments` from the `Administration` dropdown. The `Docker Container Pool Size` should be greater than 0 for every execution environment you want to use. Please refer to the Poseidon documentation for more information on the [requirements of Docker images](https://github.com/openHPI/poseidon/blob/main/docs/configuration.md#supported-docker-images).

&nbsp;

### Native Setup for Nomad

As detailed earlier, this guide focuses on CodeOcean. Nevertheless, the following provides a short overview of the most important steps to get started with Nomad (as required for Poseidon). Please refer to the [full setup guide](https://github.com/openHPI/poseidon/blob/main/docs/development.md) for more details.

&nbsp;

#### **Install Nomad**

```shell
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt-get update && sudo apt-get -y install nomad
```

**Start with**

```shell
sudo nomad agent -dev 
```

**Check with:**  

Open your web browser at <http://localhost:4646>

&nbsp;

#### **Enable Memory Oversubscription for Nomad**

The following command must be executed **every time** nomad is started.

```shell
curl -X POST -d '{"SchedulerAlgorithm": "spread", "MemoryOversubscriptionEnabled": true}' http://localhost:4646/v1/operator/scheduler/configuration 
```
&nbsp;

#### **Install Docker**

**We recommend using Docker Desktop, which you can install from [the Docker Website](https://www.docker.com/products/docker-desktop/)

It is also possible to use:** (*Do not use both options simultaneously!*)

```shell
curl -fsSL https://get.docker.com | sudo sh
```



**Check with:**

```shell
docker -v
```

&nbsp;

### Native Setup for Poseidon

As detailed earlier, this guide focuses on CodeOcean. Nevertheless, the following provides a short overview of the most important steps to get started with Poseidon. Please refer to the [full setup guide](https://github.com/openHPI/poseidon/blob/main/docs/development.md) for more details.

&nbsp;

**Install Go**
&nbsp;

```shell
gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 52B59B1571A79DBC054901C0F6BC817356A3D45E

gpg --export 52B59B1571A79DBC054901C0F6BC817356A3D45E | sudo tee /usr/share/keyrings/golang-backports.gpg >/dev/null

echo "deb [signed-by=/usr/share/keyrings/golang-backports.gpg] https://ppa.launchpadcontent.net/longsleep/golang-backports/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/golang.list

sudo apt-get update && sudo apt-get -y install golang
```



**Check with:**

```shell
go version
```

&nbsp;

#### **Clone the repository:**



You may either clone the repository via SSH (recommended) or HTTPS (hassle-free for read operations). If you haven't set up GitHub with your SSH key, you might follow [their official guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh).


**SSH (recommended, requires initial setup):**

```shell
git clone git@github.com:openHPI/poseidon.git
```



**HTTPS (easier for read operations):**

```shell
git clone https://github.com/openHPI/poseidon.git
```

&nbsp;

#### **Switch current working directory**

```shell
cd poseidon
```

&nbsp;

#### **Install required project libraries**

```shell
sudo make bootstrap
```

&nbsp;

#### **Build the binary**

```shell
sudo make build
```

&nbsp;

#### **Create the config file:**

First, copy our templates:


```shell
cp configuration.example.yaml configuration.yaml
```

Then, you should check the config file manually and adjust settings where necessary for your environment.

&nbsp;

#### **Run Poseidon**

```shell
./poseidon
```

&nbsp;

#### **Synchronize execution environments**

As part of the CodeOcean setup, some execution environments have been stored in the database. However, these haven't been yet synchronized with Poseidon yet. Therefore, please take care to synchronize environments through the user interface. To do so, open <http://localhost:7000/execution_environments> and click the "Synchronize all" button.

*Hints in case it does not work:*

- Press the button a second time after a few seconds.

- Docker must be started.

- Execution environments with network access are not running on macOS. Therefore, all execution environments in the list must be edited so that network access is disabled.



To check that everything works, you should also set the prewarming pool size to 1 for at least one execution environment. This can also be done via the edit function. Afterward it can be checked here <http://localhost:7000/admin/dashboard> that there are as many free runners as you have set before at pool size. In the nomad UI on <http://localhost:4646/ui/jobs> one can see the running jobs.

&nbsp;

### Start CodeOcean with all functionalities

The following part is intended to provide help and summary for starting CodeOcean. It is therefore not part of the actual installation and must be carried out individually for each start.

In order to start CodeOcean execute 4 instances of the Linux terminal.



**Terminal 1:**

```shell
sudo service postgresql start
```

```shell
sudo nomad agent -dev 
```

**Terminal 2:**

```shell
cd poseidon

./poseidon 
```

**Terminal 3:**

```shell
cd codeocean

yarn run webpack-dev-server
```

**Terminal 4:**

```shell
cd codeocean

bundle exec rails server
```