# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include hawksysmoon
class hawksysmoon( 

)
{
  contain '::hawksysmoon::prereq'
  contain '::hawksysmoon::install'
  contain '::hawksysmoon::config'

  Class['hawksysmoon::prereq']
  -> Class['hawksysmoon::install']
  -> Class['hawksysmoon::config']

  # Initialize bucket

  # Install prometheus

  # Install alertmanager

  # Install blackbox_exporter

  # Install grafana

  # Install nginx

  # Start all services

}
