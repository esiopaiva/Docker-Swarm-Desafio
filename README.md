# Projeto de Definição de Cluster Swarm com Vagrant

Neste desafio de projeto tem como objetivo criar um Cluster Swarm local, utilizando máquinas virtuais, com o uso da ferramenta Vagrant. Assim criando um ambiente de “infraestrutura como código” a fim de evitar as implementações manualmente, melhorando o desempenho dos desenvolvedores.

## Objetivos do Projeto :

1. Criar um Vagrantfile com as definições de 4 máquinas virtuais.
    1.  Sendo uma máquina com o nome de master e as outras com os nomes de node01, node02 e node03;
2. Cada máquina virtual deverá ter um IP fixo;
3. Todas as MV deverão possuir o Docker pré-instalado;
4. A máquina com o nome de master deverá ser o nó manager do cluster.
5. As demais máquinas deverão ser incluídas no cluster Swarm como Workers.

## ⚠️ Aviso importante

---

> Este repositório está sujeito a mudanças, por motivos de tentar adequar melhores praticas e compreensão maior do código em questão. De qualquer forma, caso esteja vendo esse repositório e encontrou algo que possa ser alterado para uma favorecer uma melhor qualidade de código ou aplicação, você pode me ajudar das seguintes maneiras:
> 
- Mande feedbacks no [Linkedin](https://www.linkedin.com/in/esiopaiva/)
- Entre em contato pelo e-mail: [esio_paiva@hotmail.com](mailto:esio_paiva@hotmail.com)

---

# Definição da implementação:

### - Vagrantfile

Arquivo responsável por descrever os detalhes da nossa infraestrutura e instanciar nossos Clusters diretamente utilizando o  Vagrant. 

O [Vagrantfile](https://github.com/esiopaiva/Docker-Swarm-Desafio/blob/main/Vagrantfile) 

Atualmente comporta 2 máquinas virtuais **(master e node01)** , devido a limitações da infraestrutura local. Contudo podem ser alteradas, basta retirar o comentário ****da linha pertinente ( indicado por **“ # “)** presente no arquivo. 

```bash
machines = {
  "master" => {"memory" => "512", "cpu" => "1", "ip" => "100", "image" => "bento/ubuntu-22.04"},
  "node01" => {"memory" => "512", "cpu" => "1", "ip" => "101", "image" => "bento/ubuntu-22.04"}
  #"node02" => {"memory" => "512", "cpu" => "1", "ip" => "102", "image" => "bento/ubuntu-22.04"},
  #"node03" => {"memory" => "512", "cpu" => "1", "ip" => "103", "image" => "bento/ubuntu-22.04"}
}
```

- Todas as máquinas possuem a seguinte configuração
    - Memória disponível: **512mb de RAM**
    - CPU: **1 Core de vCPU**
    - Imagem do sistema: **Utiliza a imagem bento/ubuntu-22.04**
    - IP:  O é definido para seguir o padrão com o final 100, 101, 102, […] respectivamente → `xxx.xxx.xxx.100`
        - A definição do valor prévio do endereço IP dependerá diretamente do adaptador de rede criado pelo Vagrant
        - Nosso nó **master** sempre terá o IP definido com o final 100 e os **workers** assumirão os IP’s subsequentes
        

Para a configuração da máquina virtual, iremos utilizar os parâmetros listados anteriormente, com a definição dos nossos nodes.

 O ponto importante é  a configuração  `machine.vm.network "private_network"` , pois ela possibilita a definição do nosso endereço IP,  no caso utilizo o endereço `169.254.234.xxx` e o final será definido por parâmetro utilizando a configuração dos nossos nós.

```bash
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
```

- A configuração: `vb.customize ["modifyvm", :id, "--groups", "/Docker-Dio-Lab"]` é para permitir agrupar os nós diretamente na infraestrutura do VirtualBox, assim facilitando a identificação das instancias.

![image](https://user-images.githubusercontent.com/32373902/207967508-75863d89-e98c-41c6-99ad-3e0782ae6388.png)


Ao final da instanciação, indicaremos que todas as nossas máquinas devem instalar o Docker, isso é feito diretamente pelo código:  

> `**machine.vm.provision "shell", path: "docker.sh"`**
> 

 - É possível indicar todos os pacotes que iremos instalar diretamente pelo Vagrant file, contudo, existe dois arquivos de script do linux para serem executados nos respectivos nós, permitindo a separação de cada componente da infraestrutura. 

 

### - Scrips .sh

- **master.sh:**
    - Inicializa nosso docker swarm por meio da máquina **“Master”** utilizando o primeiro ip reservado para nossa estrutura, que apresenta o endereço:  `xxx.xxx.xxx.100` e transfere o token para nosso arquivo `worker.sh`
    - Executa nosso script Docker compose, que permitirá a criação do nosso banco de dados (`mysql`) com a respectiva tabela inicializada que será utilizada em nossa aplicação, bem como, executar o serviço do phpmyadmin.
    - Cria um volume de dados onde utilizará para criar os serviços que serão inclusos no nossos Pod utilizando o `docker service create` com o total de **2 replicas,** a quantidade pode ser alterada a fim de contemplar a necessidade
        - Existe três linhas comentadas para permitir a instalação do servidor e a configuração do **NFS Server** caso deseje.
            - O servidor NFS está configurado para ser executado para compartilhar o volume `app_data`
- ****worker_app.sh****
    - Possuí a configuração do servidor NFS, utilizando o mount respectivo na pasta de volumer do docker `docker/volumes/app_data/_data/` a fim de permitir que toda e qualquer alteração na base do aplicativo. Ele deverá ser replicado automaticamente.
    
- **worker.sh**
    - O arquivo será vazio pois conterá o token de join do Docker Swarm assim que o **master.sh** for executado

### Para execução do código:

- Execute o com `vagrant up` todo build do projeto será feito automaticamente, para acessar a aplicação digite o respetivo ip do master, para que assim, seja direcionado automaticamente para um dos nós que estão rodando a aplicação.

A aplicação consiste em salvar um registro no banco de dados contendo a informação de qual hostname está fazendo o acesso a aplicação, salvando um id de registro único em nosso banco de dados. 

![image](https://user-images.githubusercontent.com/32373902/207967575-2b554ead-d647-4bd0-8e3d-ea22696586c3.png)
