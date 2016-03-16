notice('MODULAR: detach-haproxy/haproxy.pp')

$management_vip     = hiera('management_vip')
$database_vip       = hiera('database_vip', '')
$service_endpoint   = hiera('service_endpoint', '')
$primary_controller = hiera('primary_controller')
$haproxy_hash       = hiera_hash('haproxy', {})
$external_lb        = hiera('external_lb', false)

if !$external_lb {
  $haproxy_maxconn              = '16000'
  $haproxy_bufsize              = '32768'
  $spread_checks                = '3'
  $haproxy_maxrewrite           = '1024'
  $haproxy_ssl_default_dh_param = '2048'
  $stats_ipaddresses            = delete_undef_values([$management_vip, $database_vip, $service_endpoint, '127.0.0.1'])

  include ::concat::setup
  include ::haproxy::params
  include ::rsyslog::params

  package { 'haproxy':
    name => $::haproxy::params::package_name,
  }

  $global_options   = {
    'log'                       => '/dev/log local0',
    'pidfile'                   => '/var/run/haproxy.pid',
    'maxconn'                   => $haproxy_maxconn,
    'user'                      => 'haproxy',
    'group'                     => 'haproxy',
    'daemon'                    => '',
    'stats'                     => 'socket /var/lib/haproxy/stats',
    'spread-checks'             => $spread_checks,
    'tune.bufsize'              => $haproxy_bufsize,
    'tune.maxrewrite'           => $haproxy_maxrewrite,
    'tune.ssl.default-dh-param' => $haproxy_ssl_default_dh_param,
  }

  $defaults_options = {
    'log'     => 'global',
    'maxconn' => '8000',
    'mode'   => 'http',
    'retries' => '3',
    'option'  => [
      'redispatch',
      'http-server-close',
      'splice-auto',
      'dontlognull',
    ],
    'timeout' => [
      'http-request 20s',
      'queue 1m',
      'connect 10s',
      'client 1m',
      'server 1m',
      'check 10s',
    ],
  }

  class { 'haproxy::base':
    global_options    => $global_options,
    defaults_options  => $defaults_options,
    stats_ipaddresses => $stats_ipaddresses,
    use_include       => true,
  }

  sysctl::value { 'net.ipv4.ip_nonlocal_bind':
    value => '1'
  }

  service { 'haproxy' :
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

  tweaks::ubuntu_service_override { 'haproxy' :
    service_name => 'haproxy',
    package_name => $haproxy::params::package_name,
  }

  class { 'cluster::haproxy::rsyslog':
    log_file => $haproxy_log_file,
  }

  Package['haproxy'] ->
  Class['haproxy::base']

  Class['haproxy::base'] ~>
  Service['haproxy']

  Package['haproxy'] ~>
  Service['haproxy']

  Sysctl::Value['net.ipv4.ip_nonlocal_bind'] ~>
  Service['haproxy']
}
