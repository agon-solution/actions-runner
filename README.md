# GitHub Self-Hosted Actions Runner

This repository demonstrates how to install and configure a
[self-hosted Actions Runner](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/about-self-hosted-runners)
on a Debian-based system. The `actions runner` is configured to run jobs for a `GitHub repository`.

This repository provides
a [GitHub Actions workflow](https://docs.github.com/en/actions/writing-workflows/about-workflows)
that is triggered by a push event on the `main` branch. It updates the `index.html` file in a
[Docker Nginx container](https://hub.docker.com/_/nginx).

The GitHub Actions workflow assumes that the Nginx container is running on the same machine as the GitHub actions
runner.
The job will exit with an error if the Nginx container is not running.

## Pre-Requisites

- A GitHub account.
- A recent Debian-based system (e.g., Debian Bookworm) with an unprivileged `ocio-runner` user account
  (for the given example), and which can `sudo to root.
- A Docker installation on the system.
- cURl, tar, and git installed on the system.

You can install the required packages on a Debian-based system as follows:

```bash
  
# Update the package list
$ sudo apt update
# Install the required packages
$ sudo apt install -y curl tar git
```

### Docker Stack Installation

You can install the full Docker stack, including Docker compose, by running the following commands:

```shell
sudo curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
```

Once done, you need to log out and log back in so that your group membership is re-evaluated. Please, don't execute the
docker command using `root` user privileges.

## Fork The Repository To Your GitHub Account

Fork this repository to your `GitHub` account.

Replace `<user>` with your GitHub username.

## GitHub Actions Runner Installation And Configuration

For the given example, it is assumed that an unprivileged UNIX user named `ocio-runner` exists on the system. If you
want to use another user, make sure to replace `ocio-runner` with the desired username in the following steps, including
in the `ocio-runner.service` file (`user`, `WorkingDirectory`, and `ExecStart` fields).

### Download And Extract The GitHub Actions Runner Package

On the target machine (x64 assumed), download the runner package and extract it as follows:

```bash
# Change to the ocio-runner user's home directory
$ cd ~
# Create a dedicated directory for the actions runner
$ mkdir actions-runner && cd actions-runner
# Download the latest action runner package for Linux x64
$ curl -o actions-runner-linux-x64-2.322.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.322.0/actions-runner-linux-x64-2.322.0.tar.gz
# Extract the installer
$ tar xzf ./actions-runner-linux-x64-2.322.0.tar.gz
```

**Note:** Don't forget to check for latest version of the `actions runner`.

### Add A New self-hosted GitHub Actions Runner On GitHub, For The Forked Repository

1. Go to the forked repository in GitHub (in your user account).
2. Go to `Settings` -> `Actions` -> `Runners` -> `Add runner`.
3. Copy the token.

### Configure The GitHub Actions Runner

```bash
# Configure the actions runner
$ ./config.sh --url git@github.com:<user>/actions-runner.git --token <token>
```

Replace `<user>` with your GitHub username and `<token>` with the token copied from the GitHub repository settings.

For the questions, make use of default values, except for the runner name. For the given example, the runner name is
`ocio-runner`.

### Clone The Forked Repository On The Target Machine

```bash
# Clone the forked repository on the target machine
$ git clone git@github.com:<user>/actions-runner.git actions-runner-repository
# Change to the repository directory
$ cd actions-runner-repository
```

### Setup A Systemd Service Configuration For The GitHub Actions Runner

```bash
# Copy the service file to /etc/systemd/system/
$ sudo cp -a ocio-actions-runner.service /etc/systemd/system
# Reload the systemd configuration
$ sudo systemctl daemon-reload
# Enable the service
$ sudo systemctl enable ocio-actions-runner.service
# Start the service
$ sudo systemctl start ocio-actions-runner.service
```

## Start An Nginx Container For Testing Purposes

On the same machine as the actions runner, start a `Nginx` container for testing purposes. The container will serve the
content of the `index.html` file from this repository.

```bash
# Create a dedicated directory inside the ocio-runner user's home directory
$ mkdir ~/nginx-by-ocio-runner
# Copy the docker compose file into the newly created directory
$ cp -a docker-compose.yml ~/nginx-by-ocio-runner
# Start the Nginx container in detached mode
$ docker compose -f ~/nginx-by-ocio-runner/docker-compose.yml up -d
```

**Note:** It is assumed that the `ocio-runner` user has the necessary permissions to run Docker (e.g., added to the
`docker` group).

## Test The GitHub Actions Runner

1. Edit the `index.html` file inside this repository.
2. Commit and push the changes.
3. Wait for the runner to pick up the job and see the changes.
4. Check that the Nginx container is serving the updated `index.html` by visiting `http://<ip>:9988` in a Web browser.

Replace `<ip>` with the IP address of the machine running the Nginx container.

## Authors

> Laurent DECLERCQ, AGON PARTNERS INNOVATION AG <l.declercq@agon-innovation.ch>, for AGON PARTNERS SOLUTION GmbH

## License

> © Copyright - [AGON PARTNERS SOLUTION GmbH](https://agon-solution.ch)
