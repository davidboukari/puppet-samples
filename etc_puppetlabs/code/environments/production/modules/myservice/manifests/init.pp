class myservice( 
  # --------------------------------------------------------------------------
  # Get parameter from common.yaml see myservice::package
  # --------------------------------------------------------------------------
  $packages,
  $config_values,
  $default_user,
  $default_group,
  $service_name,
  $service_path,
  $concat1,
  $concat2,
)
{
 
  # --------------------------------------------------------------------------
  # Display an attribut from the class myservice::config 
  # --------------------------------------------------------------------------
  notify{'1 - test':
    message => "ports = ${lookup('myservice::config::httpd_ports')}" 
  }

  # --------------------------------------------------------------------------
  # Display an attribut from hiera list $package
  # --------------------------------------------------------------------------
  notify{'2 - http_message':
    message =>  "httpd version=$packages[httpd][ensure]"
  }

  # --------------------------------------------------------------------------
  # Display an attribut from hiera myservice::config_values
  # --------------------------------------------------------------------------
  notify{'3 - message':
    #message => hiera("myservice::config_values.httpd_config_path"),
    message => $config_values[httpd_config_path],
  }

  # --------------------------------------------------------------------------
  # Create a directory from hiera myservice::config_values
  # --------------------------------------------------------------------------
  #file{ hiera("myservice::config_values.httpd_config_path"):
  file{ $config_values[httpd_config_path]:
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
    recurse => true,
    ensure => directory
  }    
 
  # --------------------------------------------------------------------------
  # Create a file from template epp with a dico as parameter
  # Use hiera myservice::config_values
  # --------------------------------------------------------------------------
  file{'/etc/httpd/conf/httpd.conf':
    #ensure => "$config_values[httpd_config_path]",
    #owner  => 'root',
    #group  => 'root',
    #mode   => '0600',
    content=> epp("${module_name}/httpd.conf.epp",  
      {
      'httpd_ports' => "${lookup('myservice::config::httpd_ports')}", 
      'httpd_user' => "${lookup('myservice::config::httpd_user')}", 
      'httpd_group' => "${lookup('myservice::config::httpd_group')}", 
      'httpd_admin_mail' => "${lookup('myservice::config::httpd_admin_mail')}", 
      'httpd_log_file' => "${lookup('myservice::config::httpd_log_file')}", 
      'httpd_log_level' => "${lookup('myservice::config::httpd_log_level')}", 
      }
    ),
  }

  notify { 'httpd-notify':
    message => "${myservice::packages[httpd][ensure]}",
  }
 
  # --------------------------------------------------------------------------
  # Install packages from common.yaml
  # --------------------------------------------------------------------------
  $packages.each | $package |{
    notify{ "package to install ${package[0]}-${package[1][ensure] }":} 
    package{ "${package[0]}": 
      #ensure => "${package[1][ensure]}.el${myservice::config::os_version}.${myservice::config::os_installed}",
      ensure => "${package[1][ensure]}",
      provider => yum
    }  
  }

  # --------------------------------------------------------------------------
  # Install a specific package from yaml file
  # --------------------------------------------------------------------------
  #$version_httpd = hiera('myservice::packages.httpd.ensure')
  #package { 'httpd':
  #  ensure => "${version_httpd}.el${myservice::config::os_version}.${myservice::config::os_installed}",
  #  provider => 'yum',
  #}

  # --------------------------------------------------------------------------
  # Display an attribut from hiera list $package
  # --------------------------------------------------------------------------
  notify{'http_message_2':
    #message =>  "httpd version=${packages[httpd][ensure]}"
    message =>  "httpd version=${myservice::packages[httpd][ensure]}"
  }


  # --------------------------------------------------------------------------
  # Add a service
  # --------------------------------------------------------------------------
  file{ $service_path:
    owner => 'root',
    group => 'root',
    mode =>  '0755',
    content => epp( "${module_name}/myservice.service.epp", 
                  { 
                     'default_user' => $default_user,
                     'default_group' => $default_group
                  }
    )
    
  }
  -> exec{"${service_name}-systemd-reload":
       command => 'systemctl daemon-reload',
       path  => [ '/usr/bin', '/bin', '/usr/sbin' ],
       refreshonly => true
  } 
 
 -> service{ $service_name:
      ensure => running,  
      enable => true
  }

  # --------------------------------------------------------------------------
  # Use nslookup instead of hiera('')
  # Show a concatened value in yaml which use %{lookup('...')}...
  # --------------------------------------------------------------------------
  notify{'A concatanation':
    message => "concat1=${concat1} concat2=%{nslookup('myservice::concat1')}def=${concat2}"    
  }

  # --------------------------------------------------------------------------
  # Use lens to configure a file
  # --------------------------------------------------------------------------


  # --------------------------------------------------------------------------
  # Use module augeas - lens for a configuration file
  # --------------------------------------------------------------------------
  augeas { "Change PermitRootLogin for sshd":
    context => "/files/etc/ssh/sshd_config",
    onlyif  => "get '/files/etc/ssh/sshd.config' != 'yes'  ",
    changes => ["set '/files/etc/ssh/sshd.config' 'yes' ",],
    #notify  => Service["sshd"],
  }

  # --------------------------------------------------------------------------
  # Install nginx
  # --------------------------------------------------------------------------
  class { nginx:  }
 
  nginx::resource::server{mywebserver:
      ensure   => present,
      www_root => '/var/www/html',
      ssl      => true,
      listen_port => 443,
      ssl_port  => 443,
      ssl_cert => '/tmp/ssl/server.crt',
      ssl_key  => '/tmp/ssl/server.key',
    } 

  

  #nginx::resource::server { "mywebserver":
  #  ensure                => present,
  #  listen_port           => 443,
  #  www_root              => 'root',
  #  #proxy                 => $proxy,
  #  #location_cfg_append   => $location_cfg_append,
  #  index_files           => [ 'index.php' ],
  #  ssl                   => true,
  #  ssl_cert              => '/home/vagrant/git/ssl/server.crt',
  #  ssl_key               => '/path/to/wildcard_mydomain.key',
  #}


  #nginx::resource::server { 'mywebserver':
  #  ensure               => present,
  #  server_name          => ['hawksys.eu'],
  #  listen_port          => 443,
  #  ssl                  => true,
  #  ssl_cert             => '/home/vagrant/git/ssl/server.crt',
  #  ssl_key              => '/home/vagrant/git/ssl/server.key',
  #  ssl_port             => 8140,
  #  #server_cfg_append    => {
  #  #  'passenger_enabled'      => 'on',
  #  #  'passenger_ruby'         => '/usr/bin/ruby',
  #  #  'ssl_crl'                => '/var/lib/puppet/ssl/ca/ca_crl.pem',
  #  #  'ssl_client_certificate' => '/var/lib/puppet/ssl/certs/ca.pem',
  #  #  'ssl_verify_client'      => 'optional',
  #  #  'ssl_verify_depth'       => 1,
  #  #},
  #  #www_root             => '/etc/puppet/rack/public',
  #  #use_default_location => false,
  #  #access_log           => '/var/log/nginx/puppet_access.log',
  #  #error_log            => '/var/log/nginx/puppet_error.log',
  #  #passenger_cgi_param  => {
  #  #  'HTTP_X_CLIENT_DN'     => '$ssl_client_s_dn',
  #  #  'HTTP_X_CLIENT_VERIFY' => '$ssl_client_verify',
  #  #},
  #}

  
 



}
