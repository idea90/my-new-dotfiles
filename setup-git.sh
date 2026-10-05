#!/bin/bash

# Prompt for user information
read -p "Enter your name for Git: " git_name
read -p "Enter your email for Git: " git_email

# Configure Git user settings
git config --global user.name "$git_name"
git config --global user.email "$git_email"

# Optional: Set up default editor (vim in this case)
git config --global core.editor "vim"

# Set up default branch name to 'main'
git config --global init.defaultBranch main

# Check and display the configuration
echo "Git has been configured with the following settings:"
git config --list

echo "Git setup complete!"
