#!/bin/bash
REMOTE_NAME="am_remote"
REMOTE_URL="https://github.com/AlterMundi-MonitoreoyControl/Proyecto-Incubadora.git"

# Check if the remote is already configured
if git remote get-url "$REMOTE_NAME" &> /dev/null; then
    echo "Remote '$REMOTE_NAME' is already configured."
else
    echo "Remote '$REMOTE_NAME' is not configured. Adding it now..."
    git remote add "$REMOTE_NAME" "$REMOTE_URL"
    echo "Remote '$REMOTE_NAME' added with URL: $REMOTE_URL"
fi 

echo "obteniendo pull numero "$1
git status 
echo "verificar que no hay cambios si ves cambios presionar ctrl-c" 
read -n 1 -s
git fetch am_remote pull/$1/head:$1
git checkout $1
#$appfilecopy
echo "seguir procedimiento de pruebas para verificar que no se rompio nada"