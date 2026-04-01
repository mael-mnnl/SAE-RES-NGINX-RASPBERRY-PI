#!/bin/bash

# --- Couleurs ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Installation et Configuration de Nginx ===${NC}"

# 1. Vérification des privilèges
if [[ $EUID -ne 0 ]]; then
   echo "Ce script doit être lancé en tant que root (ou avec sudo)"
   exit 1
fi

# 2. Mise à jour du système
echo -e "\n${GREEN}[1/6] Mise à jour des dépôts...${NC}"
apt update && apt upgrade -y

# 3. Installation de Nginx
echo -e "\n${GREEN}[2/6] Installation de Nginx...${NC}"
apt install -y nginx

# 4. Configuration du Pare-feu (UFW)
echo -e "\n${GREEN}[3/6] Configuration du pare-feu pour HTTP/HTTPS...${NC}"
if command -v ufw > /dev/null; then
    ufw allow 'Nginx Full'
    # On s'assure que SSH reste ouvert pour ne pas se faire enfermer dehors !
    ufw allow OpenSSH
    echo "y" | ufw enable
fi

# 5. Création du répertoire pour le site
# Remplacez 'mon-site.com' par votre nom de domaine ou IP
DOMAIN="mon-site.local"
WEB_ROOT="/var/www/$DOMAIN/html"

echo -e "\n${GREEN}[4/6] Création des dossiers dans $WEB_ROOT...${NC}"
mkdir -p $WEB_ROOT
chown -R $USER:$USER /var/www/$DOMAIN/html
chmod -R 755 /var/www/$DOMAIN

# Création d'une page de test
echo "<h1>Succès ! Nginx tourne sur $DOMAIN</h1>" > $WEB_ROOT/index.html

# 6. Création du fichier de configuration Nginx
echo -e "\n${GREEN}[5/6] Configuration du Server Block...${NC}"
CONF_FILE="/etc/nginx/sites-available/$DOMAIN"

cat > $CONF_FILE <<EOF
server {
    listen 80;
    listen [::]:80;

    root $WEB_ROOT;
    index index.html index.htm;

    server_name $DOMAIN;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# Activation de la config et test
ln -sf $CONF_FILE /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default # Désactive la page par défaut

echo -e "\n${GREEN}[6/6] Redémarrage de Nginx...${NC}"
nginx -t && systemctl restart nginx

echo -e "\n${BLUE}==============================================${NC}"
echo -e "${GREEN}Terminé ! Nginx est configuré.${NC}"
echo -e "Votre dossier web est : ${BLUE}$WEB_ROOT${NC}"
echo -e "Votre fichier de config est : ${BLUE}$CONF_FILE${NC}"
