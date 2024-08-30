# Resize Root Partition Script

This script resizes the root partition on CentOS/Red Hat and Ubuntu/Debian systems. It works by moving existing LVM data to a temporary disk, resizing the root partition, and then moving the LVM data back.

## Features

- **OS Detection**: Automatically detects if the script is run on CentOS/Red Hat or Ubuntu/Debian.
- **Root Check**: Ensures the script is run with root permissions.
- **Readable Functions**: Improved variable names and logic for better readability.
- **Avoids Redundancies**: Removed unnecessary commands and combined actions where possible.
- **Input Validation**: Ensures correct usage of command-line tools.

## Prerequisites

- A temporary disk available to use as an LVM device.
- Root privileges to run the script.

## Usage

1. **Clone the Repository**:
    `git clone https://github.com/your-github-username/resize_root_partition_script.git`

2. **Navigate to the Script Directory**:
    `cd resize_root_partition_script`

3. **Make the Script Executable**:
    `chmod +x resize_root_partition_centos.sh`

4. **Run the Script**:
    `sudo ./resize_root_partition_centos.sh`

## Script Details

- **OS Detection**:
    - Checks `/etc/redhat-release` for Red Hat/CentOS.
    - Checks `/etc/lsb-release` for Ubuntu/Debian.
    
- **Package Installation**:
    - Installs `gdisk` using `yum` for Red Hat/CentOS.
    - Installs `gdisk` using `apt-get` for Ubuntu/Debian.
    
- **Partitioning and LVM Management**:
    - Partitions a new disk for temporary LVM storage.
    - Moves existing LVM data to the new partition.
    - Resizes the root partition to 100GB.
    - Moves LVM data back to the resized root partition.

## Example Output

- **Detected OS**:
    `Detected OS: centos`
    
- **Root Partition**:
    `Root partition is: /dev/sda1`
    
- **Original LVM Partition**:
    `Original LVM partition is: /dev/sda2`
    
- **New LVM Disk**:
    `New LVM disk is: /dev/sdb`
    
- **New LVM Partition**:
    `New LVM partition is: /dev/sdb1`

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## Author

- [Achede_HD](https://github.com/achede22)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

Feel free to contribute to this project by submitting issues or pull requests. Your feedback and contributions are welcome!