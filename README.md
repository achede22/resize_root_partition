# resize_root_partition
extend Linux root partition without issues

Extender la partición root sin afectación de servicio, lo extiende de 120GB a 190GB , moviendo la partición de LVM hacia el final.
 
La diferencia radica en que:
●	RedHat utiliza tabla de particiones GPT, se modifica con gdisk
●	CentOS utiliza tabla de particiones MBR, se modifica con fdisk.
 
Es script es sólo para AWS, detecta donde está montado root, si en xvda1 o xvda2, no soporta /dev/sda (AZURE), tarda unos 50 minutos en terminar todo el proceso.
 
Sobre la documentación, es sólo ejecutar el script, no pide parámetros.

