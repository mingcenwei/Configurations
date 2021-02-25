#!/usr/bin/env fish

# ssh-agent is a program to hold private keys used for public key authentication
# https://github.com/danhper/fish-ssh-agent/
# https://wiki.archlinux.org/index.php/SSH_keys#SSH_agents

#if check-dependencies 'ssh-agent'
#	set --local sshAgentInfoDir "$HOME"'/.say-local'
#	set --local sshAgentInfo "$sshAgentInfoDir"'/.ssh-agent-info'

#	test -d "$sshAgentInfoDir"
#	or mkdir -m 700 -p -- "$sshAgentInfoDir"
#	or exit 1

#	if test -f "$sshAgentInfo"
#		source "$sshAgentInfo" > '/dev/null'
#	end

#	# Check whether there is an ssh-agent running. If not, create one
#	if test -z "$SSH_AGENT_PID"
#	or not pgrep -u (id -un) 'ssh-agent' | grep -q '^'"$SSH_AGENT_PID"'$'
#		# Set the maximum lifetime of identities added to the agent to 3600 seconds
#		install -m 600 -- '/dev/null' "$sshAgentInfo"
#		and ssh-agent -c -t 3600 | \
#			sed -e 's/^setenv/set --export/' > "$sshAgentInfo"
#		and source "$sshAgentInfo" > '/dev/null'
#	end
#end

if check-dependencies 'ssh-agent'
	# Check whether there is an ssh-agent running. If not, create one
	if test -z "$SSH_AGENT_PID"
	or not pgrep -u (id -un) 'ssh-agent' | grep -q '^'"$SSH_AGENT_PID"'$'
		# Set the maximum lifetime of identities added to the agent to 3600 seconds
		ssh-agent -c -t 3600 | \
			sed -e 's/^setenv/set --export --universal/' | \
			source > '/dev/null'
	end
end

if check-dependencies 'ssh-add'
	if test -n "$SSH_ASKPASS"
		ssh-add -q < '/dev/null'
	end
end
