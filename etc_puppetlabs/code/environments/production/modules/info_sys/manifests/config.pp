class info_sys::config{
  $user = 'davidb'
 
  if $fqdn = 'puppet1'
  {
    notify{'my_host_if':
      message => "my_host=$fqdn",
    }
    my_host = $fqdn
  }
  else
  {
    notify{'my_host_else':
      message => "my_host=unknown",
    }
    my_host = 'unknown'

  }
 


}
