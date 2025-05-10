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
	sleep 0.5
	
	SUGGESTION=$(curl -s -X POST -d "{\"input\": \"${1}\"}" -H "Content-Type: application/json" "${ADDR}/")
	
	typeset -g suggestion="${SUGGESTION}"	
}
