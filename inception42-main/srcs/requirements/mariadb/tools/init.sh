#!/bin/bash
# Run this script with Bash.

# install Base Data (Only if missing)
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Installing base MariaDB data..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
else
    echo "MariaDB data already exists."
fi

# run the bootstrap block every startup to ensure the user 
# In MariaDB, bootstrap mode is a way to run SQL commands directly on the database system tables without starting the full server.
# and the permissions are always correct
echo "Updating MariaDB permissions..."

# flush privileges: reloads user permission data from the grant tables into memory,
# forcing the server to apply changes made directly to those system tables without needing a full server restart
mysqld --user=mysql --bootstrap << EOF
USE mysql;
FLUSH PRIVILEGES;

-- 1. Create the Database (Safe to run multiple times)
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;

-- 2. Create the User (Safe to run multiple times)
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';

-- 3. FORCE the password update (In case you changed .env)
ALTER USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';

-- 4. FORCE the Root password update
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';

-- 5. Grant Privileges (CRITICAL STEP)
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';

FLUSH PRIVILEGES;
EOF

# Start the server
echo "Starting MariaDB..."

# exec - Replace this script with mysqld (becomes main process)
# --bind-address=0.0.0.0 - Allow connections from other containers (WordPress!)
# Runs in foreground (keeps container alive)
exec mysqld --user=mysql --bind-address=0.0.0.0
