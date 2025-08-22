#!/bin/sh
apt-get update -y 2>&1 | /usr/bin/logger -t GITHUB_RUNNER

# install jq for json processing
apt-get install jq -y 2>&1 | /usr/bin/logger -t GITHUB_RUNNER

# installing the github runner
mkdir /opt/actions-runner && cd /opt/actions-runner

# Download the latest runner package
curl -o actions-runner-linux-arm64-2.320.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.320.0/actions-runner-linux-arm64-2.320.0.tar.gz

# Optional: Validate the hash
echo "bec1832fe6d2ed75acf4b7d8f2ce1169239a913b84ab1ded028076c9fa5091b8  actions-runner-linux-arm64-2.320.0.tar.gz" | shasum -a 256 -c

# Extract the installer
tar xzf ./actions-runner-linux-arm64-2.320.0.tar.gz

export RUNNER_ALLOW_RUNASROOT="1"

# TODO Use a PAT to acquire a registration token
# acquire a registration token with the github access token
echo "Acquiring Runner registration token" | /usr/bin/logger -t GITHUB_RUNNER
REGISTRATION_TOKEN=$(curl -L \
                            -X POST \
                            -H "Accept: application/vnd.github+json" \
                            -H "Authorization: Bearer ${github_token}" \
                            -H "X-GitHub-Api-Version: 2022-11-28" \
                            https://api.github.com/orgs/QuarphixCorp/actions/runners/registration-token | jq -r '.token')

echo "Configuring Runner with registration token" | /usr/bin/logger -t GITHUB_RUNNER
# Create the runner and start the configuration experience
./config.sh --unattended --url https://github.com/QuarphixCorp --token $REGISTRATION_TOKEN

# install the runner as a service
./svc.sh install

./svc.sh start

# Add Docker's official GPG key:
apt-get install ca-certificates curl gnupg unzip -y 2>&1 | /usr/bin/logger -t GITHUB_RUNNER
install -m 0755 -d /etc/apt/keyrings 2>&1 | /usr/bin/logger -t GITHUB_RUNNER
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>&1 | /usr/bin/logger -t GITHUB_RUNNER
chmod a+r /etc/apt/keyrings/docker.gpg 2>&1 | /usr/bin/logger -t GITHUB_RUNNER

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y 2>&1 | /usr/bin/logger -t GITHUB_RUNNER

# install the latest version of docker
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y 2>&1 | /usr/bin/logger -t GITHUB_RUNNER

# start the docker service just in case it was not started.
service docker start | /usr/bin/logger -t GITHUB_RUNNER

# echo the status of the service into the logs
service docker status | /usr/bin/logger -t GITHUB_RUNNER

docker run hello-world | /usr/bin/logger -t GITHUB_RUNNER

# installing amazon credential helper
echo "installing amazon credential helper" | /usr/bin/logger -t GITHUB_RUNNER
apt-get install amazon-ecr-credential-helper -y 2>&1 | /usr/bin/logger -t GITHUB_RUNNER

# installing nodejs
cd /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
NODE_MAJOR=16
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
apt-get update
apt-get install nodejs -y

# installing cypress dependencies to make cypress work
apt-get install libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libnss3 libxss1 libasound2 libxtst6 xauth xvfb -y

# configuring the runner to support multi-architecture docker builds
echo "@reboot         root    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes" >> /etc/crontab
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
