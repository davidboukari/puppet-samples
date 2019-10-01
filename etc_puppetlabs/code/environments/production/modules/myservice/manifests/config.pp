class myservice::config{
  if $facts['os']['name'] == 'CentOS'
  {
    $os_installed = 'centos'
  }

  $os_version = $facts['os']['release']['major']



  # Listen <%= ${httpd_ports} %>
  $httpd_ports = '80' 

  # User <%= httpd_user %>
  $httpd_user = 'www-data' 
 
  # Group <%= httpd_group %>
  $httpd_group = 'www-data'
  
  # ServerAdmin <%= httpd_mail_admin %>
  $httpd_admin_mail = 'root@localhost'

  # ErArorLog <%= httpd_log_file %>
  $httpd_log_file = 'logs/error_log'

  # LogLevel <%= httpd_log_level %>
  $httpd_log_level = 'warn'

}
