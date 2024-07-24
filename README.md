# DevOpsFetch Documentation

### Introduction
DevOpsFetch is a script designed to retrieve and log various system information including active ports, Docker images and containers, Nginx domains, user logins, and system activities within a specified time range. This guide covers the installation, configuration, usage, and logging mechanism of the script.

### Installation and Configuration

*Step 1: Fork or clone this repo*

Save the `devopsfetch.sh` script to your desired location, such as `/home/hayzedak/HNG5/devopsfetch.sh` and cd into the directory that contains the script.

*Step 2: Make the Script Executable*

`sudo chmod +x devopsfetch.sh`

*Step 3: Install Dependencies and Set Up the Service*

Run the script with the --install option to install necessary dependencies and set up the systemd service:

`devopsfetch.sh --install`


This command will:

- Update the package list.

- Install net-tools, nginx, and docker.io.

- Enable and start the Docker service.

- Create a systemd service file for DevOpsFetch.

- Enable and start the devopsfetch service.

*Step 4: Enable and Start the Service*

If you need to manually enable and start the service:

```
sudo systemctl daemon-reload
sudo systemctl enable devopsfetch
sudo systemctl start devopsfetch
```

### Usage

Run the script with different options to retrieve specific system information.

`devopsfetch.sh [OPTIONS]`

**Options**

-p, --port: List all active ports and services.

-p <port_number>: Detailed information about a specific port.

-d, --docker: List all Docker images and containers.

-d <container_name>: Detailed information about a specific container.

-n, --nginx: Display all Nginx domains and their ports.

-n <domain>: Detailed configuration information for a specific domain.

-u, --users: List all users and their last login times.

-u <username>: Detailed information about a specific user.

-t, --time <start> <end>: Display activities within a specified time range.

--install: Install dependencies and set up the service.

-h, --help: Show the help message.


### Logging Mechanism

Log File:

All logged information is stored in `/var/log/devopsfetch.log`.

### Viewing Logs

To view the log file, use:

`sudo cat /var/log/devopsfetch.log`


### To continuously monitor the log file, use:

`sudo tail -f /var/log/devopsfetch.log`



