# Implementation Plan: Add Chutes.ai GLM-4.5-turbo Model to OpenCode

## Overview
This plan outlines the steps to integrate the `zai-org/GLM-4.5-turbo` model from Chutes.ai into the OpenCode configuration. The integration involves updating `opencode.json` with a new provider, securely managing the API key using environment variables, and configuring shell files to load the key without exposing it in version control.

## Objectives
- Add support for the Chutes.ai model in OpenCode
- Ensure API key security (not committed to git)
- Follow best practices for environment variable management
- Validate the configuration works

## Steps

### 1. Update opencode.json Configuration
- Add a new provider entry named "chutes" in the `provider` section
- Set `baseURL` to "https://llm.chutes.ai/v1" (based on the curl example)
- Configure `apiKey` to use the environment variable `${CHUTES_API_TOKEN}`
- Add the model "zai-org/GLM-4.5-turbo" under the provider's models
- Use OpenAI-compatible npm package if needed (similar to other providers)

### 2. Secure API Key Management
- Create a private file `~/.zsh_api_keys` (or similar) to store sensitive environment variables
- Add `export CHUTES_API_TOKEN="cpk_ab14de7da8dd417fb864032adb52d4ce.4352b2752b205ae9acb5e8d75b4b79f0.jXO0SRweEDB7H9xGYXb4zjcnunzpYYPc"` to this file
- Ensure this file is not tracked by git (add to .gitignore if necessary, though it's in home directory)
- Set appropriate file permissions (e.g., 600) for security

### 3. Update Shell Configuration Files
- Modify `~/.zshrc` and `~/.bashrc` to source the private API keys file
- Add the following block to both files:
  ```
  # Source API keys from private file
  if [[ -f "$HOME/.zsh_api_keys" ]]; then
    source "$HOME/.zsh_api_keys"
  fi
  ```
- This ensures the environment variable is available in shell sessions

### 4. Verification
- Restart shell or source the configuration files
- Test that `echo $CHUTES_API_TOKEN` shows the key (without exposing it permanently)
- Attempt to use the model in OpenCode to confirm integration
- Check for any configuration errors in opencode.json

## Security Considerations
- Never commit API keys to version control
- Use environment variables for secrets in configuration files
- Limit file permissions on private key files
- Consider using a password manager or secure key storage for long-term management

## Best Practices Assessment
The suggested approach of sourcing a private file from shell rc files is a good practice for managing API keys locally. It keeps secrets out of git while making them available to applications. Alternatives include:
- Using `direnv` for directory-specific environment variables
- System-wide environment files (e.g., `/etc/environment`)
- Dedicated secret management tools (e.g., HashiCorp Vault, AWS Secrets Manager)

This approach is suitable for personal development environments but may need adaptation for team or production setups.