#!/bin/bash

export SUPERSET_CONFIG_PATH=/home/superset/superset_config.py

if [ ! -e "/home/superset/superset_config.py" ]; then

    echo "============== superset initialize =============="
    # prepare dir
    mkdir -p /home/superset
    cp /home/superset_config.py.org /home/superset/superset_config.py
    #sudo chown -R `whoami`:`whoami` /home
    #cd /home

    # Initialize the database
    superset db upgrade

    # Create an admin user 
    export FLASK_APP=superset:app \
    && flask fab create-admin \
       --username admin \
       --firstname administrator \
       --lastname '' \
       --email admin@fab.org \
       --password admin

    # Load some data to play with
    #superset load_examples

    # Create default roles and permissions
    superset init

fi

echo "#### superset execute ####"
superset run -h 0.0.0.0 -p 8080 --with-threads --reload --debugger