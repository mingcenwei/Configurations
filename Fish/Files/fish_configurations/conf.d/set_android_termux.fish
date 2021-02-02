#!/usr/bin/env fish

if is_platform 'android-termux'
	### Link common directories
	function __temporary_20200203_try_link --argument-names from to
		if not test -d "$to"
			test -e "$to"
			or test -L "$to"
			and back_up_files --back-up --timestamp --destination --compressor \
				--suffix --parents --remove-source "$to"

			ln -si "$from" "$to"
		end
	end

	__temporary_20200203_try_link '/sdcard' "$HOME"'/sdcard'
	__temporary_20200203_try_link '/sdcard/Download' "$HOME"'/Download'
	__temporary_20200203_try_link '/sdcard/DCIM' "$HOME"'/DCIM'
	__temporary_20200203_try_link '/sdcard/Pictures' "$HOME"'/Pictures'
	__temporary_20200203_try_link '/sdcard/Telegram' "$HOME"'/Telegram'
	__temporary_20200203_try_link '/sdcard/Android/data/com.tencent.mobileqq/Tencent/QQfile_recv' "$HOME"'/QQ'
	__temporary_20200203_try_link '/sdcard/Android/data/com.tencent.mm/MicroMsg/Download' "$HOME"'/WeChat'

	functions --erase __temporary_20200203_try_link
	###

	### Make common directories
	function __temporary_20200203_try_mkdir --argument-names path
		if not test -d "$path"
			test -e "$path"
			or test -L "$path"
			and back_up_files --back-up --timestamp --destination --compressor \
				--suffix --parents --remove-source "$path"

			mkdir -p "$path"
		end
	end

	__temporary_20200203_try_mkdir "$HOME"'/Workspace'
	__temporary_20200203_try_mkdir "$PREFIX"'/local'

	functions --erase __temporary_20200203_try_mkdir
	###

	# Set "~/bin/termux-file-editor"
	if not test -e "$HOME"'/bin/termux-file-editor'
		mkdir -p "$HOME"'/bin'
		ln -si (command -v vim) "$HOME"'/bin/termux-file-editor'
	end
end
