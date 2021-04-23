#!/usr/bin/env fish

complete --command 'back-up-files' \
	--condition '__fish_contains_opt -s h help' \
	--exclusive
complete --command 'back-up-files' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s s sudo' \
	) \
	--short-option 's' \
	--long-option 'sudo' \
	--description 'Use `sudo`'
complete --command 'back-up-files' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s x remove-source' \
	) \
	--short-option 'x' \
	--long-option 'remove-source' \
	--description 'Remove original files'
complete --command 'back-up-files' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s d backup-dir' \
	) \
	--short-option 'd' \
	--long-option 'backup-dir' \
	--require-parameter \
	--force-files \
	--description 'Specify backup directory'
complete --command 'back-up-files' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s c comment' \
	) \
	--short-option 'c' \
	--long-option 'comment' \
	--require-parameter \
	--no-files \
	--description 'Add comment to backup name'
complete --command 'back-up-files' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s H hard-links' \
		'-s a preserve-all' \
	) \
	--short-option 'H' \
	--long-option 'hard-links' \
	--description 'Preserve hard links'
complete --command 'back-up-files' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s A acls' \
		'-s a preserve-all' \
	) \
	--short-option 'A' \
	--long-option 'acls' \
	--description 'Preserve ACLs'
complete --command 'back-up-files' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s X xattrs' \
		'-s a preserve-all' \
	) \
	--short-option 'X' \
	--long-option 'xattrs' \
	--description 'Preserve extended attributes'
complete --command 'back-up-files' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s a preserve-all' \
	) \
	--short-option 'a' \
	--long-option 'preserve-all' \
	--description 'Equal to `-HAX`'
complete --command 'back-up-files' \
	--condition (string join -- ' ' 'not __fish_contains_opt' \
		'-s h help' \
		'-s s sudo' \
		'-s x remove-source' \
		'-s d backup-dir' \
		'-s c comment' \
		'-s H hard-links' \
		'-s A acls' \
		'-s X xattrs' \
		'-s a preserve-all' \
	) \
	--short-option 'h' \
	--long-option 'help' \
	--description 'Display help message'
