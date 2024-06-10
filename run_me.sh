#!/bin/bash

# Set the filename for the key and its public counterpart
KEY_PATH="$HOME/.ssh/id_rsa"
PUBLIC_KEY_PATH="$HOME/.ssh/id_rsa.pub"


build_r() {
    cd hireme-infra
    ./bin/start-infra.sh
}


clone_repo() {
    local repo_name=$1
    local repo_url=$2
    if [ -d "$repo_name" ]; then
        echo -e "\033[0;33m$repo_name directory already exists. Skipping clone.\033[0m"
    else
        echo -e "\033[0;33mCloning repository from $repo_name\033[0m"
        git clone -b develop "$repo_url"
        echo -e "\033[0;32mRepository $repo_name cloned successfully.\033[0m"
    fi
    echo ' '
}

# Ask the user if they have already added their SSH key to GitHub, default is 'yes'
echo -e "\033[0;32mHave you already added your SSH key to your GitHub account?\033[0m (yes/no) \033[0;33m[yes]\033[0m:"
read user_response
user_response=${user_response:-yes}  # Set default response to 'yes' if no input

if [[ "$user_response" == "yes" ]]; then
    echo -e "\033[0;43mThis operation may take a while.\033[0m"
    # Check if the public key file exists and display it
    if [ -f "$PUBLIC_KEY_PATH" ]; then
        clone_repo "hireme-infra" "git@github.com:gentis/hireme-infra.git"
        echo "Enter to hireme-infra directory..."
        cd hireme-infra        
        clone_repo "hireme-core" "git@github.com:gentis/hireme-core.git"
        clone_repo "hireme-front" "git@github.com:gentis/hireme-front.git"
        clone_repo "hireme-console" "git@github.com:gentis/hireme-console.git"
        echo ' '
        # Check if directories exist
        if [ -d "hireme-infra" ] && [ -d "hireme-core" ] && [ -d "hireme-front" ]; then
            echo -e "\033[0;32mAll repositories cloned successfully and directories exist.\033[0m"
            echo ' '
            docker login
            build_r
        else
            echo -e "\033[0;31mOne or more directories do not exist. Cloning might have failed.\033[0m"
        fi
        echo ' '
    else
        echo -e "\033[0;41mPublic SSH key file not found. Please check your SSH key path.\033[0m"
    fi
    exit 0  # Exit the script early
    elif [[ "$user_response" == "no" ]]; then
    # Prompt the user to enter their email for the SSH key
    echo -e "\033[0;32mPlease enter your email for the SSH key:\033[0m"
    read user_email
    
    # Check if the key already exists and create it if it does not
    if [ ! -f "$KEY_PATH" ]; then
        echo "Generating SSH key..."
        ssh-keygen -t rsa -b 4096 -f "$KEY_PATH" -N "" -C "$user_email"
        echo -e "\033[0;32mSSH key generated successfully. Please remember to add this SSH key to your GitHub account.\033[0m"
        echo -e "\033[0;42m************************Your public SSH key:************************\033[0m"
        cat "$PUBLIC_KEY_PATH"
        echo "********************************************************************"
        echo -e "\033[0;33mPlease copy the above SSH key and add it to your GitHub account, then run this script again.\033[0m"
    else
        echo -e "\033[0;91mSSH key already exists at $KEY_PATH\033[0m"
        echo -e "\033[0;33mIf it's not already added, please add this SSH key to your GitHub account, then run this script again.\033[0m"
        echo -e "\033[0;42m************************Your public SSH key:************************\033[0m"
        cat "$PUBLIC_KEY_PATH"
    fi
else
    echo -e "\033[0;31mInvalid input. Please answer 'yes' or 'no'.\033[0m"
    exit 1  # Exit the script with an error
fi


