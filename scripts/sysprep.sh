#!/bin/sh

set -e

# clean out state for cloning
rm /etc/ssh/ssh_host_*key
rm /etc/random.seed
