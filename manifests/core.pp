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
  $tempdata,
) {

  file { ["${solr_home}/cores/${core}", "${solr_home}/cores/${core}/conf"]:
    ensure  => directory,
    owner   => $user,
    group   => $user,
  }
  ->
  file { "${solr_home}/cores/${core}/conf/schema.xml":
    ensure  => file,
    source => "${tempdata}/cores/${core}/schema.xml",
    owner   => $user,
    group   => $user,
  }
  ->
  file { "${solr_home}/cores/${core}/conf/solrconfig.xml":
    ensure  => file,
    source => "${tempdata}/cores/${core}/solrconfig.xml",
    owner   => $user,
    group   => $user,
  }
  ->
  file { "${solr_home}/cores/${core}/conf/name_synonyms.txt":
    ensure  => file,
    source => "${tempdata}/cores/${core}/name_synonyms.txt",
    owner   => $user,
    group   => $user,
  }
  ->
  file { "${solr_home}/cores/${core}/conf/protwords.txt":
    ensure  => file,
    source => "${tempdata}/cores/${core}/protwords.txt",
    owner   => $user,
    group   => $user,
  }
  ->
  file { "${solr_home}/cores/${core}/conf/stopwords.txt":
    ensure  => file,
    source => "${tempdata}/cores/${core}/stopwords.txt",
    owner   => $user,
    group   => $user,
  }
  ->
  file { "${solr_home}/cores/${core}/conf/synonyms.txt":
    ensure  => file,
    source => "${tempdata}/cores/${core}/synonyms.txt",
    owner   => $user,
    group   => $user,
  }
  ->
  # Exploration of the core tree terminates when a file named core.properties is encountered.
  # @see: https://wiki.apache.org/solr/Core%20Discovery%20(4.4%20and%20beyond).
  file { "${solr_home}/cores/${core}/core.properties":
    ensure  => file,
    content => "name=${core}",
    owner   => $user,
    group   => $user,
  }

}
