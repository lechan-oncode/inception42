*This project has been created as part of the 42 curriculum.*

# 42-inception

## Description

This project is a comprehensive deployment of a **microservices architecture using Docker**, designed to simulate a small-scale production environment. It focuses on practical aspects of **containerization, service orchestration, networking, security, and data persistence**.

The goal is to provide a hands-on learning experience by building and managing a complete infrastructure composed of multiple interconnected services, such as a CMS, database, caching system, web server, monitoring tools, and administrative interfaces — all running inside isolated Docker containers.

This project emphasizes:
- Infrastructure-as-code principles
- Service isolation and communication
- Secure handling of credentials
- Persistent data management
- Clean and reproducible deployments using Docker Compose

### What is Docker?
Docker is a platform that enables developers and system administrators to build, package, and run applications inside containers.
It provides a consistent environment for applications across different systems, eliminating compatibility issues and ensuring portability from development to production.

The main benefits of Docker are:
* Consistency: avoids the “works on my machine” problem
* Isolation: applications run in their own isolated environments, preventing interference between them
* Portability: containers can run uniformly anywhere Docker is installed (Linux, Windows, cloud, on-premise)
* Efficiency: they are significantly faster and more lightweight than traditional virtual machines as they share the host system’s operating system kernel

#### Containers

A container is a lightweight and isolated environment that bundles an application together with all the dependencies it needs (libraries, runtime, configuration).
* Unlike Virtual Machines (VMs), containers do not require a full guest operating system
* They share the host operating system’s kernel, while keeping their processes isolated
* This makes them much faster, smaller, and more resource-efficient than VMs
* They are ideal for microservices architectures, where each service runs independently in its own container

The key difference is that VMs virtualize hardware (each with its own OS), while Docker containers virtualize the operating system, making them lightweight and portable.

#### Docker Compose

Docker Compose is a powerful tool that simplifies the process of defining and managing multi-container applications. With a single command, it is possible to easily configure an entire application stack, including services, volumes and networks, and launch it at once.
* Services: each service corresponds to a container, specifying its image, ports, volumes, and dependencies
* Volumes: provide persistent storage for services, ensuring that critical data is not lost when containers are stopped or recreated
* Networks: define isolated networks, enabling containers to communicate with each other securely and efficiently

### Technical comparison

#### Virtual Machines vs Docker
- **Virtual Machines (VMs)** virtualize the hardware level. Each VM includes a full copy of an operating system, the application, and necessary binaries, making them heavy and slow to boot.
- **Docker** virtualizes at the OS level (the kernel). Containers share the host's kernel, making them lightweight, extremely fast to start, and highly efficient in resource usage.

#### Secrets vs Environment Variables

- **Secrets** are encrypted at rest and mounted as temporary files (typically in `/run/secrets`). They provide a higher level of security and are recommended for production environments. However, their support in standard Docker Compose (non-Swarm mode) is limited.
- **Environment variables** are stored in plain text and can be accessed via tools like `docker inspect`. While less secure, they are simple to use and commonly used in development setups.
> In this project, environment variables are used via a `.env` file for simplicity and compatibility with Docker Compose. In a production environment, Docker secrets would be preferred.

#### Docker Network vs Host Network
- **Docker Network** (Bridge mode) creates an isolated virtual network for containers, requiring explicit port mapping.
- **Host Network** removes the isolation between the container and the host. The container shares the host’s IP and port space directly, which offers higher performance but reduces security and can cause port conflicts.

#### Docker Volumes vs Bind Mounts
- **Volumes** are managed by Docker and stored in a specific area of the host filesystem. They are the preferred way to persist data as they are independent of the host's directory structure.
- **Bind Mounts** link a specific host path to the container, making it dependent on the host's folder structure.

## Project Architecture Overview

All services in this project are built from scratch using custom Dockerfiles. Instead of relying on pre-built service images, each service is based on Debian and configured manually to ensure full control over dependencies and configuration.

