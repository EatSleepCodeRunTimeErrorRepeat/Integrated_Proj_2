Vagrant.configure("2") do |config|
  config.vm.boot_timeout = 1000

  # Shared private network:
  config.vm.network "private_network", ip: "192.168.56.10"

  # ─── Frontend VM ────────────────────────────────────────────────────────────
  config.vm.define "frontend" do |vm|
    vm.vm.box = "ubuntu/focal64"
    vm.vm.network "private_network", ip: "192.168.56.11"
    vm.vm.provider "virtualbox" do |vb|
      vb.memory = 2048; vb.cpus = 2
    end

    # Sync your Flutter project:
    vm.vm.synced_folder "./frontend", "/home/vagrant/frontend"

    # Install Docker engine
    vm.vm.provision "shell", inline: <<-SHELL
      set -e
      apt-get update && apt-get install -y \
        ca-certificates curl gnupg lsb-release
      mkdir -p /etc/apt/keyrings
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
      echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
        https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
        > /etc/apt/sources.list.d/docker.list
      apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io
      usermod -aG docker vagrant
    SHELL
  end

  # ─── Backend VM ─────────────────────────────────────────────────────────────
  config.vm.define "backend" do |vm|
    vm.vm.box = "ubuntu/focal64"
    vm.vm.network "private_network", ip: "192.168.56.12"
    vm.vm.provider "virtualbox" do |vb|
      vb.memory = 2048; vb.cpus = 2
    end

    vm.vm.synced_folder "./backend", "/home/vagrant/backend"

    vm.vm.provision "shell", inline: <<-SHELL
      set -e
      apt-get update && apt-get install -y \
        ca-certificates curl gnupg lsb-release
      mkdir -p /etc/apt/keyrings
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
      echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
        https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
        > /etc/apt/sources.list.d/docker.list
      apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io
      usermod -aG docker vagrant
    SHELL
  end

  # ─── Database VM ────────────────────────────────────────────────────────────
  config.vm.define "database" do |vm|
    vm.vm.box = "ubuntu/focal64"
    vm.vm.network "private_network", ip: "192.168.56.13"
    vm.vm.provider "virtualbox" do |vb|
      vb.memory = 1024; vb.cpus = 1
    end

    vm.vm.synced_folder "./database", "/home/vagrant/database"

    vm.vm.provision "shell", inline: <<-SHELL
      set -e
      apt-get update && apt-get install -y \
        ca-certificates curl gnupg lsb-release
      mkdir -p /etc/apt/keyrings
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
      echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
        https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
        > /etc/apt/sources.list.d/docker.list
      apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io
      usermod -aG docker vagrant
    SHELL
  end
end
