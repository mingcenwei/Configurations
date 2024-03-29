#!/usr/bin/env fish

if is-platform --quiet 'android-termux'
	### Make common directories
	function __sayAnonymousNamespace_try-mkdir --argument-names path
		if not test -d "$path"
			if test -e "$path"
			or test -L "$path"
				back-up-files --remove-source -- "$path" || return
			end

			mkdir -m 700 -p -- "$path"
		end
	end

	__sayAnonymousNamespace_try-mkdir "$HOME"'/Workspace'
	__sayAnonymousNamespace_try-mkdir "$HOME"'/UnderlyingFileSystem'
	__sayAnonymousNamespace_try-mkdir "$PREFIX"'/local'

	functions --erase __sayAnonymousNamespace_try-mkdir
	###

	### Link common directories
	function __sayAnonymousNamespace_try-link --argument-names from to
		if not test -d "$HOME"/"$to"
			if test -e "$HOME"/"$to"
			or test -L "$HOME"/"$to"
				back-up-files --remove-source -- "$HOME"/"$to" || return
			end

			ln -si --no-target-directory "$from" "$HOME"/"$to"
		end

		set --local pattern '^'(string escape --style=regex '/sdcard')
		if string match --quiet --regex -- "$pattern" "$from"
			set --local prefix "$HOME"'/UnderlyingFileSystem'
			if not test -L "$prefix"/"$to"
				if test -e "$prefix"/"$to"
					back-up-files --remove-source --  "$prefix"/"$to"
				end

				set --local underlying '/data/media/0'
				set --local fromUnderlying \
					(string replace --regex -- "$pattern" "$underlying" "$from")
				ln -si --no-target-directory "$fromUnderlying" "$prefix"/"$to"
			end
		end
	end

	__sayAnonymousNamespace_try-link '/sdcard' 'sdcard'
	__sayAnonymousNamespace_try-link '/sdcard/Download' 'Download'
	__sayAnonymousNamespace_try-link '/sdcard/DCIM' 'DCIM'
	__sayAnonymousNamespace_try-link '/sdcard/Pictures' 'Pictures'
	__sayAnonymousNamespace_try-link '/sdcard/Android/data/com.tencent.mobileqq/Tencent/QQfile_recv' 'QQ'
	__sayAnonymousNamespace_try-link '/sdcard/Android/data/com.tencent.mm/MicroMsg/Download' 'WeChat'

	functions --erase __sayAnonymousNamespace_try-link
	###

	# Set "~/bin/termux-file-editor"
	if not test -f "$HOME"'/bin/termux-file-editor'
		mkdir -m 700 -p "$HOME"'/bin'
		and check-dependencies --program 'vim'
		and ln -si --no-target-directory (command --search vim) \
			"$HOME"'/bin/termux-file-editor'
	end
end
