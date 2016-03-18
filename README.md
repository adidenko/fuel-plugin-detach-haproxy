fuel-plugin-detach-haproxy
==========================

## Purpose
The main purpose of this plugin is to provide ability to deploy Load Balancer
(Haproxy) separately from controllers and allow to test
[External Load Balancer](https://github.com/openstack/fuel-plugin-external-lb)
plugin in a fully automated manner.

## Compatibility

| Plugin version | Fuel version |
| -------------- | ------------ |
| 1.x.x          | Fuel-8.x     |
| 2.x.x          | Fuel-9.x     |

## How to build plugin

* Install fuel plugin builder (fpb)
* Clone plugin repo and run fpb there:
```
git clone https://github.com/openstack/fuel-plugin-detach-haproxy
cd fuel-plugin-detach-haproxy
fpb --build .
```
* Check if file `detach_haproxy-*.noarch.rpm` was created.

## Known limitations
* OSTF is not working
* Only one Haproxy node per env is allowed

## Configuration

No need to configure plugin. Just assign `Haproxy` roles to needed nodes.
If you're using it along with [External Load Balancer](https://github.com/openstack/fuel-plugin-external-lb)
pluing for testing purposes, you aslo don't need to configure External Load
Balancer plugin, it will be configured to use Haproxy node automaticaly.
