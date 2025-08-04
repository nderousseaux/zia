ADDR="http://localhost:8000"

# Step 1, find the zsh-autosuggestions plugin (oh-my-zsh or standalone)
ZSH_AUTOSUGGEST_HOME="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [ ! -d "$ZSH_AUTOSUGGEST_HOME" ]; then
	ZSH_AUTOSUGGEST_HOME="$HOME/.zsh/zsh-autosuggestions"
fi

# Step 2, load the zsh-autosuggestions plugin
source "${ZSH_AUTOSUGGEST_HOME}/zsh-autosuggestions.zsh"

# Step 3, override the _zsh_autosuggest_fetch_suggestion function
_zsh_autosuggest_fetch_suggestion() {
	sleep 0.5 # wait for user to stop typing

	# Get the last 10 commands from history
	local history_commands=""
	local cmd_count=0
	
	# Function to escape JSON strings
	escape_json() {
		echo "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/	/\\t/g; s/$/\\n/g' | tr -d '\n' | sed 's/\\n$//'
	}
	
	# Read current terminal history in reverse order and get last 10 commands
	# Use history command to get current session history
	while IFS= read -r line && [ $cmd_count -lt 10 ]; do
		if [ -n "$line" ]; then
			# Remove the history number prefix (e.g., "  123  command" -> "command")
			clean_line=$(echo "$line" | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//')
			if [ -n "$clean_line" ]; then
				escaped_line=$(escape_json "$clean_line")
				if [ $cmd_count -eq 0 ]; then
					history_commands="\"$escaped_line\""
				else
					history_commands="\"$escaped_line\", $history_commands"
				fi
				cmd_count=$((cmd_count + 1))
			fi
		fi
	done < <(history | tail -10 | tac)

	# Build data for request with history
	data="{
		\"prefix\": \"$(escape_json "${1}")\",
		\"history\": [$history_commands]
	}"

	# Send request to server
	RESPONSE=$(
		curl -s -X POST -d "${data}" \
		 -H "Content-Type: application/json" "${ADDR}/"
	)
	
	# Extract command from JSON response
	SUGGESTION=$(echo "${RESPONSE}" | jq -r '.completion')
	
	typeset -g suggestion="${SUGGESTION}"	
}
