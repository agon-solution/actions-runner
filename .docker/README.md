# GitHub Self-Hosted Actions Runner

This repository demonstrates how to install and configure a
[self-hosted Actions Runner](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/about-self-hosted-runners)
inside a Docker container. The `actions runner` is configured to run jobs for a `GitHub repository`.

This repository provides
a [GitHub Actions workflow](https://docs.github.com/en/actions/writing-workflows/about-workflows)
that is triggered by a push event on the `main` branch. It updates the `index.html` file in a
[Docker Nginx container](https://hub.docker.com/_/nginx).

The GitHub Actions workflow assumes that the `Nginx container` is running on the same machine as the GitHub actions
runner. The job will exit with an error if the Nginx container is not running.

Note: If you prefer run the GitHub Actions Runner on the host machine, please refer to the dedicated
[README.md](../README.md) file instead.

## Pre-Requisites

- A GitHub account.
- A recent Debian-based system (e.g., Debian Bookworm) with an unprivileged `ocio-runner` user account
  (for the given example), and which can `sudo to root.
- A Docker installation on the system.
- Git installed on the system.

You can install the required packages on a Debian-based system as follows:

```bash
# Update the package list.
$ sudo apt update
# Install the required packages.
$ sudo apt install -y git
```

### Docker Stack Installation

You can install the full Docker stack, including Docker compose, by running the following commands:

```shell
# Download and install Docker.
sudo curl -fsSL https://get.docker.com | sh
# Add the current user to the docker group.
sudo usermod -aG docker $USER
```

Once done, you need to log out and log back in so that your group membership is re-evaluated. Please, don't execute the
docker command using `root` user privileges.

## Fork The Repository To Your GitHub Account

Fork this repository to your `GitHub` account. The forked repository will be used to test the `GitHub Actions Runner`.

## GitHub Actions Runner Installation And Configuration

For the given example, it is assumed that an unprivileged UNIX user named `ocio-runner` exists on the system. If you
want to use another user, make sure to replace `ocio-runner` with the desired username in the following steps.

### Add A New self-hosted GitHub Actions Runner On GitHub, For The Forked Repository

1. Go to the forked repository in GitHub (in your user account).
2. Go to `Settings` -> `Actions` -> `Runners` -> `New self-hosted runner`.
3. Copy the token which is displayed on the screen, in the configure section.

### Clone The Forked Repository On The Target Machine

```bash
# Change to the ocio-runner user's home directory
$ cd ~
# Clone the forked repository on the target machine
$ git clone git@github.com:<user>/actions-runner.git actions-runner-repository
# Change to the repository directory
$ cd actions-runner-repository
```

Replace `<user>` with your GitHub username.

**Note:** You should first create a new SSH key pair on the target machine for the `ocio-runner` user, and add the
public key to your GitHub account. You can create a new SSH key pair as follows:

```bash
# Create a new SSH key pair
$ ssh-keygen -t ed25519 -C "<email_address>"
```

Replace `<email_address>` with your email address.

Then, add the public key to your GitHub account by copying the content of the `~/.ssh/id_ed25519.pub` file.

### Build The GitHub Actions Runner Docker Image

```bash
# Change to the runner directory inside the repository.
cd ~/actions-runner-repository/runner
# Build the GitHub Actions Runner Docker image.
docker compose build --no-cache --pull
```

### Set The GitHub Actions Runner Service
Edit the ~/actions-runner-repository/runner/.env file and set the following environment variables:

- RUNNER_UR: The URL of the GitHub repository.
- RUNNER_TOKEN: The token copied from the GitHub repository settings.

```bash
# Start the GitHub Actions Runner.
$ docker compose up -d
```

## Start An Nginx Container For Testing Purposes

Start a `Nginx` container for testing purposes. The container will serve the  content of the `index.html` file from this
repository.

```bash
# Start the Nginx container in detached mode.
$ docker compose -f ~/actions-runner-repository/docker-compose.yml up -d
```

**Note:** It is assumed that the `ocio-runner` user has the necessary permissions to run Docker (e.g., added to the
`docker` group).

## Test The GitHub Actions Runner

1. Edit the `index.html` file inside the forked repository.
2. Commit and push the changes.
3. Wait for the runner to pick up the job and see the changes.
4. Check that the Nginx container is serving the updated `index.html` by visiting `http://<ip>:9988` in a Web browser.

Replace `<ip>` with the IP address of the machine running the Nginx container.

## Authors

> Laurent DECLERCQ, AGON PARTNERS INNOVATION AG <l.declercq@agon-innovation.ch>, for AGON PARTNERS SOLUTION GmbH.

## License

> © 2025 [AGON PARTNERS SOLUTION GmbH](https://agon-solution.ch). All rights reserved.
