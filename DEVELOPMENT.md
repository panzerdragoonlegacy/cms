# Development Configuration

Step-by-step instructions for setting up a development environment for the site.

## Setting Up the Development Environment

1. Install git (refer to setup instructions on git-scm.com)

2. Install Docker (refer to setup instructions on docker.com). If you are using
   Windows 10 Home you will need to install the Docker Toolbox instead.

3. Clone the git repository and change into it's directory:

   (Windows specific): `git config --global core.autocrlf false`

   `git clone https://github.com/panzerdragoonlegacy/cms.git`

   `cd cms`

4. Create a .env from the example file:

   `cp .example.env .env`

5. Build and start the Docker containers:

   `docker-compose up --build`

6. If they do not already exist, create the development and test databases:

   `docker-compose exec app bin/rails db:create`

7. Load the database schema and run any pending migrations:

   `docker-compose exec app bin/rails db:schema:load`

   `docker-compose exec app bin/rails db:migrate`

8. Enter the Rails console and create an administrator user:

   `docker-compose exec app bin/rails c`

   ```ruby
   User.create(
     email: 'admin@example.com',
     password: 'MyPa$$word',
     administrator: true,
     confirmed_at: Time.now
   )

   exit
   ```

9. Open http://localhost:3000 to log in as the admin user.

   If you are using the Docker Toolbox you will get a connection refused error.
   In this case, you will need to use the IP address of Docker Machine instead.
   Run `docker-machine ls`. If the displayed URL is `tcp://192.168.99.100:2376`
   you would access the site at `http://192.168.99.100:3000` instead.

10. For automatic reloading of webpack-dev-server, open a seperate tab and run:

   `docker-compose exec app bash`

   `WEBPACKER_DEV_SERVER_HOST=0.0.0.0 ./bin/webpack-dev-server`

## Restore a Database Backup into Docker Volume

1. Stop the app and start the database container only.

   `docker-compose stop`

   `docker-compose start database`

1. Open psql in an interactive terminal.

   `docker exec -it cms_database_1 psql -U postgres`

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

   `cat /My/Path/backup.sql | docker exec -i cms_database_1 psql -U panzerdragoonlegacy`

8. Update `.env` with the database user, password, and name you used.

   ```
   DB_USER=panzerdragoonlegacy
   POSTGRES_PASSWORD=PASSWORDHERE
   DB_NAME=panzerdragoonlegacy
   DB_HOST=database
   ```

9. Restart the containers to reload from `.env`

   `docker-compose down`

   `docker-compose up`

10. Run any outstanding migrations on the restored database

    `docker-compose exec app bin/rails db:migrate`

### Restore Paperclip Attachments into Docker Volume

1. Copy the system folder from your local machine into the volume:

   `docker cp /My/Path/system cms_app_1:cms/public`

2. Restart the app

   `docker-compose down`

   `docker-compose up`

## Running the Test Suite

1. If it does not already exist, create the test database:

   `docker-compose exec app bin/rails db:create RAILS_ENV=test`

2. Run this test suite:

   `docker-compose exec app bin/rspec`
