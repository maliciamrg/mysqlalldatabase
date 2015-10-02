#!/bin/bash

##################################################
# Ce script effectue une sauvegarde des bases de
# données et du dossier des sites et transfert
# cette sauvegarde sur un serveur FTP
##################################################

##############################################
# Variables à modifier
##############################################

#hote FTP
FTP_SERVER="home.daisy-street.fr"  
#login FTP 
FTP_LOGIN="david"     
#pass FTP              
FTP_PASS="haller"     
FTP_DIR="/media/wordpress/"                              
#Utilisateur MySQL
MUSER="daisystreet"   
#pass MySQL                                                 
MPASS="roxanne01"
#hote MySQL                                           
MHOST="localhost"
#Dossier à sauvergarder (dossier dans lequel les sites sont placés)
DIRSITES="/www/"

##############################################
# dossiers temporaires crées (laissez comme ça, ou pas)
##############################################

#Dossier de sauvegarde temporaire des dumps sql
DIRSAVESQL="backups/sql"
#Dossier de sauvegarde temporaire des sites
DIRSAVESITES="backups/sites"


##############################################
#
##############################################
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
GZIP="$(which gzip)"
TAR="$(which tar)"
DBS="$(mysql -u $MUSER -h $MHOST -p$MPASS -Bse 'SHOW DATABASES')"
DATE_FORMAT=="wordpress"
#`date +%Y-%m-%d`  

if [ ! -d $DIRSAVESITES ]; then
  mkdir -p $DIRSAVESITES
else
 :
fi
if [ ! -d $DIRSAVESQL ]; then
  mkdir -p $DIRSAVESQL
else
 :
fi

echo "Sauvegarde des bases de données :"
for db in $DBS
do
    echo "Database : $db"
        FILE=$DIRSAVESQL/mysql-$db-$DATE_FORMAT.gz
        `$MYSQLDUMP -u $MUSER -h $MHOST -p$MPASS $db | $GZIP -9 > $FILE`
done

echo "Creation de l'archive des dumps"
`$TAR -cvzf base-$DATE_FORMAT.tar.gz $DIRSAVESQL`

echo "Création de l'archive des sites"
`$TAR -cvzf sites-$DATE_FORMAT.tar.gz $DIRSITES`

echo "Connexion au serveur FTP et envoi des données"
ftp -n $FTP_SERVER <<END
        user $FTP_LOGIN $FTP_PASS
        put base-$DATE_FORMAT.tar.gz /$FTP_DIR/base-$DATE_FORMAT.tar.gz
        put sites-$DATE_FORMAT.tar.gz /$FTP_DIR/sites-$DATE_FORMAT.tar.gz
        quit
END

echo "Suppression de l'archive de sauvegarde SQL"
rm -Rf $DIRSAVESQL
rm base-$DATE_FORMAT.tar.gz
echo "Suppression de l'archive de sauvegarde des sites"
rm -R $DIRSAVESITES
rm sites-$DATE_FORMAT.tar.gz
