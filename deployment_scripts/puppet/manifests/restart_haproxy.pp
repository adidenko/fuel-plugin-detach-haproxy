notice('MODULAR: detach-haproxy/restart_haproxy.pp')

notify {'restarting_haproxy':} ~>
service { 'haproxy':
  ensure     => 'running',
  enable     => true,
  hasstatus  => true,
  hasrestart => true,
}

