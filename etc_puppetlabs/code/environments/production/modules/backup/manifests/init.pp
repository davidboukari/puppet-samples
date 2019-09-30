include cron

class backup{
  notify{ 'In init.pp::backup':}

  cron::job { 'backup_puppet':
    minute      => '20',
    hour        => '17',
    date        => '*',
    month       => '*',
    weekday     => '*',
    user        => 'root',
    command     => 'tar czvf /tmp/puppetlabs-$(date %Y%m%d-%H%M%S).tar.gz /etc/puppetlabs',
    environment => [ 'MAILTO=root', 'PATH="/usr/bin:/bin"', ],
    description => 'Backup puppetlabs',
  }


}




