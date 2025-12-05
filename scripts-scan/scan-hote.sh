OSCAP_PROFILE="xccdf_org.ssgproject.content_profile_ccn_intermediate"
SCAP_CONTENT="/usr/share/xml/scap/ssg/content/ssg-cs9-ds.xml"
RESULT_DIR="/home/osadmin/scan-oscap"

# Scan + rapport
oscap xccdf eval \
    --profile $OSCAP_PROFILE \
    --results $RESULT_DIR/results.xml \
    --report $RESULT_DIR/report.html \
    $SCAP_CONTENT

# Génération du script fix
oscap xccdf generate fix \
    --profile $OSCAP_PROFILE \
    --fix-type bash \
    --output $RESULT_DIR/fix-direct.sh \
    $RESULT_DIR/results.xml

# Vérification
ls -lh $RESULT_DIR
