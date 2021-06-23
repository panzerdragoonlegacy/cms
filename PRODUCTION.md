# Production Configuration

Step-by-step instructions for setting up the site on a VPS. Ensure that IPv6 is
enabled (for Let's Encrypt).

## Create Linux User Accounts for Admins

1. Add the user account with a strong password:

   `sudo adduser kyle`

2. Give the user sudo access:

   `sudo adduser kyle sudo`

3. Switch to the new user:

   `sudo su kyle`

4. Create new public and private SSH keys for the user:

   `ssh-keygen -t rsa`

5. Create other files for SSH:

   `touch ~/.ssh/authorized_keys`

   `touch ~/.ssh/known_hosts`

   `touch ~/.ssh/config`

6. (On local machine) Find and copy your SSH public key:

   `cat ~/.ssh/id_rsa.pub`

7. Back on the server, open authorized_keys and paste in your public
   key:

   `vim ~/.ssh/authorized_keys`

8. (If not done already), set the server to only allow key-based authentication.
   Open `sshd_config`:

   `sudo vim /etc/ssh/sshd_config`

8. Add the following line and save the file:

   `PasswordAuthentication no`

9. Restart the SSH service to apply the change:

   `sudo service ssh restart`

10. (On local machine) Test that key based authentication works.

    `ssh kyle@servername`

## Enable the Firewall

1. Check that OpenSSH is in the ufw list:

   `sudo ufw app list`

2. Ensure that we can log in via SSH after the Firewall is enabled:

   `sudo ufw allow OpenSSH`

3. Enable ports 80 and 443 for the web application:

   `sudo ufw allow 80`

   `sudo ufw allow 443`

3. Enable to Firewall

   `sudo ufw enable`

4. Check that SSH connections and port 80 and 443 are allowed:

   `sudo ufw status`

## Setup Docker

1. Update the existing list of packages:

   `sudo apt update`

2. Install some prerequisite packages which let apt use packages over HTTPS:

   `sudo apt install apt-transport-https ca-certificates curl software-properties-common`

3. Add the GPG key for the official Docker repository to the server:

   `curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -`

4. Add the Docker repository to APT sources:

   `sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"`

5. Update the package database with the Docker packages from the newly added repo:

   `sudo apt update`

6. Check that you are about to install from the Docker repo (instead of the default Ubuntu repo):

   `apt-cache policy docker-ce`

7. Install Docker:

   `sudo apt install docker-ce`

8. Check that Docker is running:

   `sudo systemctl status docker`

9. To run the docker command without typing sudo, add your username to the docker group (log out and in again to apply this):

   `sudo usermod -aG docker kyle`

## Setup Docker Compose

1. Install Docker Compose (update the release number to use the latest on GitHub):

   `sudo curl -L https://github.com/docker/compose/releases/download/1.26.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose`

2. Apply executable permissions to the binary:

   `sudo chmod +x /usr/local/bin/docker-compose`

3. Verify the installation:

   `docker-compose --version`

## Install the CMS Docker Image

1. Clone the git repo and change into the cloned directory:

   `cd /var`

   `sudo git clone https://github.com/panzerdragoonlegacy/cms.git`

   `cd cms`

   `pwd` (should show `/var/cms`)

2. Copy .env based on .example.env

   `sudo cp .example.env .env`

3. Edit the .env to include the database and mail details.

   `sudo vim .env`

   ```
   RAILS_ENV=production

   DB_USER=panzerdragoonlegacy
   POSTGRES_PASSWORD=PASSWORDHERE
   DB_NAME=panzerdragoonlegacy
   DB_HOST=database

   SECRET_KEY_BASE=abcd1234

   SMTP_ADDRESS=smtp.mailgun.org
   SMTP_PORT=587
   SMTP_USER_NAME=postmaster@mg.panzerdragoonlegacy.com
   SMTP_PASSWORD=PASSWORDHERE
   ```

4. If there is already an SSL certificate for this domain, copy an existing
   `certbot` directory into `/var/cms`. Otherwise, temporarily change
   `/var/cms/nginx/default.conf` to contain the following contents the first
   time that the app is built (see next step) to generate new certificate files:

   ```
   server {
     listen [::]:80;
     listen 80;

     server_name panzerdragoonlegacy.com www.panzerdragoonlegacy.com;

     location ~ /.well-known/acme-challenge {
       allow all;
       root /var/www/certbot;
     }
   }
   ```

5. Build and start the docker containers, which will also run certbot:

   `sudo docker-compose -f docker-compose.prod.yml up --build`

   If generating the SSL certificate, you should see a congratulations message and
   `certbot exited with code 0`. If certbot exits with a non-zero code, there's
   an error.

6. Check that the SSL certificate files were generated successfully. These will
   exist in a subdirectory for the domain.

   `sudo ls -la /var/cms/certbot/conf/live/panzerdragoonlegacy.com`

7. If you changed the `default.conf` in step 4, change it back to what it was
   and restart the app.

   `sudo docker-compose -f docker-compose.prod.yml down`

   `sudo docker-compose -f docker-compose.prod.yml up -d`

8. Ensure that there are no errors in the output. If you go to
   https://www.panzerdragoonlegacy.com in your web browser you should see the
   custom 404 error page. Once the database and Paperclip attachments are
   restored into the volumes that were created by Docker Compose you can verify
   that the app is fully working (see next steps).

## Copying the Site's Data From Another Server

1. On the old server, log in as the web app user:

   `sudo su thewilloftheancients`

2. Get the password for the database from `database.yml`:

   `cat ~/thewilloftheancients/shared/config/database.yml`

3. Create a dump of the database as a tar file, pasting in the password from
   `database.yml` when prompted:

   `pg_dump thewilloftheancients > backup.sql`

4. On the new server, get your public key:

   `cat ~/.ssh/id_rsa.pub`

5. Back on the old server, paste the new web app user's public key into the
   `authorized_keys` file of the old web app user:

   `vim ~/.ssh/authorized_keys`

6. On the new server, copy the database dump from the old server to the home
   directory of the webapp user on the new server:

   `scp thewilloftheancients@1.2.3.4:backup.sql ~`

7. On the new server, copy the data files in the `system` directory from the
   old server. These must be copied at the same time as the database so that
   the record IDs remain in sync:

   `rsync -av thewilloftheancients@1.2.3.4:~/thewilloftheancients/shared/public/system ~/`

## Restore a Database Backup into Docker Volume

1. Stop the app and start the database container only.

   `sudo docker-compose -f docker-compose.prod.yml stop`

   `sudo docker-compose -f docker-compose.prod.yml start database`

1. Open psql in an interactive terminal.

   `sudo docker exec -it database psql -U postgres`

2. Create a user for the webapp that matches what is in the backup:

   `CREATE USER panzerdragoonlegacy WITH ENCRYPTED PASSWORD 'PASSWORDHERE';`

3. Create a database (drop old database first if required):

   `DROP DATABASE panzerdragoonlegacy;` (if required)

   `CREATE DATABASE panzerdragoonlegacy;`

4. Give the user you created full access to the database:

   `GRANT ALL PRIVILEGES ON DATABASE panzerdragoonlegacy TO panzerdragoonlegacy;`

5. Set the owner of the database to the user:

   `ALTER DATABASE panzerdragoonlegacy OWNER TO panzerdragoonlegacy;`

6. Quit postgres:

   `\q`

7. Restore the database from a backup.sql file:

   `cat ~/backup.sql | sudo docker exec -i database psql -U panzerdragoonlegacy`

8. Restart the containers

   `sudo docker-compose -f docker-compose.prod.yml down`

   `sudo docker-compose -f docker-compose.prod.yml up -d`

9. Run any outstanding migrations on the restored database

   `sudo docker-compose -f docker-compose.prod.yml exec app bin/rails db:migrate`

## Restore Paperclip Attachments into Docker Volume

1. Copy the system folder from outside of the container into the volume:

   `sudo docker cp ~/system app:/cms/public`

2. Inside the container, check that the system directory contains the files

   `sudo docker-compose -f docker-compose.prod.yml exec app bash`

   `cd /cms/public/system`

   `ls -la`

   `exit`

3. Restart the app

   `sudo docker-compose -f docker-compose.prod.yml down`

   `sudo docker-compose -f docker-compose.prod.yml up -d`

## Add a Cron Job to call the SSL Certificate Renewal Script

1. Open the crontab

   `sudo crontab -e`

2. Add the following line to call the script every 5 minutes:

   `*/5 * * * * /var/cms/ssl_renew.sh >> /var/log/cron.log 2>&1`

3. After 5 minutes, check the cron log to see if it succeeded.

   `tail -f /var/log/cron.log`

4. Change the cron job to run every day at noon:

   `sudo crontab -e`

   `0 12 * * * /var/cms/ssl_renew.sh >> /var/log/cron.log 2>&1`

## Create a Backup to Your Local Machine

1. On the server, back up the database to your home directory:

   `sudo docker exec -t database pg_dumpall -c -U postgres > ~/backup.sql`

2. Back up the Paperclip attachments to your home directory:

   `sudo docker cp app:/cms/public/system ~/system`

3. On your local machine, make a folder for the various parts of the backup:

   `mkdir ~/backups/cms-backup`

4. Clone the current version of the code repository into the local backup
   directory. This ensures that data can be restored to the same point in time
   as the code, if required:

   `cd ~/backups/cms-backup`

   `git@github.com:panzerdragoonlegacy/cms.git`

5. Download the database backup from the server:

   `scp kyle@servername:~/backup.sql ~/backups/cms-backup`

6. Download the Paperclip attachments from the server. This will take a while,
   so if there is enough free space on the server you may want to create a
   tarball of the folder first:

   `scp -r kyle@servername:~/system ~/backups/cms-backup/system`

7. Create a tarball of the folder containing the three parts of the backup:

   `cd ~/backups`

   `tar cvzf ~/backups/cms-backup.tar.gz cms-backup`

8. Rename the tarball to the date of the backup and archive it:

   `mv cms-backup.tar.gz cms-backup-2021-06-23.tar.gz`

9. On the server, delete the backup files:

   `sudo rm ~/backup.sql`

   `sudo rm -rf ~/system`
