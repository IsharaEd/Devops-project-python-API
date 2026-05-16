Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-24.04"

  nodes = {
    "control-plane" => { "ip" => "192.168.56.10", "mem" => 4096, "cpu" => 2 },
    "app-server"    => { "ip" => "192.168.56.11", "mem" => 2048, "cpu" => 1 },
    "db-server"     => { "ip" => "192.168.56.12", "mem" => 2048, "cpu" => 1 }
  }

  nodes.each do |name, conf|
    config.vm.define name do |node|
      node.vm.hostname = name
      node.vm.network "private_network", ip: conf["ip"]

      node.vm.provider "virtualbox" do |vb|
        vb.name   = name
        vb.memory = conf["mem"]
        vb.cpus   = conf["cpu"]
        vb.gui    = false
      end
    end
  end
end
