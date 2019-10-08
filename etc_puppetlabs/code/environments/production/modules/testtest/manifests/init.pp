# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include testtest
class testtest {
  class{ 'nginx': }
  nginx::resource::server{'mywebserver':
    ensure      => present,
    www_root    => '/var/www/html',
    ssl         => true,
    listen_port => 443,
    ssl_port    => 443,
    ssl_cert    => '/tmp/ssl/server.crt',
    ssl_key     => '/tmp/ssl/server.key',
  }
}
