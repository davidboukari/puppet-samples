include cron

class info_sys::task{
  notify{'info_sys_task':
    message => 'In info_sys::task',
  }

  cron::job { 'info_sys_task_back_puppetlabs_etc':
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

   cron::job { 'info_sys_task_back_puppetlabs_opt':
    minute      => '20',
    hour        => '17',
    date        => '*',
    month       => '*',
    weekday     => '*',
    user        => 'root',
    command     => 'tar czvf /tmp/puppetlabs-$(date %Y%m%d-%H%M%S).tar.gz /opt/puppetlabs',
    environment => [ 'MAILTO=root', 'PATH="/usr/bin:/bin"', ],
    description => 'Backup puppetlabs',
  }

  file { '/tmp/puppetlabs':
    ensure => 'link',
    target => '/etc/puppetlabs',
  }

  cron::job { 'info_sys_task_back_puppetlabs_opt_1':
    minute      => '20',
    hour        => '17',
    date        => '*',
    month       => '*',
    weekday     => '*',
    user        => 'root',
    command     => "tar czvf /tmp/${fqdn}-puppetlabs-$(date %Y%m%d-%H%M%S).tar.gz /opt/puppetlabs",
    environment => [ 'MAILTO=root', 'PATH="/usr/bin:/bin"', ],
    description => 'Backup puppetlabs',
  }

  file { "/tmp/puppetlabs-${fqdn}":
    ensure => 'link',
    target => '/etc/puppetlabs',
  }

  $list_file_name = [ 'name1', 'name2', 'name3' ]
  $list_file_name.each | String $my_file  | {
    notify{ "${fqdn}-file-${my_file}": }
    file{ "/tmp/${fqdn}-file-${my_file}":
          ensure => 'link',
          target => '/tmp/target',
          purge   => true,
          force   => true,
    }
  }

 cron::job { 'info_sys_task_back_puppetlabs_opt_2':
    minute      => '20',
    hour        => '17',
    date        => '*',
    month       => '*',
    weekday     => '*',
    user        => 'root',
    command     => "tar czvf /tmp/${fqdn}-puppetlabs-$((`date +%W`%2+1)).tar.gz /opt/puppetlabs",
    environment => [ 'MAILTO=root', 'PATH="/usr/bin:/bin"', ],
    description => 'Backup puppetlabs',
  }

}
