class info_sys::grafana{
  Class['info_sys::config']

  notify{'In info_sys::grafana':}
  
  # ------------------------------
  # Use Template erb
  # ------------------------------
  # grafana_log_file
  $grafana_log_file = '/tmp/logs'

  # grafana_plugins_dir
  $grafana_plugins_dir = '/tmp/plugins' 

  #Template ERB (puppet 3)  
  file {"/tmp/grafana-erb.ini":
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
    content=> template("info_sys/grafana.ini.erb"),
  }

  #Template EPP (puppet 4)  
  $grafana_plugins_dir_epp = '/tmp/plugins-epp'
  file {"/tmp/grafana-epp.ini":
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
    content=> epp("info_sys/grafana.ini.epp",  {'grafana_log_file_epp' => '/tmp/log-epp', 'grafana_plugins_dir_epp' => $grafana_plugins_dir_epp   }),
  }


  

}
