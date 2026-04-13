# User Documentation

This document explains how to run, access, and verify the services provided by the Inception stack.


## Provided Services

The Inception stack provides the following services:
- **WordPress Website:** Main CMS on [https://lechan.42.fr](https://lechan.42.fr)

## Starting and Stopping
All operations are managed via the Makefile at the root:
- **To Start:** Run `make` (or `make all`)
- **To Stop:** Run `make down`
- **To Restart:** Run `make re`
- **To Clean:** Run `make fclean`


## Access and Administration
- **Website:** Access via HTTPS. If the browser shows a security warning, it is because of the self-signed certificate (expected in this environment).
- **Admin Panel:** Log into WordPress at [/wp-admin](https://lechan.42.fr/wp-admin).

## Credentials Location
All credentials (database passwords, WordPress admin details, etc.) are stored in the following file:
/srcs/.env
Each variable in this file represents a specific credential or configuration value.
- **To manage or change a credential:**  
  Edit the corresponding variable in `.env` and restart the services:
  ```bash
  make re

## Checking Service Health
- **Status:** Run `make ps` to see if all containers are "running".
- **Troubleshooting:** If a service is down, use `make logs` to check for error messages.
