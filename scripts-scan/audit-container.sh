# --- Configuration des variables ---
CONTAINER="alma-target-audit"
# Le fichier XML confirmé par ta commande précédente
SCAP_FILE="/usr/share/xml/scap/ssg/content/ssg-almalinux9-ds.xml"
# Le profil choisi dans la liste 
PROFILE="xccdf_org.ssgproject.content_profile_ospp"
# Dossier de réception sur l'hôte
HOST_REPORT_DIR="/home/osadmin/scan-oscap/docker-reports"

# --- 1. Lancement du scan (Evaluation) ---
echo "Démarrage du scan OpenSCAP dans le conteneur..."
docker exec $CONTAINER oscap xccdf eval \
    --profile $PROFILE \
    --results /tmp/results.xml \
    --report /tmp/report.html \
    $SCAP_FILE

# --- 2. Génération du script de correction (Fix) ---
echo "Génération du script de correction..."
docker exec $CONTAINER oscap xccdf generate fix \
    --profile $PROFILE \
    --fix-type bash \
    --output /tmp/fix.sh \
    /tmp/results.xml

# --- 3. Récupération des fichiers sur l'hôte ---
echo "Récupération des rapports vers $HOST_REPORT_DIR..."
docker cp $CONTAINER:/tmp/report.html $HOST_REPORT_DIR/report_ospp.html
docker cp $CONTAINER:/tmp/results.xml $HOST_REPORT_DIR/results_ospp.xml
docker cp $CONTAINER:/tmp/fix.sh $HOST_REPORT_DIR/fix_ospp.sh

# --- 4. Nettoyage du conteneur ---
echo "Nettoyage des fichiers temporaires dans le conteneur..."
docker exec $CONTAINER rm /tmp/report.html /tmp/results.xml /tmp/fix.sh

echo "Terminé ! Les fichiers sont disponibles dans $HOST_REPORT_DIR"
