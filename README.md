🛡️ Projet Audit de Sécurité : OpenSCAP & Docker
Ce projet documente la mise en place d'une infrastructure d'audit de sécurité automatisée sur une machine virtuelle CentOS 9 Stream hébergeant des conteneurs Docker.

L'objectif est de scanner et de sécuriser (durcir) à la fois le système hôte (Host) et les conteneurs (Guest) en utilisant le standard SCAP (Security Content Automation Protocol).

🌍 Environnement de Lab
Hyperviseur : VMware Workstation

OS Hôte : CentOS 9 Stream

Adresse IP : 192.168.80.130/24

Utilisateur : osadmin

Cible Docker : Conteneur AlmaLinux 9

🏗️ 1. Préparation de l'Hôte (CentOS 9)
Mise à jour du système et installation des prérequis essentiels.


 ```bash 
# Mise à jour et redémarrage

dnf update -y
reboot


# Installation et activation SSH
dnf install -y openssh-server
systemctl enable --now sshd
Installation de Docker CE
```
```bash
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
dnf install -y docker-ce docker-ce-cli containerd.io

systemctl enable --now docker
usermod -aG docker osadmin
```
Installation d'OpenSCAP
Installation du scanner et de la bibliothèque de règles (SSG).

```bash

dnf install -y openscap-scanner scap-security-guide
mkdir /home/osadmin/scan-oscap/
```
🖥️ 2. Audit de l'Hôte (Machine Virtuelle)
Scan de la machine CentOS 9 elle-même pour vérifier sa conformité.

Profil utilisé : ccn_intermediate (Centro Criptológico Nacional - Intermediate)

Fichier de définition : ssg-cs9-ds.xml

Script de scan hôte
Le scan est exécuté via un script bash automatisant l'évaluation et la génération du correctif.

```bash

# Lancement du script d'audit hôte
bash /home/osadmin/scan-oscap/script.sh
```
Remédiation (Correction)
Le scan génère automatiquement un script fix-direct.sh pour corriger les failles détectées.

```bash

# Application des correctifs sur l'hôte
bash /home/osadmin/scan-oscap/fix-direct.sh
```
🐳 3. Audit du Conteneur Docker
Mise en place d'un conteneur cible (AlmaLinux 9) avec une approche "Agent-less simulé" (les outils de scan sont pré-installés dans l'image pour faciliter l'introspection).

Construction de l'image cible
Le Dockerfile utilisé installe openscap-scanner dans une base AlmaLinux 9.

```bash

# Construction et démarrage
docker build -t target-oscap:v1 .
docker run -d --name alma-target-audit target-oscap:v1
```
Scan du Conteneur (Agent-less)
Le scan est piloté depuis l'hôte mais exécuté à l'intérieur du conteneur via docker exec.

Profil utilisé : ospp (Protection Profile for General Purpose Operating Systems)

Fichier de définition : ssg-almalinux9-ds.xml

```bash

# Lancement du script d'audit conteneur
bash /home/osadmin/scan-oscap/docker-reports/scan_container_alma.sh
```
Ce script récupère automatiquement les rapports (html, xml) et le script de correction (fix.sh) sur l'hôte dans /home/osadmin/scan-oscap/docker-reports/.

Remédiation du Conteneur
Application des correctifs de sécurité directement dans le conteneur actif.

```bash

# 1. Sauvegarde du rapport "Avant"
mv report_ospp.html report_AVANT_fix.html

# 2. Injection et exécution du script de fix
docker cp fix_ospp.sh alma-target-audit:/tmp/fix_ospp.sh
docker exec -it alma-target-audit bash /tmp/fix_ospp.sh
```
📦 4. Export des Résultats
La totalité du projet (Dockerfile, Scripts, Rapports XML/HTML) a été archivée depuis la VM CentOS pour être versionnée.

```bash

# Création de l'archive sur la VM
tar -czvf Project-openscap-docker.tar.gz export-github/

# Récupération sur machine physique via SCP
scp osadmin@192.168.80.130:/home/osadmin/Project-openscap-docker.tar.gz .
```
📂 Structure du Dépôt GitHub
Voici l'organisation des fichiers de ce dépôt :

```Plaintext

openscap-docker-audit/
├── Dockerfile                      # Fichier de construction de l'image AlmaLinux auditable
├── scripts-scan/
│   ├── audit-container.sh          # Script d'automatisation du scan Docker (Scan + Fix Gen + Export)
│   └── audit-hote.sh               # Script d'audit de la machine hôte CentOS
├── reports-examples/               # Exemples de résultats obtenus
│   ├── report_before.html          # Rapport HTML du conteneur AVANT correction
│   └── report_after.html           # Rapport HTML du conteneur APRÈS correction
├── generated-fixes/                # Scripts de correction générés automatiquement par OpenSCAP
│   ├── fix_example_container-alma.sh
│   └── fix_example_hote.sh
└── README.md                       # Documentation du projet
```
📝 Licence
Projet réalisé dans un cadre éducatif/PoC.