### Nginx (Web Server)
Nginx serves as the entry point for all incoming HTTP requests. It acts as a web server for static content and, more importantly, as a reverse proxy that forwards requests to backend services (WordPress, Adminer).
* Load Balancing: distributes incoming traffic across multiple backend instances (in this project, typically one instance per service)
* SSL/TLS Termination: handles HTTPS encryption and decryption, ensuring secure communication between clients and the server
* Static Content Delivery: serves static files directly, reducing latency and improving performance
* Request Routing: routes requests to the correct upstream service based on the URL

Configuration:
* Listens on port 443 (HTTPS) - the sole entry point into the network
* Enforces secure connections by using SSL/TLS certificate

### WordPress (Blog Platform)
WordPress provides a full-featured Content Management System (CMS) for building and managing websites or blogs.
* Dynamic Content Generation: dynamically renders web pages using PHP, with content and settings stored in the MariaDB database
* User Interface: offers both an administrative dashboard (backend) and a public-facing website interface (frontend)
* Customization: allows developers to create custom themes, plugins, and integrations, making it flexible for everything
* PHP-FPM Integration: runs with PHP-FPM (FastCGI Process Manager) to efficiently process PHP code. Nginx handles incoming HTTP requests and forwards PHP-related requests to PHP-FPM, which executes the scripts

### MariaDB (Database Server)
MariaDB is a reliable, open-source relational database management system (RDBMS), created as a fork of MySQL, used here to store and manage all WordPress data.
* Data Storage: securely stores all WordPress content, user accounts, posts, comments, and configuration settings
* Data Persistence: leverages Docker volumes to ensure data is preserved even if containers are stopped or removed
* Accessibility: configured to be accessible only by authorized services within the Docker network, preventing external access


### Prerequisites
- Docker and Docker Compose
- Make
- Sudo privileges (required for automatic `/etc/hosts` configuration and volume directory creation)

### Setup

1. **Configure environment variables:**

Before launching the project, create and fill in the `.env` file located at: 
./srcs/.env

Each variable stores a specific credential or configuration value. For example:
MYSQL_ROOT_PASSWORD=
MYSQL_DATABASE=
MYSQL_USER=
MYSQL_PASSWORD=
WP_ADMIN_USER=
WP_ADMIN_PASSWORD=
WP_ADMIN_EMAIL=

> ⚠️ Important: The `.env` file should be added to `.gitignore` to prevent sensitive data from being committed to version control.

2. **Build and start the project:** Run the following command in the root of the repository

   ```bash
   make
   ```

   This command is automated to:
   - Configure the domain `your_login.42.fr` in `/etc/hosts`
   - Create the persistent data directories in `/home/your_login/data`
   - Build the custom images and start all services in detached mode

3. **Access the services:** Once the containers are running, you can access the services via your browser

   * WordPress: https://your_login.42.fr
   * WordPress admin page: https://your_login.42.fr/wp-admin/

4. **Other commands:**

   **Stop the services** (keeps images and data):
   ```bash
   make down
   ```

   **View logs** (useful for debugging):
   ```bash
   make logs
   ```

   **Full cleanup** (removes containers, images, volumes, and deletes all data in `/home/your_login/data`):
   ```bash
   make fclean
   ```
*** Resources ***
      Docker Documentation – Official docs for Docker: https://docs.docker.com/
      Docker Compose Reference – Manage multi-container applications: https://docs.docker.com/compose/
      WordPress CLI Reference – WP-CLI commands: https://developer.wordpress.org/cli/commands/
      Nginx Documentation – Official Nginx guides: https://nginx.org/en/docs/
      MariaDB Documentation – Database configuration and commands: https://mariadb.com/kb/en/
      SSL/TLS with Nginx – How to configure HTTPS: https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-20-04
      Docker Networking Guide – Bridge, overlay, and host networks: https://docs.docker.com/network/

*** AI Usage Disclosure ***

      AI-assisted tools were employed solely as aids for learning, productivity, and documentation enhancement, including:
      Clarifying complex Docker, networking, and containerization concepts
      Reviewing and organizing documentation structure
      Refining technical explanations for clarity and accuracy
      All architectural designs, configurations, and implementations in this project were conceived, developed, and verified manually by the author
