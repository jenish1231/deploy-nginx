#!/bin/bash

NAME=""
DIR=path-to-project-directory
USER=root
GROUP=root
WORKERS=3
BIND=unix:path-to-sock.sock
DJANGO_SETTINGS_MODULE=django-project-settings
DJANGO_WSGI_MODULE=django-wsgi.wsgi
LOG_LEVEL=error

cd $DIR
source ../venv/bin/activate



exec ../venv/bin/gunicorn ${DJANGO_WSGI_MODULE}:application \
        --name $NAME \
        --workers $WORKERS \
        --user=$USER \
        --group=$GROUP \
        --bind=$BIND \
        --log-level=$LOG_LEVEL \
        --log-file=-

