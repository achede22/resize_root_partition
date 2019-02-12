#!/bin/bash

cat /etc/redhat-release | grep  
  
cat /etc/redhat-release 

yum install -y gdisk.x86_64

# get variablas AGAIN   
              # get ROOT partition 
              MyROOT=`df | grep -w /  | cut -d" " -f1` 
              echo "root partition is --> $MyROOT" 
              
              # get LVM partition 
              MyLVM_1=`pvs --rows | grep PV | cut -d" " -f4` #fourth column 
              echo "original LVM partition is --> $MyLVM_1" 
              
              # get EMPTY disk, to use as LVM temporaly 
              MyLVM_2_disk=`lsblk -lp | grep disk | grep -v xvda | cut -d" " -f1` #first column 
              echo "New LVM disk is --> $MyLVM_2_disk"
                                               
                                               MyROOT_disk=`echo $MyROOT | rev | cut -c 2- | rev`
              echo "root disk is --> $MyROOT_disk" 
  
#get information 
lsblk  
pvdisplay  
vgs  
lvs  
# create xvdf1 partition, get 100% of the free space 
( 
echo n # Add a new partition 
echo p # Primary partition 
echo 1 # Partition number 
echo   # First sector (Accept default: 1) 
echo   # Last sector (Accept default: varies) 
echo w # Write changes 
) |  fdisk $MyLVM_2_disk 
  
  
# get NEW partition, to use as LVM temporaly 
MyLVM_2_partition=`lsblk -lp | grep part | grep -v xvda | cut -d" " -f1` #first column 
echo "root partition is --> $MyLVM_2_partition"   
     
# Move LVM to the new disk 
pvcreate $MyLVM_2_partition 
  
vgextend vgroot $MyLVM_2_partition 
  
echo "############### Please wait around 20 minutes " 
pvmove $MyLVM_1 $MyLVM_2_partition
lsblk  
vgreduce vgroot $MyLVM_1 
pvremove $MyLVM_1  
pvdisplay  
lsblk  
echo "deleting the original LVM partition --> $MyLVM_1"
part_number=`echo $MyLVM_1 | cut -c10` 

part_number_root=`echo $MyROOT | cut -c10` 
echo "part_number_root $part_number_root"

echo $part_number_root | grep 1 && part_number_LVM="2"
echo $part_number_root | grep 2 && part_number_LVM="3"

###### delete original LVM ############

 ( 
echo p   
echo d  
echo $part_number_LVM   
echo p  
echo w  
)| fdisk $MyROOT_disk

# read new partition table without reboot 
partprobe; lsblk

echo "############## resize root partition (extend to 100GB)-> $MyROOT "  

( 
echo p   
echo d  
echo $part_number_root 
echo n  
echo p  
echo $part_number_root  
echo   


echo +100G  
echo p  
echo w  
)| fdisk $MyROOT_disk 
 
  
# read new partition table without reboot 
partprobe
lsblk 
  
########## recreate original LVM partition ###############
( 
echo p    
echo n  
echo p  
echo $part_number_LVM  
echo   
echo
echo p  
echo w  
)| fdisk $MyROOT_disk
# read new partition table without reboot 
partprobe
lsblk 

######### Move LVM structure to original partition ##############   
echo y | pvcreate $MyLVM_1 -ff   
vgextend vgroot $MyLVM_1  
vgreduce vgroot --removemissing 

echo "############### Please wait around 20 minutes "  
pvmove $MyLVM_2_partition $MyLVM_1   
vgreduce vgroot $MyLVM_2_partition
pvremove $MyLVM_2_partition
vgreduce vgroot --removemissing 
lsblk      

echo  " ###### root partition has been extended succesfully, Please dettach the aditional disk "
