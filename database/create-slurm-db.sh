#!/bin/bash
set -e

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

source /etc/slurm/slurmdbd.conf

StorageLoc=${StorageLoc:-slurm_acct_db}
StorageUser=${StorageUser:-slurm}
StoragePass=${StoragePass:-ilovelinux}

echo "Creating slurm accounting database.."
mariadb -uroot <<EOF
create database if not exists $StorageLoc
EOF

echo "Creating $StorageUser mysql user.."
mariadb -uroot <<EOF
create user '$StorageUser'@'%' identified by '$StoragePass';
EOF

echo "Granting $StorageUser access to $StorageLoc.."
echo "grant all on \`${StorageLoc//_/\\_}\`.* to '$StorageUser'@'%';" | mariadb -uroot
echo "flush privileges;" | mariadb -uroot
