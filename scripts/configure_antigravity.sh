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

REPO_URL="https://github.com/q2w/terraform-google-mongodb.git"
DEST_DIR="$HOME/.gemini/antigravity/skills"
SKILL_FOLDERS=("design-and-deploy")

echo "🚀 Starting Antigravity Skill installation..."

mkdir -p "$DEST_DIR"

# Clone to a temporary location
TEMP_DIR=$(mktemp -d)
if git clone --depth 1 "$REPO_URL" "$TEMP_DIR" > /dev/null 2>&1; then
  :
else
  echo "❌ Error: Failed to clone repository from $REPO_URL"
  rm -rf "$TEMP_DIR"
  exit 1
fi

# Check and copy each skill folder
for SKILL_FOLDER in "${SKILL_FOLDERS[@]}"; do
  if [ -d "$DEST_DIR/$SKILL_FOLDER" ]; then
    echo "ℹ️ Info: $SKILL_FOLDER already exists in $DEST_DIR. Skipping."
  elif [ -d "$TEMP_DIR/$SKILL_FOLDER" ]; then
    mkdir -p "$DEST_DIR/$SKILL_FOLDER"
    cp -r "$TEMP_DIR/$SKILL_FOLDER/"* "$DEST_DIR/$SKILL_FOLDER/"
  else
    echo "⚠️ Warning: $SKILL_FOLDER not found in the repository. Skipping."
  fi
done

echo "⚙️ Configuring Antigravity MCP Server..."
if [ -x "$TEMP_DIR/scripts/configure_mcp.sh" ]; then
  "$TEMP_DIR/scripts/configure_mcp.sh"
else
  bash "$TEMP_DIR/scripts/configure_mcp.sh"
fi

# Cleanup
rm -rf "$TEMP_DIR"

echo "✅ Success! Your skills and MCP configurations are now installed."
echo "Refresh your Antigravity agent to see new capabilities."