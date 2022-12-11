# -*- mode: ruby -*-
# vi: set ft=ruby :

machines = {
  "master" => {"memory" => "512", "cpu" => "1", "ip" => "100", "image" => "bento/ubuntu-22.04"},
  "node01" => {"memory" => "512", "cpu" => "1", "ip" => "101", "image" => "bento/ubuntu-22.04"}
  #"node02" => {"memory" => "512", "cpu" => "1", "ip" => "107", "image" => "bento/ubuntu-22.04"},
  #"node03" => {"memory" => "512", "cpu" => "1", "ip" => "108", "image" => "bento/ubuntu-22.04"}
}

Vagrant.configure("2") do |config|
  
  machines.each do |name, conf|
    config.vm.define "#{name}" do |machine|
      machine.vm.box = "#{conf["image"]}"
      machine.vm.hostname = "#{name}"
      machine.vm.network "private_network", ip: "169.254.234.#{conf["ip"]}"
      machine.vm.provider "virtualbox" do |vb|
        vb.name = "#{name}"
        vb.memory = conf["memory"]
        vb.cpus = conf["cpu"]
        vb.customize ["modifyvm", :id, "--groups", "/Docker-Dio-Lab"]

      end
      machine.vm.provision "shell", path: "docker.sh"

      if "#{name}" == "master"
        machine.vm.provision "shell", path: "master.sh"
        
      else
        machine.vm.provision "shell", path: "worker.sh"
       # machine.vm.provision "shell", path: "worker_app.sh"
      end
    end
  end
end
