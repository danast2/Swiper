#!/bin/bash

readonly PROJECT_FILE="Swiper.xcodeproj"

showHelp() {
  cat << EOF  
  
  *Without params*    Build Project

  -h, -help, --help   Display help

  --full              Install dependencies, close Xcode and generate xcodeproj

  --generate          Run XcodeGen only

EOF
}

# XcodeGen run
runXcodeGen() {
  if [ -d "$PROJECT_FILE" ]; then
    echo "Removing existing $PROJECT_FILE..."
    rm -rf "$PROJECT_FILE"
  else
   echo "$PROJECT_FILE not found. Skipping removal."
  fi

  xcodegen -s project.yml
}

# Install brew (if needed)
installBrew() {
  if which brew >/dev/null; then
    echo "🟢 Brew already installed earlier"
  else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ "$(arch -arm64 uname -m)" == "arm64" ]]; then
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/$(id -un)/.zprofile
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    echo "🟢 Brew installed"
  fi
}

installXcodeGen() {
  brew install xcodegen
}

# Arguments parser
if [[ "$1" == "" ]]; then
    echo "🔴 Bad argument. Use -h to help"

    exit 1;
else
   for i in "$@"; do
    case "$i" in
        -h|-help|--help)
            showHelp
            exit 0
            ;;

        --full)
            kill $(ps aux | grep 'Xcode')
            installBrew
            installXcodeGen
            runXcodeGen
            open "$PROJECT_FILE"
            ;;
        --generate)
            runXcodeGen
            ;;
        *)
            echo "🔴 Bad argument. Use -h to help"

            exit 1
            ;;
    esac
  done
fi
