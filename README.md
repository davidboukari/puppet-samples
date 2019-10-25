### puppet-samples ###

# Create a new module
```bash
pdk new module mypdk
pdk new class mypdk
```

# show fact
```bash
facter -p
FACTERLIB=/var/lib/puppet/lib/facter:/var/lib/puppet/facts  facter -p
```

# Write a module
```bash
puppet config print
cd ...
puppet module generate fullstackpuppet-ntp
```

# Create a Puppetfile and install plugins
```bash
cat Puppetfile
mod 'puppetlabs-stdlib', '6.0.0'
mod 'saz-sudo', '6.0.0'
mod 'puppet-grafana', '6.0.0'

r10k puppetfile install
```

# https://puppet.com/docs/pdk/1.x/pdk_testing.html
```bash
pdk  test unit

For just a compil without pki
puppet agent --test --waitforcert 10
```

### Install puppetserver ###
```bash
rpm -Uvh https://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm
yum update
yum install puppetserver
#Edit puppetserver service unit memory setting
vim /etc/sysconfig/puppetserver 

# Read certificate
cd /etc/puppetlabs/puppet/ssl
openssl x509 -text -noout -in ca/ca_crt.pem
openssl s_client -showcerts -connect ma.ttias.be:443

$ ls /opt/puppetlabs/
bin  facter  mcollective  puppet  pxp-agent  server

$ ls /opt/puppetlabs/puppet/bin/
augparse  c_rehash     dmidecode        facter  hiera  mco           puppet     rdoc     rmsgfmt    ruby       testrb       xmlcatalog   xsltproc
augtool   curl         erb              fadot   hocon  mcollectived  pxp-agent  ri       rmsginit   rxgettext  virt-what    xmllint
catstomp  curl-config  extlookup2hiera  gem     irb    openssl       rake       rmsgcat  rmsgmerge  stompcat   xml2-config  xslt-config

# Jvm conf
$ cat  /etc/sysconfig/puppetserver 
# Init settings for puppetserver
JAVA_BIN="/usr/bin/java"
#JAVA_ARGS="-Xms2g -Xmx2g -XX:MaxPermSize=256m"
JAVA_ARGS="-Xms2g -Xmx2g"
USER="puppet"
GROUP="puppet"
INSTALL_DIR="/opt/puppetlabs/server/apps/puppetserver"
CONFIG="/etc/puppetlabs/puppetserver/conf.d"
BOOTSTRAP_CONFIG="/etc/puppetlabs/puppetserver/services.d/,/opt/puppetlabs/server/apps/puppetserver/config/services.d/"
SERVICE_STOP_RETRIES=60
START_TIMEOUT=300
RELOAD_TIMEOUT=120

cat /etc/sysconfig/puppet
# You may specify parameters to the puppet client here
#PUPPET_EXTRA_OPTS=--waitforcert=500

#Service conf
$ cat /usr/lib/systemd/system/puppet.service|grep -v '#'
[Unit]
Description=Puppet agent
Wants=basic.target
After=basic.target network.target
[Service]
EnvironmentFile=-/etc/sysconfig/puppetagent
EnvironmentFile=-/etc/sysconfig/puppet
EnvironmentFile=-/etc/default/puppet
ExecStart=/opt/puppetlabs/puppet/bin/puppet agent $PUPPET_EXTRA_OPTS --no-daemonize
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
[Install]
WantedBy=multi-user.target

$ cat /etc/profile.d/puppet-agent.sh 
if ! echo $PATH | grep -q /opt/puppetlabs/bin ; then
  export PATH=$PATH:/opt/puppetlabs/bin
  export PATH=$PATH:/opt/puppetlabs/puppet/bin
fi
if ! echo $MANPATH | grep -q /opt/puppetlabs/puppet/share/man ; then
  export MANPATH=$MANPATH:/opt/puppetlabs/puppet/share/man
fi

$ rpm -q puppet-agent
puppet-agent-1.10.14-1.el7.x86_64

$ puppet --version
4.10.12

$ ls /etc/puppetlabs/code/environments/
master  production  staging  test

# Hiera conf
$ ls /etc/puppetlabs/puppet
auth.conf  hiera.yaml  puppet.conf  r10k.yaml  ssl

$ service puppetserver status
$ service puppetserver start
$ netstat -laputen|grep 8140
tcp6       0      0 :::8140                 :::*                    LISTEN      52         59634      31127/java     
```

## Certificate ##
```bash
$ puppet cert list

[root@puppetmaster ~]# puppet cert list --all
+ "puppetmaster" (SHA256) D1:B2:6E:5C:A9:C3:DF:2C:00........... (alt names: "DNS:puppet", "DNS:puppetmaster")

$ puppet cert sign <agent name>

$ puppet cert sign <agent name>

$ puppet cert clean centos-agent
```

# Show the fact

facter
facter |grep hostname

# Set puppetserver in conf file

cat /etc/puppetlabs/puppet/puppet.conf |grep -v "#"
[main]
server = puppetmaster


# Check the puppet configuration

puppet config print
puppet config print|grep module

# Apply the agent with a server

puppet agent -t --server puppetmaster


# Apply an environ

puppet agent -t --server puppetmaster --environment development

# Template ruby .erb

https://puppet.com/docs/puppet/6.4/lang_template_erb.html

