# == Definition: solr::core
# This definition sets up solr config and data directories for each core
#
# === Parameters
# - The $core to create
#
# === Actions
# - Creates the solr web app directory for the core
# - Copies over the config directory for the file
# - Creates the data directory for the core
#
define solr::core(
  $core = $title,
  $solr_home,
  $user,
) {

  file { "${core}":
    path    => ["${solr_home}/cores", "${solr_home}/cores/${core}"],
    ensure  => directory,
    owner   => $user,
    group   => $user,
    require => File[$solr_home],
  }

  # Exploration of the core tree terminates when a file named core.properties is encountered.
  # @see: https://wiki.apache.org/solr/Core%20Discovery%20(4.4%20and%20beyond).
  file { "${solr_home}/${core}/core.properties":
    ensure  => file,
    content => "name=${core}",
    owner   => $user,
    group   => $user,
    require => File["core-roots"],
  }

}
