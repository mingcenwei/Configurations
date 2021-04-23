#!/usr/bin/env fish

complete --command 'sc-show-description' \
	--wraps 'systemctl show'
