#!/bin/bash
# Mettre à jour la liste des paquets
apt-get update

# Installer Nginx automatiquement (-y pour dire oui à tout)
apt-get install -y nginx

# Créer une page d'accueil personnalisée pour prouver que c'est notre script
echo "<h1>Felicitations ! Deploiement Automatise via Terraform & Cloud-Init</h1>" > /var/www/html/index.html

# S'assurer que le service est démarré
systemctl start nginx
systemctl enable nginx
