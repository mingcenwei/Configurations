#!/usr/bin/env fish

function toggle-bluetooth-headset-profile --description 'Switch between A2DP and HSP/HFP profiles for a bluetooth headset (Default: HSP/HFP)'
	check-dependencies --program --quiet='never' 'bluetoothctl' || return 3
	check-dependencies --program --quiet='never' 'pactl' || return 3
	check-dependencies --program --quiet='never' 'jq' || return 3

	set --local devices (bluetoothctl devices 'Connected' | string split --fields 2 -- ' ' | string replace --all -- ':' '_' | string replace --regex -- '^' 'bluez_card.')
	set --local cards (pactl --format='json' -- list cards 2>'/dev/null' | jq --raw-output '.[].name')
	set --local validDevices
	for device in $devices
		if contains -- "$device" $cards
			set --append validDevices "$device"
		end
	end
	if test 0 -eq (count $validDevices)
		echo-err -- 'No valid bluetooth headset found'
		return 1
	else if test 1 -lt (count $validDevices)
		echo-err -- 'Multiple valid bluetooth headsets found: '(printf '`%s`\\n' $validDevices | string join -- ', ')
		return 1
	end
	set --local device "$validDevices"
	set --local profiles (pactl --format='json' -- list cards 2>'/dev/null' | jq --raw-output ".[] | select(.name == \"$device\") | .profiles | keys | .[]")
	set --local profile_a2dp (string match --regex -- '^a2dp_sink$' $profiles)
	set --local profile_hspOrHfp (string match --regex -- '^.+_head_unit$' $profiles)
	if test 0 -eq (count $profile_a2dp)
		echo-err -- 'No A2DP profile found: '(printf '`%s`\\n' $profiles | string join -- ', ')
		return 1
	else if test 1 -lt (count $profile_a2dp)
		echo-err -- 'Multiple A2DP profiles found: '(printf '`%s`\\n' $profiles | string join -- ', ')
		return 1
	end
	if test 0 -eq (count $profile_hspOrHfp)
		echo-err -- 'No HSP/HFP profile found: '(printf '`%s`\\n' $profiles | string join -- ', ')
		return 1
	else if test 1 -lt (count $profile_hspOrHfp)
		echo-err -- 'Multiple HSP/HFP profiles found: '(printf '`%s`\\n' $profiles | string join -- ', ')
		return 1
	end
	set --local profile_active (pactl --format='json' -- list cards 2>'/dev/null' | jq --raw-output ".[] | select(.name == \"$device\") | .active_profile")
	if test "$profile_active" != "$profile_hspOrHfp"
		pactl set-card-profile "$device" "$profile_hspOrHfp"
		echo-err --info -- '🎤 Mode: HSP/HFP'
	else
		pactl set-card-profile "$device" "$profile_a2dp"
		echo-err --info -- '🎧 Mode: A2DP'
	end
end
