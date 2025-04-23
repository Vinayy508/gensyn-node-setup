#!/bin/bash

# Step 1: Prompt the user to enter an email for swarm.pem
read -p "Enter your email address for the node: " EMAIL

# Step 2: Update and Install dependencies
echo "Updating system and installing dependencies..."
sudo apt update && sudo apt install -y python3 python3-venv python3-pip curl wget screen git lsof
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - 
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list 
sudo apt update && sudo apt install -y yarn

# Step 3: Run the Gensyn node setup script
echo "Running Gensyn setup script..."
curl -sSL https://raw.githubusercontent.com/ABHIEBA/Gensyn/main/node.sh | bash

# Step 4: Create a screen session for gensyn
echo "Creating a new screen session for gensyn..."
screen -S gensyn

# Step 5: Clone the gensyn-testnet repo and set up
echo "Cloning gensyn-testnet repository..."
cd $HOME && rm -rf gensyn-testnet
git clone https://github.com/zunxbt/gensyn-testnet.git
cd gensyn-testnet

# Step 6: Create and activate Python virtual environment
echo "Setting up the Python virtual environment..."
python3 -m venv .venv
source .venv/bin/activate

# Step 7: Install necessary dependencies
echo "Installing Python dependencies..."
pip install -r requirements.txt

# Step 8: Generate swarm.pem with the entered email
echo "Generating swarm.pem file for email: $EMAIL"
./generate_swarm.sh --email "$EMAIL" --output swarm.pem

# Check if swarm.pem was successfully generated
if [ ! -f swarm.pem ]; then
    echo "Error: swarm.pem file was not generated!"
    exit 1
fi

# Step 9: Make the gensyn-testnet script executable and run it
chmod +x gensyn.sh
./gensyn.sh

# Step 10: Optional - if you want to run the Cloudflare tunnel for remote access
read -p "Do you want to run Cloudflare tunnel for access (y/n)? " CF_TUNNEL
if [ "$CF_TUNNEL" == "y" ]; then
    echo "Setting up Cloudflare tunnel..."
    cloudflared tunnel --url http://localhost:3000 &
fi

echo "Gensyn node is now running!"
echo "To view the logs, you can reattach to the screen session using: screen -r gensyn"
