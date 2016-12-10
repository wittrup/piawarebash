if [[ -n $1  ]]; then # True if the length of string is non-zero.
    sudo groupadd sshtungrp
    sudo useradd sshtunnel -m -d /home/sshtunnel -s /bin/false -p '*' -g sshtungrp
    sudo -u sshtunnel chmod 710 /home/sshtunnel

    sudo -u sshtunnel mkdir /home/sshtunnel/.ssh
    sudo -u sshtunnel chmod 710 /home/sshtunnel/.ssh

    sudo -u sshtunnel touch /home/sshtunnel/.ssh/authorized_keys
    sudo -u sshtunnel chmod 640 /home/sshtunnel/.ssh/authorized_keys

    while read p; do
        sudo useradd $p -d /home/sshtunnel -s /bin/true -p '*' -g sshtungrp
    done < $1

    echo "Copy your keys into:"
    echo "sudo -u sshtunnel vim /home/sshtunnel/.ssh/authorized_keys"
else
    echo Missing arguments
fi
