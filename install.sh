#!/bin/bash

# Function to install Homebrew if not installed
install_brew() {
  if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    echo "Homebrew is already installed."
  fi
}

# Function to install dependencies using Homebrew
install_brew_dependencies() {
  echo "Installing Homebrew dependencies..."
  while IFS= read -r package; do
    brew list "$package" &>/dev/null || brew install "$package"
  done < "brew_requirements.txt"
}

# Function to install Python3 and pip if not installed
install_python() {
  if ! command -v python3 &> /dev/null; then
    echo "Python3 not found. Installing..."
    brew install python
  fi
  if ! command -v pip3 &> /dev/null; then
    echo "pip not found. Installing..."
    easy_install pip
  fi
}

# Function to install Python dependencies
install_python_dependencies() {
  echo "Installing Python dependencies..."
  while IFS= read -r package; do
    pip3 show "$package" &>/dev/null || pip3 install "$package"
  done < "pip_requirements.txt"
}


# set up virtual environment for packages not a part of the standard library
python3 -m venv venv
source venv/bin/activate
echo "Environment setup complete. Run 'source venv/bin/activate' to activate."


# Install Homebrew if not present
install_brew

# Install Python if not present
install_python

# Install Homebrew dependencies
install_brew_dependencies



# Install Python dependencies
install_python_dependencies
pip install --upgrade earthengine-api

echo "Installation complete!"
