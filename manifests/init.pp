# == Class: solr
#
# This module helps you create a multi-core solr install
# from scratch. I'm packaging a version of solr in the files
# directory for convenience. You can replace it with a newer
# version if you like.
#
# IMPORTANT: Works only with Ubuntu as of now. Other platform
# support is most welcome.
#
# === Parameters
#
# [*cores*]
#   "Specify the solr cores you want to create (optional)"
#
# === Examples
#
# Default case, which creates a single core called 'default'
#
#  include solr
#
# If you want multiple cores, you can supply them like so:
#
#  class { 'solr':
#    cores => [ 'development', 'staging', 'production' ]
#  }
#
# You can also manage/create your cores from solr web admin panel.
#
# === Authors
#
# Vamsee Kanakala <vamsee AT riseup D0T net>
#
# === Copyright
#
# Copyright 2012-2013 Vamsee Kanakala, unless otherwise noted.
#

class solr (
  $my_cores       = 'UNSET',
  $my_version     = 'UNSET',
  $my_mirror      = 'UNSET',
  $my_jetty_base  = 'UNSET',
  $my_solr        = 'UNSET',
  $my_user        = 'UNSET',
  $my_tempdata    = 'UNSET',
) {

  include solr::params

  $cores = $my_cores ? {
    'UNSET'   => $::solr::params::cores,
    default   => $my_cores,
  }

  $version = $my_version ? {
    'UNSET'   => $::solr::params::solr_version,
    default   => $my_version,
  }

  $mirror = $my_mirror ? {
    'UNSET'   => $::solr::params::mirror_site,
    default   => $my_mirror,
  }

  $jetty_base = $my_jetty_base ? {
    'UNSET'   => $::solr::params::jetty_base,
    default   => $my_jetty_base,
  }

  $solr = $my_solr ? {
    'UNSET'   => $::solr::params::solr_home,
    default   => $my_solr,
  }

  $user = $my_user ? {
    'UNSET'   => $::solr::params::user,
    default   => $my_user,
  }

  $tempdata = $my_tempdata ? {
    'UNSET'   => '/tmp',
    default   => $my_tempdata,
  }

  class {'solr::install': }
  ->
  class {'solr::config':
    cores       => $cores,
    version     => $version,
    mirror      => $mirror,
    jetty_base  => $jetty_base,
    solr_home   => $solr,
    user        => $user,
    tempdata    => $tempdata,
  }
  ->
  Class['solr']

}
