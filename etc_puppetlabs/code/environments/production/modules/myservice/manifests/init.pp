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
    message => "ports = $myservice::config::httpd_ports" 
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
      'httpd_ports' => $::myservice::config::httpd_ports, 
      'httpd_user' => $::myservice::config::httpd_user, 
      'httpd_group' => $::myservice::config::httpd_group, 
      'httpd_admin_mail' => $::myservice::config::httpd_admin_mail, 
      'httpd_log_file' => $::myservice::config::httpd_log_file, 
      'httpd_log_level' => $::myservice::config::httpd_log_level, 
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
  -> exec{"${myservice_name}-systemd-reload":
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



}
