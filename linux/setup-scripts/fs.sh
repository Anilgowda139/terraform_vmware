#!/bin/bash

# This script will only execute when user is root

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo "This script is running as root"

mount_points="/tmp/mounts"

disks=`grep '^disks=' $mount_points | sed -e 's/^.*=//'`
vg=`grep '^vg=' $mount_points | sed -e 's/^.*=//'`
sizes=`grep '^sizes=' $mount_points | sed -e 's/^.*=//'`
lvs=`grep '^lv=' $mount_points | sed -e 's/^.*=//'`
fs=`grep '^fs=' $mount_points | sed -e 's/^.*=//'`
fstype=`grep '^fstype=' $mount_points | sed -e 's/^.*=//'`


disk_list=($(echo $disks | tr "|" "\n"))
size_list=($(echo $sizes | tr "|" "\n"))
fs_list=($(echo $fs | tr "|" "\n"))
lv_list=($(echo $lvs | tr "|" "\n"))


for i in ${!disk_list[@]}; do
    echo "Creating physical volume on ${disk_list[i]}"
    /bin/echo -e "n\np\n1\n\n\nt\n8e\nw" | sudo fdisk ${disk_list[i]}
    pvcreate ${disk_list[i]}1
done


echo "Creating physical volume on ${disk_list[i]}"
vgcreate $vg ${disk_list[0]}1


for i in ${!disk_list[@]}; do
    echo "Extending the VG "
    vgextend $vg ${disk_list[i]}1
done

for i in ${!lv_list[@]}; do
 if [ ${size_list[i]} = "100%FREE" ]
  then
    lvcreate -l 100%FREE -n ${lv_list[i]} --wipesignatures y --yes --zero y /dev/mapper/$vg
  else
    echo "Creating the Logical Volume ${lv_list[i]}"
    lvcreate -L +${size_list[i]} -n ${lv_list[i]} --wipesignatures y --yes --zero y /dev/mapper/$vg
 fi
done

for i in ${!lv_list[@]}; do
    echo "Creating the filesystems ${lv_list[i]}"
    mkfs.$fstype /dev/mapper/$vg-${lv_list[i]}
done

for i in ${!fs_list[@]}; do
    echo "Creating the directories ${fs_list[i]}"
    mkdir -p ${fs_list[i]}
done

for i in ${!lv_list[@]}; do
    echo "mouting the filesystem ${fs_list[i]}"
    echo "/dev/mapper/$vg-${lv_list[i]} ${fs_list[i]} $fstype defaults 0 0" >> /etc/fstab
    mount -a
done