# Quickstart Guide: Docker Compose and WordPress

## Docker Compose - Wordpress Example

Mainly got the steps for download from Dockerdocs, this is a summed up/ personial notes part.
1. **Setting Up apt repository**

*sudo apt-get update*

*sudo apt-get install ca-certificates curl*

*sudo install -m 0755 -d /etc/apt/keyrings*

*sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc*

*sudo chmod a+r /etc/apt/keyrings/docker.asc*

2. **Installing Docker Packages**
   
*sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin*

Then run this next one to confirm installation with a hello-world image

*sudo docker run hello-world*

We are now done installing Docker! 

Remember to shut off the hello world image(docker-compose down)
# Add the repository to Apt sources:
```
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```
3. **Create Project Directory**

   - Choose an name for your directory.(Remember you need to Probably reference it several Times)
   - This directory will contain your application resources and `docker-compose.yml` file.
  I used this yml below, I put the reasource I used at the end
```
services:
  db:
    # We use a mariadb image which supports both amd64 & arm64 architecture
    image: mariadb:10.6.4-focal
    # If you really want to use MySQL, uncomment the following line
    #image: mysql:8.0.27
    command: '--default-authentication-plugin=mysql_native_password'
    volumes:
      - db_data:/var/lib/mysql
    restart: always
    environment:
      - MYSQL_ROOT_PASSWORD=somewordpress
      - MYSQL_DATABASE=wordpress
      - MYSQL_USER=wordpress
      - MYSQL_PASSWORD=wordpress
    expose:
      - 3306
      - 33060
  wordpress:
    image: wordpress:latest
    volumes:
      - wp_data:/var/www/html
    ports:
      - 80:80
    restart: always
    environment:
      - WORDPRESS_DB_HOST=db
      - WORDPRESS_DB_USER=wordpress
      - WORDPRESS_DB_PASSWORD=wordpress
      - WORDPRESS_DB_NAME=wordpress
volumes:
  db_data:
  wp_data:
  ```

4. **Navigate to the Project Directory**
 Make sure to cd into the directory for startup. Use the command below. (my_wordpress being the name of the directory)
   *cd my_wordpress/*

5. **Create a docker-compose.yml**

Create docker-compose.yml File (yml is a format)

Make a configuration for WordPress and a MySQL.
Use volume mounts (db_data and wordpress_data) for data persistence.

6. **Build the Project**

Run Docker Compose

Execute the following command to start the services in detached mode:

*docker-compose up -d*

This will pull the necessary Docker images and start the WordPress and MySQL containers.
After this it is now just needed to setup wordpress on the port you selected for WordPress.(WordPress should be used on ports 80 or 443)

Remember *docker-compose down* is how to actually shut off container. The container could run in background. This is why it could be useful to run something like a website.

**Resources Used**
1. https://github.com/docker/awesome-compose/blob/master/official-documentation-samples/wordpress/README.md
2. https://docs.docker.com/engine/install/ubuntu/