# Check the syntax

puppet parser validate init.pp

### Syntax ###

content => @("CONF"/L)
This is the content of the 
file...
...
 | CONF

### Install a puppet server from scrash ###

* Install the depot by puppetlabs
* Update script on /etc/sysconfig/puppetserver.conf (jvm memory)
* Edit /etc/hosts and add hosts name
* Generate certificates: puppet cert 
  puppet cert list -a
  cd /etc/puppetlabs/puppet/ssl/certs/ ; ls -lahtr
  puppet cert generate --dns_alt_names puppet,puppet.dev.example.com,puppet.prod.example.com --ca-location local
  puppet cert generate puppetdemomaster --dns_alt_names puppetdemomaster,uppetdemomaster.clients.t70.sncf
  ls certificate_requests 
  puppet cert sign puppet.example.com --allow-dns-alt-names
  systemctl start puppetserver
* Open the port:
    firewalld --add-port:8140/tcp 
    firewalld --add-port:8140/tcp --permanent



### git & r10k ###

git init --bare $HOME/gitrepo/control.git
git clone $HOME/repogit/control.git
cd control
touch environment
touch manifests/site.pp
git commit -am "1st" commit
git push origin master

cd /etc/puppetlabs/code/environment
git clone $HOME/repo

gem install r10k
Fetching r10k-3.3.1.gem
Fetching puppet_forge-2.3.0.gem
Successfully installed puppet_forge-2.3.0
Successfully installed r10k-3.3.1
Parsing documentation for puppet_forge-2.3.0
Installing ri documentation for puppet_forge-2.3.0
Parsing documentation for r10k-3.3.1
Installing ri documentation for r10k-3.3.1
Done installing documentation for puppet_forge, r10k after 1 seconds
2 gems installed

### Deploy the environment: Deploy the environment with the branch & install plug in by using PuppetFile ###

cat /etc/puppetlabs/r10k/r10k.yaml 
#sources:
#  operartions:
#    remote: 'git@github.com:davidboukari/environments.git'
#    basedir: '/etc/puppetlabs/code/environments'
#    prefix: false
#

sources:
  :control:
    remote: '/root/repogit/control.git'
    basedir: '/etc/puppetlabs/code/environments'
    prefix: false
  :ctl:
    remote: '/root/repogit/control.git'
    basedir: '/etc/puppetlabs/code/environments'
    prefix: true

r10k deploy  environment
r10k -c /etc/puppetlabs/puppet/r10k.yaml deploy  environment

puppet agent -t --environment ctl_production    
puppet agent -t --environment production    


## Install new modules in the directory by using a puppet file ##
See https://forge.puppet.com/puppetlabs&:w

[root@puppetmaster development]# pwd
/etc/puppetlabs/code/environments/development
[root@puppetmaster development]# ls
environment.conf  manifests  Puppetfile

/etc/puppetlabs/code/environments/development
[root@puppetmaster development]# cat Puppetfile 
mod 'puppetlabs/ntp', '4.1.0'
mod 'puppetlabs/stdlib'

# -p to read Puppetfile
r10k deploy environment -p development

[root@puppetmaster development]# r10k deploy environment -p development
[root@puppetmaster development]# ls
environment.conf  manifests  modules  Puppetfile

[root@puppetmaster code]# find .  |grep -v git|grep -v ntp|grep -v stdlib
.
./environments
./environments/development
./environments/development/environment.conf
./environments/development/manifests
./environments/development/manifests/site.pp
./environments/development/Puppetfile
./environments/development/.r10k-deploy.json
./environments/development/modules
./environments/development/site
./environments/development/site/example
./environments/development/site/example/files
./environments/development/site/example/files/example-file
./environments/development/site/example/manifests
./environments/development/site/example/manifests/.goodbye.pp.swp
./environments/development/site/example/manifests/.template.pp.swp
./environments/development/site/example/manifests/file.pp
./environments/development/site/example/manifests/goodbye.pp
./environments/development/site/example/manifests/init.pp
./environments/development/site/example/manifests/template.pp
./environments/development/site/example/templates
./environments/development/site/example/templates/example-template.erb

./environments/master
./environments/master/environment.conf
./environments/master/manifests
./environments/master/manifests/site.pp
./environments/master/.r10k-deploy.json

./environments/production
./environments/production/environment.conf
./environments/production/manifests
./environments/production/manifests/site.pp
./environments/production/.r10k-deploy.json
./environments/production/test_file_4_prod

./environments/ctl_development
./environments/ctl_development/environment.conf
./environments/ctl_development/manifests
./environments/ctl_development/manifests/site.pp
./environments/ctl_development/Puppetfile
./environments/ctl_development/modules
./environments/ctl_development/.r10k-deploy.json

./environments/ctl_master
./environments/ctl_master/environment.conf
./environments/ctl_master/manifests
./environments/ctl_master/manifests/site.pp
./environments/ctl_master/.r10k-deploy.json

./environments/ctl_production
./environments/ctl_production/environment.conf
./environments/ctl_production/manifests
./environments/ctl_production/manifests/site.pp
./environments/ctl_production/.r10k-deploy.json
./environments/ctl_production/test_file_4_prod
./modules


### Puppet DB ###
* To store facts, reports, and exported ressources
