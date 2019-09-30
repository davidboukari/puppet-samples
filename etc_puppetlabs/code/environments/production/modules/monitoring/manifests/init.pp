class monitoring( 
  # --------------------------------------------------------------------------
  # Get parameter from common.yaml see monitoring::package
  # --------------------------------------------------------------------------
  $packages 
)
{
  include  monitoring::config
 
  # --------------------------------------------------------------------------
  # Display an attribut from the class monitoring::config 
  # --------------------------------------------------------------------------
  notify{'test':
    message => "ports = $monitoring::config::httpd_ports" 
  }

  # --------------------------------------------------------------------------
  # Display an attribut from hiera list $package
  # --------------------------------------------------------------------------
  notify{'http_message':
    message =>  "httpd version=$packages[httpd][ensure]"
  }

  # --------------------------------------------------------------------------
  # Display an attribut from hiera monitoring::config_values
  # --------------------------------------------------------------------------
  notify{'a message':
    message => hiera("monitoring::config_values.httpd_config_path"),
  }

  # --------------------------------------------------------------------------
  # Create a directory from hiera monitoring::config_values
  # --------------------------------------------------------------------------
  file{ hiera("monitoring::config_values.httpd_config_path"):
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
    recurse => true,
    ensure => directory
  }    
 
  # --------------------------------------------------------------------------
  # Create a file from template epp with a dico as parameter
  # Use hiera monitoring::config_values
  # --------------------------------------------------------------------------
  file{'/etc/httpd/conf/httpd.conf':
    #ensure => "hiera('monitoring::config_values.httpd_config_path')",
    #owner  => 'root',
    #group  => 'root',
    #mode   => '0600',
    content=> epp("${module_name}/httpd.conf.epp",  
      {
      'httpd_ports' => $::monitoring::config::httpd_ports, 
      'httpd_user' => $::monitoring::config::httpd_user, 
      'httpd_group' => $::monitoring::config::httpd_group, 
      'httpd_admin_mail' => $::monitoring::config::httpd_admin_mail, 
      'httpd_log_file' => $::monitoring::config::httpd_log_file, 
      'httpd_log_level' => $::monitoring::config::httpd_log_level, 
      }
    ),
  }

  notify { 'httpd-notify':
    message => hiera("monitoring::packages.httpd.ensure"),
  }
 
  # --------------------------------------------------------------------------
  # Install packages from common.yaml
  # --------------------------------------------------------------------------
  hiera('monitoring::packages').each | $package |{
    notify{ "package to install ${package[0]}-${package[1][ensure] }":} 
   
    package{ "${package[0]}": 
      #ensure => "${package[1][ensure]}.el${monitoring::config::os_version}.${monitoring::config::os_installed}",
      ensure => "${package[1][ensure]}",
      provider => yum
    }  
  }

  # --------------------------------------------------------------------------
  # Install a specific package from yaml file
  # --------------------------------------------------------------------------
  #$version_httpd = hiera('monitoring::packages.httpd.ensure')
  #package { 'httpd':
  #  ensure => "${version_httpd}.el${monitoring::config::os_version}.${monitoring::config::os_installed}",
  #  provider => 'yum',
  #}

  # --------------------------------------------------------------------------
  # Display an attribut from hiera list $package
  # --------------------------------------------------------------------------
  notify{'http_message_2':
    message =>  "httpd version=${packages[httpd][ensure]}"
  }

  # --------------------------------------------------------------------------
  # Use lens to configure a file
  # --------------------------------------------------------------------------

  # --------------------------------------------------------------------------
  # Use nslookup instead of hiera('')
  # --------------------------------------------------------------------------


  # --------------------------------------------------------------------------
  # Use module augeas - lens for a configuration file
  # --------------------------------------------------------------------------



}
