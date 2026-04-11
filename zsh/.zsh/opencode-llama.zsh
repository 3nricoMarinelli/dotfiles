#!/bin/zsh

opencode() {
    local PORT=11434
    export OLLAMA_HOST="127.0.0.1:$PORT"

    # Ensure the Ollama server is running on the correct port
    if ! lsof -i :$PORT > /dev/null; then
        echo "📡 Starting Ollama engine on port $PORT..."
        ollama serve > /dev/null 2>&1 &

        # Wait for the server to wake up
        while ! lsof -i :$PORT > /dev/null; do sleep 0.5; done
    fi

    export OLLAMA_LOADED_MODEL=$(ollama ps | tail -n +2 | awk '{print $1}' | head -n 1)

    local no_model="☁️ Cloud Models Only"
    local selection=$( (echo "$no_model"; ollama list | tail -n +2 | awk '{print "💠 " $1}'; echo "✨ Pull a new model...") | fzf --height 40% --reverse --border --header "Select an Ollama Model")

    if [[ ! ( -z "$selection" || "$selection" == "$no_model" ) && "$selection" != "$OLLAMA_LOADED_MODEL" ]]; then

        if [[ "$selection" == "✨ Pull a new model..." ]]; then
            echo -n "🔍 Enter model name to pull (e.g., gemma4:e4b): "
            read model_to_pull

            if [[ -n "$model_to_pull" ]]; then
                echo "📥 Pulling $model_to_pull... this may take a minute."
                ollama pull "$model_to_pull"
                selection=$model_to_pull
            else
                echo "❌ No model name entered."
                return 1
            fi
        fi

        # This pushes the model into the M1 Pro GPU memory immediately
        echo "🚀 Loading $selection into Unified Memory..."
        curl -s -X POST http://localhost:$PORT/api/generate -d "{
            \"model\": \"$selection\",
            \"options\": {
                \"num_gpu\": -1,
                \"num_thread\": 8
            },
        \"keep_alive\": \"15m\"
        }" > /dev/null 2>&1 &
        export OLLAMA_LOADED_MODEL="$selection"
    fi
    command opencode -c "$@"
}
