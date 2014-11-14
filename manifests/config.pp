# == Class: solr::config
# This class sets up solr install
#
# === Parameters
# - The $cores to create
#
# === Actions
# - Copies a new jetty default file
# - Creates solr home directory
# - Downloads the required solr version, extracts war and copies logging jars
# - Creates solr data directory
# - Creates solr config file with cores specified
# - Links solr home directory to jetty webapps directory
#
class solr::config(
  $cores          = $solr::params::cores,
  $version        = $solr::params::solr_version,
  $mirror         = $solr::params::mirror_site,
  $jetty_base     = $solr::params::jetty_base,
  $solr_home      = $solr::params::solr_home,
  $user           = $solr::params::user,
  ) inherits solr::params {

  $dl_name        = "solr-${version}.tgz"
  $download_url   = "${mirror}/${version}/${dl_name}"

  # download only if WEB-INF is not present and tgz file is not in /tmp:
  exec { 'solr-download':
    path      =>  ['/usr/bin', '/usr/sbin', '/bin'],
    command   =>  "wget ${download_url}",
    cwd       =>  '/tmp',
    creates   =>  "/tmp/${dl_name}",
    onlyif    =>  "test ! -d ${solr_home}/WEB-INF && test ! -f /tmp/${dl_name}",
    timeout   =>  0,
  }

  exec { 'extract-solr':
    path      =>  ['/usr/bin', '/usr/sbin', '/bin'],
    command   =>  "tar xzvf ${dl_name}",
    cwd       =>  '/tmp',
    onlyif    =>  "test -f /tmp/${dl_name} && test ! -d /tmp/solr-${version}",
    require   =>  Exec['solr-download'],
  }

  file {["${jetty_base}", "${jetty_base}/webapps", "${jetty_base}/webapps/lib", "${jetty_base}/webapps/lib/ext"]:
    ensure    => directory,
    owner     => $user,
    group     => $user,
    require   =>  Exec['extract-solr'],
  }
  ->
  file {"${jetty_base}/webapps/solr.war":
    owner     => $user,
    group     => $user,
    source    => "/tmp/solr-${version}/dist/solr-${version}.war",
  }

  file {"${jetty_base}/webapps/solr.xml":
    owner     => $user,
    group     => $user,
    source    => "/tmp/solr-${version}/example/contexts/solr-jetty-context.xml",
    require   =>  File["${jetty_base}/webapps/solr.war"],
  }

  file {["${solr_home}", "${solr_home}/contrib", "${solr_home}/dist", "${solr_home}/cores"]:
    ensure    => directory,
    owner     => $user,
    group     => $user,
    require   =>  File["${jetty_base}/webapps/solr.xml"],
  }
  ->
  file {"${solr_home}/collection1":
    ensure   => absent,
  }
  ->
  solr::core { $cores:
    solr_home => $solr_home,
    user      => $user,
    require   =>  File["${solr_home}/collection1"],
  }
}
