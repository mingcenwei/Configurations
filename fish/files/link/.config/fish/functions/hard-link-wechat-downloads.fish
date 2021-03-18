#!/usr/bin/env fish

function hard-link-wechat-downloads \
--description 'Hard link WeChat downloaded files on Android'
	is-platform android-termux || exit 2
	
	if not set --local rootId (sudo id -u)
	or test 0 -ne "$rootId"
		echo-err 'You are not a sudoer'
		exit 2
	end

	set --local prefix '/data/media/0'
	set --local from "$prefix"'/Android/data/com.tencent.MicroMsg/Download'
	set --local to "$prefix"'/Download/.WeChat.say-local'

	if not test -d "$from"
		echo-err "Not a directory: "(string escape -- "$from")
		exit 2
	end

	sudo rsync --archive --hard-links --sparse \
		--human-readable --human-readable \
		--info='stats1,progress2' \
		--link-dest="$from"/ "$from"/ "$to"/
end
