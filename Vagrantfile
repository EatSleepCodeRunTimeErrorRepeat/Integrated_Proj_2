Vagrant.configure("2") do |config|
  # Increase boot timeout to 10 minutes for slower boots
  config.vm.boot_timeout = 600

  # Shared host-only network base IP (optional, mostly for clarity)
  config.vm.network "private_network", ip: "192.168.56.10"

  # Flutter VM (Frontend)
  config.vm.define "flutter" do |flutter|
    flutter.vm.box = "ubuntu/focal64"
    flutter.vm.network "private_network", ip: "192.168.56.11"
    flutter.vm.provider "virtualbox" do |vb|
      vb.gui    = true    # Show VM console for debugging boot issues
      vb.memory = 2048
      vb.cpus   = 2
    end

    # Sync your local frontend folder to VM
    flutter.vm.synced_folder "./frontend", "/home/vagrant/frontend"

    flutter.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update
      sudo apt-get install -y git curl unzip xz-utils libglu1-mesa
    SHELL
  end

  # Node.js VM (Backend)
  config.vm.define "backend" do |backend|
    backend.vm.box = "ubuntu/focal64"
    backend.vm.network "private_network", ip: "192.168.56.12"
    backend.vm.provider "virtualbox" do |vb|
      vb.gui    = true
      vb.memory = 1024
      vb.cpus   = 1
    end

    # Sync your local backend folder to VM
    backend.vm.synced_folder "./backend", "/home/vagrant/backend"

    backend.vm.provision "shell", inline: <<-SHELL
      curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
      sudo apt-get install -y nodejs git
    SHELL
  end

  # PostgreSQL VM (Database)
  config.vm.define "db" do |db|
    db.vm.box = "ubuntu/focal64"
    db.vm.network "private_network", ip: "192.168.56.13"
    db.vm.provider "virtualbox" do |vb|
      vb.gui    = true
      vb.memory = 1024
      vb.cpus   = 1
    end

    # Sync your local database folder to VM
    db.vm.synced_folder "./database", "/home/vagrant/database"

    db.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update
      sudo apt-get install -y postgresql postgresql-contrib
      sudo -u postgres psql -c "CREATE USER peaksmart WITH PASSWORD 'secret';"
      sudo -u postgres psql -c "CREATE DATABASE peaksmart OWNER peaksmart;"
    SHELL
  end
end
