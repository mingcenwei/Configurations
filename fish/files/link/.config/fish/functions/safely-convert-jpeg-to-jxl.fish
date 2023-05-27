#!/usr/bin/env fish

function __sayAnonymousNamespace_safely-convert-jpeg-to-jxl_help
	echo 'Usage:  safely-convert-jpeg-to-jxl [-f] [-x] [-c] [--] <input> <output>'
	echo '        safely-convert-jpeg-to-jxl -r [-f] [-x] [--] <input> <output>'
	echo 'Safely convert a JPEG image to a JPEG XL image'
	echo
	echo 'Options:'
	echo '        -r, --restore              Restore original JPEG from JPEG XL'
	echo '        -f, --force                Overwrite destination <output>'
	echo '        -x, --remove-source-image  Remove source image <input>'
	echo '        -c, --compress-metadata    Compress metadata (Brotli)'
	echo '        -h, --help                 Display this help message'
	echo '        --                         Only <input> and <output> after this'
end

function safely-convert-jpeg-to-jxl --description 'Safely convert a JPEG image to a JPEG XL image'
	check-dependencies --program --quiet='never' 'cjxl' || return 3
	check-dependencies --program --quiet='never' 'djxl' || return 3
	check-dependencies --program --quiet='never' 'file' || return 3
	check-dependencies --program --quiet='never' 'diff' || return 3

	# Parse options
	set --local optionSpecs \
		--name 'safely-convert-jpeg-to-jxl' \
		(printf '--exclusive\nh,%s\n' 'r' 'f' 'x' 'c') \
		--exclusive 'r,c' \
		(fish_opt --short 'r' --long 'restore') \
		(fish_opt --short 'f' --long 'force') \
		(fish_opt --short 'x' --long 'remove-source-image') \
		(fish_opt --short 'c' --long 'compress-metadata') \
		(fish_opt --short 'h' --long 'help')
	argparse $optionSpecs -- $argv
	or begin
		__sayAnonymousNamespace_safely-convert-jpeg-to-jxl_help
		return 2
	end
	if test -n "$_flag_h"
		__sayAnonymousNamespace_safely-convert-jpeg-to-jxl_help
		return
	end
	if test (count $argv) -ne 2
		echo-err 'Expected 2 args, got '(count $argv)
		__sayAnonymousNamespace_safely-convert-jpeg-to-jxl_help
		return 2
	end

	set --local input (path normalize -- $argv[1])
	set --local output (path normalize -- $argv[2])
	set --local restore "$_flag_r"
	set --local force '--no-clobber'
	if test -n "$_flag_f"
		set force '--force'
	end
	set --local removeSourceImage "$_flag_x"
	set --local compressMetadata '--compress_boxes=0'
	if test -n "$_flag_c"
		set compressMetadata '--compress_boxes=1'
	end

	set --local dir_temp (mktemp -d) || return 1

	if test "$force" != '--force'
		if test -e "$output" || test -L "$output"
			echo-err -- "Output file exists: $output"
			return 1
		end
	end
	if not test -f "$input"
		echo-err -- "Input file not found: $input"
		return 1
	end

	if test -z "$restore"
		if test 'image/jpeg' != (file --brief --mime-type -- "$input")
			echo-err -- "Input file not a JPEG image: $input"
			return 1
		end
		cjxl --quiet --lossless_jpeg=1 $compressMetadata -- "$input" "$dir_temp/output.jxl" || return 1
		djxl --quiet -- "$dir_temp/output.jxl" "$dir_temp/original.jpg" || return 1
		if diff --brief -- "$input" "$dir_temp/original.jpg" >'/dev/null'
			mv $force -- "$dir_temp/output.jxl" "$output" || return 1
		else
			echo-err -- 'Cannot restore original JPEG image from generated JPEG XL image'
			rm -r -- "$dir_temp"
			return 1
		end
	else
		if test 'image/jxl' != (file --brief --mime-type -- "$input")
			echo-err -- "Input file not a JPEG XL image: $input"
			return 1
		end
		djxl --quiet -- "$input" "$dir_temp/output.jpg" || return 1
		mv $force -- "$dir_temp/output.jpg" "$output" || return 1
	end
	rm -r -- "$dir_temp" || return 1
	if test -n "$removeSourceImage"
		rm -- "$input" || return 1
	end
end

if test 0 -ne (count $argv)
	safely-convert-jpeg-to-jxl $argv
end
