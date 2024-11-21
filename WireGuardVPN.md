# How to Set Up a Wireguard VPN on DigitalOcean

## 1. Create a DigitalOcean Account
- Sign up for a account on DigitalOcean
- Would Suggest this [URL](https://www.digitalocean.com).

## 2. Create an Ubuntu Droplet
- Choose **Ubuntu 24.04** as your operating system.
- Select a plan, for this project I chose the **$6/month** plan.
- Choose **Basic** with **Regular Intel CPU** and **Normal SSD** (This Is the bare needed,but can do more).
- Select **Password** for authentication.
- Pick the desired **data center**. I went with California

## 3. Install Docker on the Droplet
- In creating the droplet step you can select the image that already has docker or you can do below.
- Mainly got the steps for download from Dockerdocs, this is a summed up/ personial notes part.

## 3a Setting Up apt repository

```sudo apt-get update```

```sudo apt-get install ca-certificates curl```

```sudo install -m 0755 -d /etc/apt/keyrings```

```sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc```

```sudo chmod a+r /etc/apt/keyrings/docker.asc```

## 3b Installing Docker Packages

```sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin```

Then run this next one to confirm installation with a hello-world image

```sudo docker run hello-world```

We are now done installing Docker!
## 4. Install Wireguard Using Docker Compose
- SSH into you container remember **ssh root@<'address'>**
- When in the container make a wireguard directory and in that directory make a config directory.
- Be in the wireguard directory and make a docker-compose.yml (Don't even think of calling it something else, It needs to be called docker-compose)
- copy and paste this wiregaurd pre-done yml into the yml
  ```
  version: '3.8'
services:
  wireguard:
    container_name: wireguard
    image: linuxserver/wireguard
    environment:
      - PUID=1000
      - PGID=1000
      - MX=America/Mexico_City
      - SERVERURL=1.2.3.4
      - SERVERPORT=51820
      - PEERS=pc1,pc2,phone1
      - PEERDNS=auto
      - INTERNAL_SUBNET=10.0.0.0
    ports:
      - 51820:51820/udp
    volumes:
      - type: bind
        source: ./config/
        target: /config/
      - type: bind
        source: /lib/modules
        target: /lib/modules
    restart: always
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
      ```

- When making that file update the Time Zone, SERVERURL, and PEERS. Also if you want the port.
- When doing the Time Zone use this [link](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones?ref=thematrix.dev), otherwise you can use the one I used that is Mexico City.
- For SERVERURL put in your servers IP address, In DigitalOcean it should be right next to your active droplet.
- PEERS is what devices that might connect. For Example a computer or phone in such a case. I went with a default two PC's and a phone.

## 4a Starting up Wireguard

- cd into the wireguard directory and run ```docker compose up -d``` the d will help you keep using terminal.
## 4b Connecting Phone

- Run the command ``` docker compose logs -f wireguard```
- This should give you a QR code to scan for the WireGuard app. You need the WireGuard app.
- If the QR code doesn't work you can put the info in manually.
- In the app make sure to create a tunnel that has the info from your wireguard config file on the container.
- These are the installation instructions I followed [here](https://thematrix.dev/setup-wireguard-vpn-server-withdocker/)

## 5. Test Your VPN Connection
- Go to IPLeak.net and look at your IP address with the VPN off. (```docker compose down``` While in its directory)
- Now run the container and look up IPLeak.net with your phone connected to the VPN.

### 5b. On a Laptop
- Download the Wireguard app
- Find the config files in `~/wireguard/configs/{username}`.
- Look for the `.conf` file and download or copy it to your laptop.
- Before turning on the VPN, visit [IPLeak.net](https://ipleak.net) in a browser to check your local IP and capture a screenshot.
- Turn on the Wireguard VPN Tunnel.
- This should conclude the guide
