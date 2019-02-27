#!/bin/bash

echo "Stating ansbile..."

ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -i ../hosts --private-key ../key/beerstore_key beerstore-playbook.yml -v
