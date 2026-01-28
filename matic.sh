echo "this won't work so try snap instead"

sudo apt update
sudo apt install -y curl gnupg

curl -fsSL https://packagecloud.io/crystal-lang/crystal/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/crystal.gpg

echo "deb [signed-by=/usr/share/keyrings/crystal.gpg] https://packagecloud.io/crystal-lang/crystal/ubuntu/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/crystal.list

sudo apt update
sudo apt install -y crystal

crystal --version
