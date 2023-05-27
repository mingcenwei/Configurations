#!/usr/bin/env fish

complete --command 'safely-convert-jpeg-to-jxl' \
	--condition '__fish_contains_opt -s h help' \
	--no-files
complete --command 'safely-convert-jpeg-to-jxl' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s r restore' \
		'-s c compress-metadata' \
	) \
	--short-option 'r' \
	--long-option 'restore' \
	--description 'Restore original JPEG from JPEG XL'
complete --command 'safely-convert-jpeg-to-jxl' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s f force' \
	) \
	--short-option 'f' \
	--long-option 'force' \
	--description 'Overwrite destination <output>'
complete --command 'safely-convert-jpeg-to-jxl' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s x remove-source-image' \
	) \
	--short-option 'x' \
	--long-option 'remove-source-image' \
	--description 'Remove source image <input>'
complete --command 'safely-convert-jpeg-to-jxl' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s c compress-metadata' \
		'-s r restore' \
	) \
	--short-option 'c' \
	--long-option 'compress-metadata' \
	--description 'Compress metadata (Brotli)'
complete --command 'safely-convert-jpeg-to-jxl' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s r restore' \
		'-s f force' \
		'-s x remove-source-image' \
		'-s c compress-metadata' \
	) \
	--short-option 'h' \
	--long-option 'help' \
	--description 'Display help message'
