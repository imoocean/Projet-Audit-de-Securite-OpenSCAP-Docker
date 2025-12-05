# Utiliser une base compatible RHEL 9
FROM almalinux:9

# Installer OpenSCAP et les règles de sécurité
RUN dnf install -y openscap-scanner scap-security-guide

# Garder le conteneur actif pour pouvoir se connecter dessus
CMD ["tail", "-f", "/dev/null"]
