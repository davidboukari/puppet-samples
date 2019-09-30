node default{
  notify{ 'default':
    message => 'default node',
  }
  #class{ info_sys::task: }
}

node puppet,puppetmastert{
  notify{'In a node':   
    message => "Node=$fqdn"
  }
  class{ info_sys::task: }
  class{ info_sys::grafana: }

}
