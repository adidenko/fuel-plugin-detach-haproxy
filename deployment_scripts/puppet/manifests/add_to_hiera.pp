notice('MODULAR: detach-haproxy/add_to_hiera.pp')

$plugin_name      = 'detach_haproxy'
$network_metadata = hiera_hash('network_metadata', {})
$haproxy_nodes    = get_nodes_hash_by_roles($network_metadata, ['standalone-haproxy'])

if size($haproxy_nodes) != 1 {
  fail('There should be only one standalone haproxy node')
}

$mgmt = values(get_node_to_ipaddr_map_by_network_role($haproxy_nodes, 'mgmt/vip'))
$mgmt_ip = $mgmt[0]

$public = values(get_node_to_ipaddr_map_by_network_role($haproxy_nodes, 'public/vip'))
$public_ip = $public[0]

if roles_include(['standalone-haproxy']){
  $haproxy = true
} else {
  $haproxy = false
}

file {"/etc/hiera/plugins/${plugin_name}.yaml":
  ensure  => file,
    content => inline_template("# Created by puppet, please do not edit manually
network_metadata:
  vips:
    management:
      ipaddr: <%= @mgmt_ip %>
      <% if @haproxy -%>
      namespace: haproxy
      <% end -%>
    public:
      ipaddr: <%= @public_ip %>
      <% if @haproxy -%>
      namespace: haproxy
      <% end -%>
")
}

