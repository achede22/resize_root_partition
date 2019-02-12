# resize_root_partition
extend Linux root partition without issues

Extender la partición root sin afectación de servicio, lo extiende de 120GB a 190GB , moviendo la partición de LVM hacia el final.
 
La diferencia radica en que:

●	RedHat utiliza tabla de particiones GPT, se modifica con gdisk.

●	CentOS utiliza tabla de particiones MBR, se modifica con fdisk.


 
Es script es sólo para AWS, detecta donde está montado root, si en xvda1 o xvda2, no soporta /dev/sda (AZURE), tarda unos 50 minutos en terminar todo el proceso.
 
Sobre la documentación, es sólo ejecutar el script, no pide parámetros.


-

# PROCEDURE TO MODIFY THE ROOT PARTITION

## 1.	Expand The Root volume to 190GB

•	Login to the aws account, navigate to the desired instance and make the following changes:

Select the disk and choose modify
 
Choose the new size for the disk, and apply the changes
 




## 2.	Attach a new temporary disk

•	Inside the AWS, go to volumes section and choose create volume
 
Select the space to 90GB, and leave the other options by default, later click on create volume
 
You should see something like this
 
Copy the volume id (we are going to need this later), now going back to volumes section we are going to filter by the volume id that we copied it, next we choose attach volume.
 
Now, in instance we enter the name of our machine, and complete the name of the device and click on attach
 

## 3.	Execution of script

•	Paste our script in the VM and simply execute this script as shown below 

You should see something like this after the successfully execution of the script

We recommend to have a snaphot prior of doing this modification, just in case


## 4.	Detaching the temporary disk.

We are going back to aws (volumes section), filter by the volume id, and select with right click on the volume the detach option.

After this please proceed to delete the temporary volume.


