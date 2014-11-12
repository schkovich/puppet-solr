# == Class: solr::install
# This class installs the required packages
#
# === Actions
# - Installs wget
#
class solr::install {
  package { 'wget':
    ensure  => present,
  }
}
