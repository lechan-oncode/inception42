# Developer Documentation

This document describes how to set up, build, and maintain the Inception project.

## Environment Setup

1. **Prerequisites:**  
   Ensure `docker`, `docker-compose`, and `make` are installed.

2. **Configuration:**  
   The `srcs/.env` file defines all configuration values, including:
   - Domain name (e.g. `DOMAIN_NAME`)
   - Database credentials
   - WordPress admin credentials

3. **Credentials Management:**  
All credentials are stored directly inside the `.env` file.

- To update credentials:  
  Edit `srcs/.env` and restart the services:
  ```bash
  make re
  ```

> ⚠️ Important:
> - `.env` contains sensitive information  
> - It must NOT be committed to version control  

## Build and Launch
- **Initial Setup & Build:** Running `make` will automatically:
  - Configure the `/etc/hosts` file.
  - Create local data directories in `/home/your_login/data`.
  - Build images and launch containers in detached mode.
- **Rebuild:** Use `make re` to perform a clean rebuild of all images.

## Management Commands
- **Inspection:** Use `make ps` to verify container names and port mappings.
- **Debugging:** Use `make logs` to follow the output of all containers.
- **Cleanup:**
  - `make clean`: Removes containers, images, and the network.
  - `make fclean`: Removes all of the above plus **permanently deletes the data directories** in `/home/your_login/data`.

## Data Persistence & Storage
The project uses Docker volumes with the `local` driver and `bind` options to persist data directly on the host filesystem:
- **MariaDB Data:** Stored at `/home/your_login/data/mariadb`.
- **WordPress Files:** Stored at `/home/your_login/data/wordpress`.

This configuration ensures that data is preserved even if the containers are removed. Data is only lost if `make fclean` is executed or the host directories are manually deleted.

## Infrastructure Details
- **Network:** All containers communicate through a dedicated bridge network named `inception`.
- **Isolation:** MariaDB, WordPress do not expose ports to the host; they are only accessible through the Nginx proxy or internally within the Docker network. Only Nginx (443) has a mapped port to the host.
