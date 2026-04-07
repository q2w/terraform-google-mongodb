# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#!/bin/bash

# Default Antigravity MCP configuration path (can be overridden by second argument)
CONFIG_FILE="${2:-$HOME/.gemini/antigravity/mcp_config.json}"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Antigravity MCP configuration file not found at $CONFIG_FILE. It will be created."
  mkdir -p "$(dirname "$CONFIG_FILE")"
  echo '{"mcpServers": {}}' > "$CONFIG_FILE"
fi

DEFAULT_INPUT_JSON="$(dirname "$0")/default_mcp_config.json"

if [ "$#" -eq 0 ]; then
  echo "No input JSON file provided. Using default: $DEFAULT_INPUT_JSON"
  INPUT_JSON="$DEFAULT_INPUT_JSON"
else
  INPUT_JSON="$1"
fi

if [ ! -f "$INPUT_JSON" ]; then
  echo "Error: Input JSON file '$INPUT_JSON' not found."
  echo "Usage: $0 [path_to_input_json] [path_to_mcp_config_json]"
  exit 1
fi

echo "Merging '$INPUT_JSON' into Antigravity MCP configuration at $CONFIG_FILE..."

# Use python3 built-in json module to merge without needing jq
python3 -c "
import sys, json

config_path = sys.argv[1]
input_path = sys.argv[2]

try:
    with open(config_path, 'r') as f:
        config_data = json.load(f)
except Exception:
    config_data = {'mcpServers': {}}

try:
    with open(input_path, 'r') as f:
        input_data = json.load(f)
except Exception as e:
    print(f'Error reading input JSON: {e}')
    sys.exit(1)

if 'mcpServers' not in config_data:
    config_data['mcpServers'] = {}

if 'mcpServers' in input_data:
    # Merge keys under mcpServers (this automatically adds/updates servers)
    for server_name, server_config in input_data['mcpServers'].items():
        config_data['mcpServers'][server_name] = server_config

with open(config_path, 'w') as f:
    json.dump(config_data, f, indent=2)
" "$CONFIG_FILE" "$INPUT_JSON"

if [ $? -eq 0 ]; then
  echo "Successfully updated the MCP configuration."
else
  echo "Failed to update the MCP configuration. Please ensure the input JSON is valid."
  exit 1
fi
