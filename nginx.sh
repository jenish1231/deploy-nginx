commands="socket service activate nginx"

select option in $commands; do
    if [ $option == 'socket' ]; then
        read -p "Enter socket name :" socket
        sudo echo '
[Unit]
Description='"$socket"' socket

[Socket]
ListenStream=/run/'"$socket"'.sock

[Install]
WantedBy=sockets.target
        ' > $socket.socket
        sudo mv $socket.socket /etc/systemd/system/$socket.socket
    elif [ $option == 'service' ]; then
        read -p "Project path : " path
        read -p "gunicorn env path : " env
        read -p "username : " username
        read -p "project name : " project
        read -p "socket name : " socket

        sudo echo '
[Unit]
Description='"$socket"' daemon
Requires='"$socket"'.socket
After=network.target

[Service]
User='"$username"'
Group=www-data
WorkingDirectory='"$path"'
ExecStart='"$env"' \
    --access-logfile - \
    --workers 3 \
    --bind unix:/run/'"$socket"'.sock \
    '"$project"'.wsgi:application

[Install]
WantedBy=multi-user.target
        ' > $socket.service
        sudo mv $socket.service /etc/systemd/system/$socket.service

        sudo systemctl start $socket.socket
        sudo systemctl enable $socket.socket
    elif [ $option == 'nginx' ]; then
        read -p "Domain or IP : " ip
        read -p "Port : " port
        read -p "Project Path : " path
        read -p "socket : " socket
        read -p "Project Name : " project
        sudo echo '
server {
    listen '"$port"';
    server_name '"$ip"';

    location = /favicon.ico { access_log off; log_not_found off; }
    location /static/ {
        root '"$path"';
    }

    location / {
        include proxy_params;
        proxy_pass http://unix:/run/'"$socket"'.sock;
    }
}
' > $project
    sudo mv $project /etc/nginx/sites-available/$project
    sudo ln -s /etc/nginx/sites-available/$project /etc/nginx/sites-enabled
    sudo systemctl restart nginx
    sudo ufw delete allow $port
    sudo ufw allow 'Nginx Full'
    elif [ $option == 'activate' ]; then
        read -p "socket : " socket
        sudo systemctl start $socket.socket
        sudo systemctl enable $socket.socket
    fi


done
