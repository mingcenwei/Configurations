#!/usr/bin/env fish

### Set macOS path variables
if is_platform 'macos'
    set --path PATH $PATH "$HOME"'/Library/Python/3.7/bin' "$HOME"'/.local/bin'
end
###