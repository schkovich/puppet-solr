# == Class: solr::params
# This class sets up some required parameters
#
# === Actions
# - Specifies jetty and solr home directories
# - Specifies the default core
#
class solr::params {

  $jetty_base    = '/usr/share/solr_base'
  $solr_home     = '/usr/share/solr'
  $solr_version  = '4.7.2'
  $mirror_site   = 'http://www.us.apache.org/dist/lucene/solr'
  $user          = 'jetty'
  $cores         = ['default']
}
