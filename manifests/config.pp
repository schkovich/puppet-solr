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
  $cores_root     = $solr::params::solr_home,
  $user           = $solr::params::user,
  $tempdata       = 'UNSET',
  ) inherits solr::params {

  $dl_name        = "solr-${version}.tgz"
  $download_url   = "${mirror}/${version}/${dl_name}"

  # download only if WEB-INF is not present and tgz file is not in /tmp:
  exec { 'solr-download':
    path    => [ '/bin', '/sbin' , '/usr/bin', '/usr/sbin', '/usr/local/bin' ],
    command =>  "wget ${download_url}",
    cwd     =>  '/tmp',
    creates =>  "/tmp/${dl_name}",
    onlyif  =>  "test ! -d ${solr_home}/WEB-INF && test ! -f /tmp/${dl_name}",
    timeout =>  0,
  }

  exec { 'extract-solr':
    path    =>  ['/usr/bin', '/usr/sbin', '/bin'],
    command =>  "tar xzvf ${dl_name}",
    cwd     =>  '/tmp',
    onlyif  =>  "test -f /tmp/${dl_name} && test ! -d /tmp/solr-${version}",
  }
  ->
  file {["${jetty_base}", "${jetty_base}/lib", "${jetty_base}/webapps"]:
    ensure    => directory,
    owner     => $user,
    group     => $user,
    require =>  Exec['extract-solr'],
  }
  ->
  file {"${jetty_base}/lib/ext":
    ensure => directory, # so make this a directory
    recurse => true, # enable recursive directory management
    purge => true, # purge all unmanaged junk
    force => true, # also purge subdirs and links etc.
    source  => "/tmp/solr-${version}/example/lib/ext",
    owner     => $user,
    group     => $user,
  }
  ->
  file {"${jetty_base}/webapps/solr.war":
    owner     => $user,
    group     => $user,
    source    => "/tmp/solr-${version}/dist/solr-${version}.war",
  }
  ->
  file {"${jetty_base}/webapps/context.xml":
    owner     => $user,
    group     => $user,
    source    => "/tmp/solr-${version}/example/contexts/solr-jetty-context.xml",
  }
  ->
  augeas{ "context":
    incl => "${jetty_base}/webapps/context.xml",
    context => "/files/${jetty_base}/webapps/context.xml/Configure",
    lens => "Xml.lns",
    changes => [
      'set Set[#attribute/name = "war"]/SystemProperty/#attribute/name "jetty.base"',
      'set Set[#attribute/name = "tempDirectory"]/Property/#attribute/name "jetty.base"',
    ]
  }
  ->
  file {"${solr_home}":
    ensure => directory, # so make this a directory
    recurse => true, # enable recursive directory management
    purge => true, # purge all unmanaged junk
    force => true, # also purge subdirs and links etc.
    owner   => $user,
    group   => $user,
    source  => "/tmp/solr-${version}/example/solr",
  }
  ->
  augeas{ "cores_root":
    incl => "${solr_home}/solr.xml",
    lens => "Xml.lns",
    context => "/files/${solr_home}/solr.xml/solr",
    changes => [
      'set str/#attribute/name coreRootDirectory',
      "set str/#text ${cores_root}",
    ]
  }
  ->
  file {"${solr_home}/contrib":
    ensure => directory, # so make this a directory
    recurse => true, # enable recursive directory management
    purge => true, # purge all unmanaged junk
    force => true, # also purge subdirs and links etc.
    owner     => $user,
    group     => $user,
    source   => "/tmp/solr-${version}/contrib",
  }
  ->
  file {"${solr_home}/dist":
    ensure => directory, # so make this a directory
    recurse => true, # enable recursive directory management
    purge => true, # purge all unmanaged junk
    force => true, # also purge subdirs and links etc.
    owner     => $user,
    group     => $user,
    source   => "/tmp/solr-${version}/dist",
  }
  ->
  file {"${solr_home}/cores":
    ensure    => directory,
    owner     => $user,
    group     => $user,
  }
  ->
  file {"${solr_home}/collection1":
    ensure   => absent,
  }
  ->
  solr::core { $cores:
    solr_home => $solr_home,
    user      => $user,
    tempdata   => $tempdata,
    require   =>  File["${solr_home}/collection1"],
  }
}
