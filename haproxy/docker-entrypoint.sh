#!/bin/bash
sed -e 's/%NGINX_ENDPOINT%/'${NGINX_ENDPOINT}'/g' -e 's/%WORDPRESS_ENDPOINT%/'${WORDPRESS_ENDPOINT}'/g' -e 's/%NODEJS_ENDPOINT%/'${NODEJS_ENDPOINT}'/g' /usr/local/etc/haproxy/haproxy.cfg.template > /usr/local/etc/haproxy/haproxy.cfg

haproxy -f /usr/local/etc/haproxy/haproxy.cfg