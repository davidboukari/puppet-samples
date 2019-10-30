class hawksysmoon::config
(
  $install_user,
  $install_root_dir,
)
{
  notify{'mynotice':
    message => "install_user=$install_user, install_root_dir=$install_root_dir",
  }  
  # Initialize bucket
   

  # Install prometheus
  
  -> file{ ['/tmp/download', '/tmp/install' ]:
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
    recurse => true,
    ensure => directory
  } 
  -> archive {'prometheus':
    path		=> '/tmp/download/prometheus-2.13.1.linux-amd64.tar.gz',
    source 		=> 'http://192.168.31.10/prometheus-2.13.1.linux-amd64.tar.gz',
    extract 		=> true,
    extract_path 	=> '/tmp/download',
    creates 		=> '/tmp/download/prometheus-2.13.1.linux-amd64',
    cleanup		=> true,
    user		=> 'root',
    #ensure		=> present,
    #require		=> File['/tmp/download']
  }
#  -> file { '/tmp/download/prometheus':
#    ensure => 'directory',
#    recurse => true,
#    purge   => true,
#    source => "file:///tmp/download/prometheus-2.13.1.linux-amd64",
#    #before => "File[/tmp/download/prometheus-2.13.1.linux-amd64]" ,
#  }
-> file {'/tmp/download/prometheus':  
  ensure => link,
  target => '/tmp/download/prometheus-2.13.1.linux-amd64',
  }
  

#  -> file { ['/tmp/download/prometheus-2.13.1.linux-amd64.tar.gz', '/tmp/download/prometheus-2.13.1.linux-amd64'] :
#    ensure => 'absent',
#    recurse => true,
#    purge   => true,
#  }

if ( $facts['disks']['sdb'] ) {
  $have_external_storage = true
}
else {
  $have_external_storage = false
}

notify { 'external_info':
  message => "have_external_storage=${have_external_storage}"
}


  # Install alertmanager

  # Install blackbox_exporter

  # Install grafana

  # Install nginx

  # Start all services
}
