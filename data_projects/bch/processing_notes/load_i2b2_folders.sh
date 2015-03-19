/usr/bin/time -v sqlplus -s biomart_user/dwtst@BCH_DWTST<<EOF
exec BIOMART_USER.PRUNE_I2B2();
exit;
EOF
