#!/bin/sh



function patch_firmware()
{

if [ $# -ne 4 ]
then
    echo "4 arguments expected by function patch_firmware IMAGE_FILE, svn-repo absolute path, \[500|500a|500i|500m|500mini|500minia|500plus|R2A|HDR3\], SDK version \[2|3|4\]"
    exit 1
fi

IMAGE_FILE=$1
SVN_REPO=$2
VERSION=$3
SDK=$4
TEA="no"
SIMPLE_VERSION=${VERSION}
USE_EBODA_INSTALL="no"
USE_M8_INSTALL="no";
ACRYAN_MENU="no" #contains news instead youtube, keep original font
EGREAT_MENU="no"
OPLAY_MENU="no"
KEEP_ORIGINAL_BUSYBOX="NO"

if [ ${VERSION} = "500a" ]
then
    USE_EBODA_INSTALL="yes";
    TEA="YES";
    SIMPLE_VERSION="500"
    ACRYAN_MENU="YES"
fi

if [ ${VERSION} = "500i" ]
then
    USE_EBODA_INSTALL="yes";
    TEA="NO";
    SIMPLE_VERSION="500"
fi

if [ ${VERSION} = "500m" ]
then
    USE_M8_INSTALL="yes";
    TEA="YES";
    SIMPLE_VERSION="500"
    ACRYAN_MENU="YES"
fi

if [ ${VERSION} = "500minia" ]
then
    USE_EBODA_INSTALL="yes";
    SIMPLE_VERSION="500mini"
    TEA="YES";
    ACRYAN_MENU="YES"
fi


if [ ${VERSION} = "PV73200" ]
then
    USE_EBODA_INSTALL="no";
    SIMPLE_VERSION="500mini"
    TEA="YES";
    ACRYAN_MENU="YES"
fi

if [ ${VERSION} = "PV73100" ]
then
    USE_EBODA_INSTALL="no";
    SIMPLE_VERSION="500"
    TEA="YES";
    ACRYAN_MENU="YES"
fi

if [ ${VERSION} = "MP3011" ]
then
    USE_EBODA_INSTALL="no";
    SIMPLE_VERSION="500"
    TEA="NO";
fi

if [ ${VERSION} = "R2A" ]
then
    USE_EBODA_INSTALL="no";
    SIMPLE_VERSION="500mini"
    TEA="NO";
    KEEP_ORIGINAL_BUSYBOX="NO"
    EGREAT_MENU="YES"
fi

if [ ${VERSION} = "HDR3" ]
then
    USE_EBODA_INSTALL="no";
    SIMPLE_VERSION="500mini"
    TEA="NO";
    KEEP_ORIGINAL_BUSYBOX="NO"
    OPLAY_MENU="YES"
fi



if [ ${VERSION} = "MP3012" ]
then
    USE_EBODA_INSTALL="no";
    SIMPLE_VERSION="500plus"
    TEA="NO";
fi


if [ ${VERSION} = "500m" -o ${VERSION} = "500i" -o ${VERSION} = "500a" -o ${VERSION} = "500minia" -o ${VERSION} = "500" -o ${VERSION} = "500mini" -o ${VERSION} = "500plus" -o ${VERSION} = "PV73200" -o ${VERSION} = "PV73100"  -o ${VERSION} = "MP3011" -o ${VERSION} = "MP3012" -o ${VERSION} = "R2A" -o ${VERSION} = "HDR3" ]
then
    echo Patching firmware variant ${VERSION}
else
    echo Wrong firmware variant
    exit 1
fi

if [ ${SDK} = "2" -o ${SDK} = "3" -o ${SDK} = "4" ]
then
    echo Patching SDK version ${SDK}
else
    echo Wrong SDK variant
    exit 1
fi


####################
# CHECKING prequisites
#

#checking original firmware presence

[ -f ${IMAGE_FILE} ] || ( echo "Original install.img not found" &&  exit 3 )
echo Original install.img found, continuing


if [ -d ${SVN_REPO}/.svn ]
then
    echo SVN dir ${SVN_REPO} found, continuing
else
    echo  Wrong argument given, please suppply absolute path to SVN directory in first argument
    exit 1
fi

#checking Resources and other directories presence
if [ ! -d ${SVN_REPO}/src/${SIMPLE_VERSION}/Resource ]
then
    echo Resources not found, repository incomplete
    exit 1
fi

if [ ! -d ${SVN_REPO}/src/bin ]
then
    echo bin not found, repository incomplete
    exit 1
fi

if [ ! -d ${SVN_REPO}/src/${SIMPLE_VERSION}/image ]
then
    echo image not found, repository incomplete
    exit 1
fi
echo "All resources and directories found, continuing"

#cheking unyaffs tools
which unyaffs >/dev/null
if [ $? -eq 1 ]
then
    echo 'required tool unyaffs not in PATH, please update PATH or copy unyaffs binary in "/usr/bin"'
    exit
fi

which mkyaffs2image >/dev/null
if [ $? -eq 1 ]
then
    echo 'required tool unyaffs not in PATH, please update PATH or copy mkyaffs2image binary in "/usr/bin"'
    exit
fi
echo unyaffs tools are present

#
# CHECKING prequisites
####################


####################
# modifying firmware


# unpack img
mkdir unpacked_install
[ $? -eq 0 ] || exit 'cannot create "unpacked_install" dir please start from a clean directory'

cd unpacked_install/
tar xf ../${IMAGE_FILE}

echo install.img inpacked

#
# go to package 2
cd package2/

#
# unpack root
mkdir unpacked_root
[ $? -eq 0 ] || exit cannot create dir please start from a clean directory
echo "Unpacking root image"

cd unpacked_root/

if [ ${SDK} = "2" ]
then
    unyaffs ../yaffs2_1.img
elif [ ${SDK} = "3" -o ${SDK} = "4" ]
then
    if [ $TEA = "YES" ]
    then
	tea -d -i ../squashfs1.upg -o ../squashfs1.img -k 12345678195454322338264935438139
	rm ../squashfs1.upg
    fi
    unsquashfs3 ../squashfs1.img 
    cd squashfs-root
fi


#
#modify root

# in last version e-boda makes /opt symlink to /usr/local/etc and mess-up my optware !!!
echo "removing optdir if present"
rm -f opt

# cb3pp directory for apps
mkdir cb3pp

# ewcp directory for apps
mkdir ewcp

# and opt for other people to play
mkdir opt

# and rss_ex requirements
mkdir rss_ex
ln -s ../etc/translate/rss usr/local/bin/rss

mkdir xVoD


# and scripts for me to play
mkdir scripts

# and xLive for me to play
mkdir xLive

# and utilities for me to play
mkdir utilities



#home dir for root part 1
sed -i -e '/^root/c\
root::0:0:root:/usr/local/etc/root:/bin/sh' etc/passwd
echo passwd updated

if [ ${SDK} -ne 4 ]
then

sed -i -e '/\/tmp\/package\/script\/samba-security/i\
addmountpointtosambaconf ext3 /tmp/hdd/root/' usr/local/bin/package/script/configsamba
echo configsamba 1

sed -i -e '/mountpoint=$(cat \/proc\/mounts|grep $l |cut -d" " -f 2)/c\
mountpoint=$(cat /proc/mounts|grep $l | head -n 1 | cut -d" " -f 2)' usr/local/bin/package/script/configsamba
echo configsamba 2

fi

# traducere + font
#cp  ${SVN_REPO}/src/${SIMPLE_VERSION}/Resource/*.str usr/local/bin/Resource 


if [ $ACRYAN_MENU = "YES" ]
then
    echo "Keeping original fon, needed for acryan news menu"
else
    #echo "No longer replacing font to save some space"
    echo "Replacing font"
    #not sure is we still need this
    # let's try without
    cp  ${SVN_REPO}/src/${SIMPLE_VERSION}/Resource/*.TTF usr/local/bin/Resource 
fi


sed -i -e '/export TZ=CST+0:00:00/a\
if [ -f /usr/local/etc/TZ ]\
then\
. /usr/local/etc/TZ\
fi' etc/profile

if [ ${VERSION} = "HDR3" ]
then
    cp -a ${SVN_REPO}/src/${SIMPLE_VERSION}/lib/* lib/

fi






# screensaver + skinpack
# keeping original files
#cp  ${SVN_REPO}/src/${SIMPLE_VERSION}/Resource/bmp/* usr/local/bin/Resource/bmp 
#cp  ${SVN_REPO}/src/${SIMPLE_VERSION}/image/* usr/local/bin/image 

# awk
#CBA awk is OK in SDK 4, update no longer needed
if [ $SDK -ne 4 ]
then
    echo overwriting awk
    rm usr/bin/awk
    cp  ${SVN_REPO}/src/bin/awk usr/bin
    chmod +x usr/bin/awk
else
    echo NOT overwriting awk
fi

#use my init + startup
if [ ${KEEP_ORIGINAL_BUSYBOX} = "YES" ]
then
    echo Not updating init + httpd busybox version
    echo 'ifconfig eth0 192.168.0.2 netmask 255.255.0.0
' >> etc/init.d/rcS
else
    echo Updating init + httpd busybox version

    rm sbin/init
    
    cp ${SVN_REPO}/src/bin/busybox.1.18.4 sbin/
    ln -s ../sbin/busybox.1.18.4 sbin/init
    chmod +x sbin/busybox.1.18.4


    [ -f sbin/httpd ] && rm sbin/httpd
    ln -s ../sbin/busybox.1.18.4 sbin/httpd
    
    [ -f etc/httpd.conf ] && rm etc/httpd.conf

    cat > etc/inittab <<EOF
#If no inittab is found, it has the following default behavior
::sysinit:/etc/init.d/rcS
::askfirst:/bin/sh
#If it detects that /dev/console is _not_ a serial console, it will also run
# not needed
# tty::askfirst:/bin/sh
# Stuff to do before rebooting
::shutdown:/etc/init.d/rcK
::restart:/sbin/init
EOF


    cat > etc/init.d/rcK <<EOF
#!/bin/sh
[ -f /usr/local/etc/rcK ] && /usr/local/etc/rcK>/dev/console
/bin/umount -a -r
/sbin/swapoff -a
EOF

    chmod +x etc/init.d/rcK


fi

# eboda web control panel
dir=`pwd`
cd ${SVN_REPO}/www/
find ewcp | grep -v .svn | grep -v '~' | zip -9 ${dir}/ewcp4.zip -@
cp ewcp4-version.txt ${dir}/
cd $dir

# /cb3pp
dir=`pwd`
cd ${SVN_REPO}/src/
find cb3pp | grep -v .svn | grep -v '~'  | zip -9 ${dir}/cb3pp4.zip -@
cp cb3pp4-version.txt ${dir}/
cd $dir

# IMS menu
if [ ${SDK} -ne 4 ]
then
    echo overwriting IMS menu
    if [ $ACRYAN_MENU = "YES" ]
        then
        echo ACRyan menu
        cp ${SVN_REPO}/src/${SIMPLE_VERSION}/menu/menu.rss_sdk${SDK}_acryan usr/local/bin/scripts/menu.rss
    elif [ $EGREAT_MENU = "YES" ] 
        then
        echo EGreat menu
        cp ${SVN_REPO}/src/${SIMPLE_VERSION}/menu/menu.rss_sdk${SDK}_egreat usr/local/bin/scripts/menu.rss
    elif [ $OPLAY_MENU = "YES" ] 
        then
        echo Asus Oplay menu
        cp ${SVN_REPO}/src/${SIMPLE_VERSION}/menu/menu.rss_sdk${SDK}_oplay usr/local/bin/scripts/menu.rss
    else
        echo Eboda menu
        cp ${SVN_REPO}/src/${SIMPLE_VERSION}/menu/menu.rss_sdk${SDK} usr/local/bin/scripts/menu.rss
    fi
else
    cp usr/local/bin/scripts/menu.rss usr/local/bin/scripts/menu_orig.rss
    cp ${SVN_REPO}/src/${SIMPLE_VERSION}/menu/menu.rss_sdk${SDK} usr/local/bin/scripts/menu.rss
    echo "overwriting IMS menu(try)"
fi


[ -d usr/local/bin/scripts/image ] || mkdir usr/local/bin/scripts/image
cp ${SVN_REPO}/src/${SIMPLE_VERSION}/menu/image/* usr/local/bin/scripts/image/

if [ ${SDK} -eq 3 ]
then
#Repair some weather stuff
    cp ${SVN_REPO}/src/${SIMPLE_VERSION}/map/* usr/local/bin/IMS_Modules/Weather/scripts/map/
fi

#rss_ex

# if [ ${SIMPLE_VERSION} = "500" ]

# then
#     cp ${SVN_REPO}/scripts/feeds/rss_ex/rss_ex/www/cgi-bin/* usr/local/bin/Resource/www/cgi-bin/
#     chmod +x usr/local/bin/Resource/www/cgi-bin/
# else
#     cp ${SVN_REPO}/scripts/feeds/rss_ex/rss_ex/www/cgi-bin/* tmp_orig/www/cgi-bin/
#     chmod +x tmp_orig/www/cgi-bin/*
# fi
# #www

# [ -d tmp_orig/www/bin/ ] || mkdir tmp_orig/www/bin/
# cp ${SVN_REPO}/scripts/feeds/rss_ex/rss_ex/www/bin/* tmp_orig/www/bin/
# chmod +x tmp_orig/www/bin/*

#[ -d tmp_orig/www/img/ ] || mkdir tmp_orig/www/img/
#cp ${SVN_REPO}/scripts/feeds/rss_ex/rss_ex/www/img/* tmp_orig/www/img/


#media translate
# no space in firmware, latest version will be downloaded from internet
# dir=`pwd`
cd ${SVN_REPO}/scripts/feeds/zero_version/rss_ex/
find rss_ex/ | grep -v .svn | grep -v '~' | zip -9 ${dir}/rss_ex4.zip -@
cp rss_ex-version.txt ${dir}/rss_ex4-version.txt
cd ${dir}


cd ${SVN_REPO}/scripts/feeds/zero_version/xVoD/
find xVoD/ | grep -v .svn | grep -v '~' | zip -9 ${dir}/xVoD4.zip -@
cp xVoD-version.txt ${dir}/xVoD4-version.txt
cd ${dir}


# vb6 bin
# bin is in /scripts/bin


# vb6 cgi-bin

# if [ ${SIMPLE_VERSION} = "500" ]

# then
#     cp {SVN_REPO}/scripts/feeds/scripts_vb6/scripts/cgi-bin/* usr/local/bin/Resource/www/cgi-bin/
#     chmod +x usr/local/bin/Resource/www/cgi-bin/
# else
#     cp {SVN_REPO}/scripts/feeds/scripts_vb6/scripts/cgi-bin/* tmp_orig/www/cgi-bin/
#     chmod +x tmp_orig/www/cgi-bin/*
# fi



# vb6 scripts
# no space in firmware, latest version will be downloaded from internet
# dir=`pwd`
cd ${SVN_REPO}/scripts/feeds/zero_version/scripts_vb6/
find scripts | grep -v .svn | grep -v '~' | zip -9 ${dir}/scripts4.zip -@
cp scripts-version.txt ${dir}/scripts4-version.txt
cd ${dir}

# xLive
#out because no space.
#I should make script to take-it from internet!
#dir=`pwd`
cd ${SVN_REPO}/scripts/feeds/zero_version/xLive
find xLive | grep -v .svn | grep -v '~' | zip -9 ${dir}/xLive4.zip -@
cp xLive-version.txt ${dir}/xLive4-version.txt
cd ${dir}

#patch DvdPlayer binary

#bspatch oldfile newfile patchfile
if [ ${VERSION} = "500minia" -o ${VERSION} = "500a" ]
then
    echo patching DvdPlayer
    bspatch usr/local/bin/DvdPlayer usr/local/bin/DvdPlayer.patched ${SVN_REPO}/src/${SIMPLE_VERSION}/DvdPlayer.bspatch_sdk${SDK}
    mv usr/local/bin/DvdPlayer.patched usr/local/bin/DvdPlayer 
    chmod +x usr/local/bin/DvdPlayer
fi


#bspatch oldfile newfile patchfile
if [ ${VERSION} = "500m" ]
then
    echo patching DvdPlayer
    bspatch usr/local/bin/DvdPlayer usr/local/bin/DvdPlayer.patched ${SVN_REPO}/src/${SIMPLE_VERSION}/DvdPlayer.bspatch_m_sdk${SDK}
    mv usr/local/bin/DvdPlayer.patched usr/local/bin/DvdPlayer 
    chmod +x usr/local/bin/DvdPlayer
fi

# if [ ${SDK} = "2" ]
# then
#     ## egreat is this one
#     sed -i -e '$a\
# www3    stream  tcp     nowait  www-data        /usr/sbin/httpd httpd -h /scripts\
# www4    stream  tcp     nowait  www-data        /usr/sbin/httpd httpd -h /rss_ex/www\
# www5    stream  tcp     nowait  www-data        /usr/sbin/httpd httpd -h /xLive' etc/inetd.conf

# else
#inetd.conf
    sed -i -e '$a\
www3    stream  tcp     nowait  www-data        /sbin/httpd httpd -i -h /scripts\
www4    stream  tcp     nowait  www-data        /sbin/httpd httpd -i -h /rss_ex/www\
www5    stream  tcp     nowait  www-data        /sbin/httpd httpd -i -h /xLive' etc/inetd.conf
# fi


#services.conf
sed -i -e '$a\
http3           83/tcp          www3 www3-http  # HyperText Transfer Protocol\
http3           83/udp          www3 www3-http  # HyperText Transfer Protocol\
http4           84/tcp          www4 www4-http  # HyperText Transfer Protocol\
http4           84/udp          www4 www4-http  # HyperText Transfer Protocol\
http5           85/tcp          www5 www5-http  # HyperText Transfer Protocol\
http5           85/udp          www5 www5-http  # HyperText Transfer Protocol' etc/services

sed -i -e '1a\
[ -f /usr/local/etc/rcK ] && /usr/local/etc/rcK' usr/sbin/pppoe-stop



#packaging root back
if [ ${SDK} = "2" ]
then
    cd ..
    rm yaffs2_1.img
    mkyaffs2image unpacked_root yaffs2_1.img 
elif [ ${SDK} = "3" -o ${SDK} = "4" ]
then
    rm ../../squashfs1.img
    mksquashfs3 * ../../squashfs1.img -b 65536
    cd  ..
    if [ $TEA = "YES" -a $USE_EBODA_INSTALL = "no" -a $USE_M8_INSTALL = "no" ]
    then
    	tea -e -i ../squashfs1.img -o ../squashfs1.upg -k 12345678195454322338264935438139
    	rm ../squashfs1.img
    fi
    cd ..
fi


rm -rf unpacked_root/

#unpacking /usr/local/etc
mkdir unpacked_etc
[ $? -eq 0 ] || exit cannot create dir please start from a clean directory


cd unpacked_etc/

tar jxvf ../usr.local.etc.tar.bz2

#root home part 2
mkdir root

echo 'PATH=/cb3pp/bin:$PATH' >> root/.profile
echo 'export PATH' >>  root/.profile


#rss_ex
ln -s  /rss_ex translate

#gracefully stop transmission
#NOK with SDK4

#[ -d dvdplayer/script ] || mkdir -p dvdplayer/script
#ln -s /usr/local/etc/rcK dvdplayer/script/stop_livepause

#better link at pppoe end script

# keep this to be mine
# later update to come for external images of xtreamer
# cp ${SVN_REPO}/src/${SIMPLE_VERSION}/etc/rcS .

# creating our startup script to install cb3pp stuff if not in
echo '#!/bin/sh
#BEGIN CBA_CB3PP_STARTUP
# wait storage to be mounted
if [ -f /usr/local/etc/use_storage ]
then

	mount_pattern=`cat /usr/local/etc/use_storage`
else
	mount_pattern=scsi
fi
#TODO find what to check instead root which exists even if not mounted?

n=1
mount | grep ${mount_pattern}
while [ $? -ne 0 ] ; do
sleep 3
[ $n -gt 30 ] && break
let n+=1
echo "#waiting for hdd.."
mount | grep ${mount_pattern}
done

if [ $n -gt 30 ]
then
	echo no storage found, nothing to do ...
else
#storage online !! go go go

if [ ! -e /tmp/package ]
then
 ln -s /usr/local/etc/package /tmp/package
fi

storage=`mount | grep ${mount_pattern} | tr -s " " | cut -d " " -f 3 | head -n 1`
echo "storage=$storage" > /usr/local/etc/storage

#remount RW
mount -o rw,remount $storage

storage="$storage/zapps"
echo "storage=$storage" > /usr/local/etc/storage

#check if overmount dirs present 
[ -d ${storage} ] || mkdir ${storage}
[ -d ${storage}/cb3pp ] || mkdir ${storage}/cb3pp
[ -d ${storage}/scripts ] || mkdir ${storage}/scripts
[ -d ${storage}/rss_ex ] || mkdir ${storage}/rss_ex
[ -d ${storage}/xVoD ] || mkdir ${storage}/xVoD
[ -d ${storage}/ewcp ] || mkdir ${storage}/ewcp
[ -d ${storage}/xLive ] || mkdir ${storage}/xLive

if [ ! -f /cb3pp/.overmounted ];then
    echo overmount start
    mount -o bind ${storage}/cb3pp /cb3pp
    touch /cb3pp/.overmounted
    echo overmount end
fi

if [ ! -f /xLive/.overmounted ];then
    echo overmount start
    mount -o bind ${storage}/xLive /xLive
    touch /xLive/.overmounted
    echo overmount end
fi


if [ ! -f /rss_ex/.overmounted ];then
    echo overmount start
    mount -o bind ${storage}/rss_ex /rss_ex
    touch /rss_ex/.overmounted
    echo overmount end
fi

if [ ! -f /xVoD/.overmounted ];then
    echo overmount start
    mount -o bind ${storage}/xVoD /xVoD
    touch /xVoD/.overmounted
    echo overmount end
fi


if [ ! -f /scripts/.overmounted ];then
    echo overmount start
    mount -o bind ${storage}/scripts /scripts
    touch /scripts/.overmounted
    echo overmount end
fi


if [ ! -f /ewcp/.overmounted ];then
    echo overmount start
    mount -o bind ${storage}/ewcp /ewcp
    touch /ewcp/.overmounted
    echo overmount end
fi

# check if .../cb3pp installed from us, if not, unpack
SERIAL=0
 [ -f ${storage}/cb3pp4-version.txt ] && . ${storage}/cb3pp4-version.txt
DISK_SERIAL=${SERIAL}
[ -f /cb3pp4-version.txt ] && . /cb3pp4-version.txt

if [ ${SERIAL} -gt ${DISK_SERIAL} ]
then
	rm -rf  ${storage}/cb3pp/*
	cd ${storage}
	unzip -o /cb3pp4.zip 
	cp /cb3pp4-version.txt ${storage}/

fi


# check if .../rss_ex from us, if not, unpack
SERIAL=0
 [ -f ${storage}/rss_ex4-version.txt ] && . ${storage}/rss_ex4-version.txt
DISK_SERIAL=${SERIAL}
[ -f /rss_ex4-version.txt ] && . /rss_ex4-version.txt

if [ ${SERIAL} -gt ${DISK_SERIAL} -o ! -f /rss_ex/rss/menuEx.rss ]
then
        rm -rf ${storage}/rss_ex/*
        cd ${storage}
        unzip -o /rss_ex4.zip
	cp /rss_ex4-version.txt ${storage}/rss_ex4-version.txt
fi

# check if .../xVoD from us, if not, unpack
SERIAL=0
 [ -f ${storage}/xVoD4-version.txt ] && . ${storage}/xVoD4-version.txt
DISK_SERIAL=${SERIAL}
[ -f /xVoD4-version.txt ] && . /xVoD4-version.txt

if [ ${SERIAL} -gt ${DISK_SERIAL} -o ! -f /xVoD/php/index.php ]
then
        rm -rf ${storage}/xVoD/*
        cd ${storage}
        unzip -o /xVoD4.zip
	cp /xVoD4-version.txt ${storage}/xVoD4-version.txt
fi


# check if .../scripts from us, if not, unpack
SERIAL=0
 [ -f ${storage}/scripts4-version.txt ] && . ${storage}/scripts4-version.txt
DISK_SERIAL=${SERIAL}
[ -f /scripts4-version.txt ] && . /scripts4-version.txt

if [ ${SERIAL} -gt ${DISK_SERIAL} -o ! -f /scripts/menu.rss ]
then
        rm -rf ${storage}/scripts/*
        cd ${storage}
        unzip -o /scripts4.zip
	cp /scripts4-version.txt ${storage}/scripts4-version.txt
fi



# check if .../xLive from us, if not, unpack
SERIAL=0
 [ -f ${storage}/xLive4-version.txt ] && . ${storage}/xLive4-version.txt
DISK_SERIAL=${SERIAL}
[ -f /xLive4-version.txt ] && . /xLive4-version.txt

if [ ${SERIAL} -gt ${DISK_SERIAL} -o ! -f /xLive/menu.rss ]
then
        rm -rf ${storage}/xLive/*
        cd ${storage}
        unzip -o /xLive4.zip
	cp /xLive4-version.txt ${storage}/xLive4-version.txt
fi



# check if .../ewcp installed from us, if not, unpack
SERIAL=0
 [ -f ${storage}/ewcp4-version.txt ] && . ${storage}/ewcp4-version.txt
DISK_SERIAL=${SERIAL}
[ -f /ewcp4-version.txt ] && . /ewcp4-version.txt

if [ ${SERIAL} -gt ${DISK_SERIAL} -o ${SERIAL} -eq 0 ]
then
        rm -rf ${storage}/ewcp/*
        cd  ${storage}
        unzip -o /ewcp4.zip
	cp /ewcp4-version.txt ${storage}/

fi

cb3pp_startup=/cb3pp/etc/init.d/rcS 

# standard startup
[ -f $cb3pp_startup ] && /bin/sh $cb3pp_startup $1

fi
#END CBA_CB3PP_STARTUP' > rccb3ppS
chmod +x rccb3ppS


#addind my startup to standard startup procedure
echo '
[ -f /usr/local/etc/rccb3ppS ] && sh /usr/local/etc/rccb3ppS start &' >> rcS



cat > rcK <<EOF
#!/bin/sh
[ -f /usr/local/etc/rccb3ppK ] && sh /usr/local/etc/rccb3ppK 
EOF

chmod +x rcK

cat > rccb3ppK <<EOF
#!/bin/sh

# standard stop
[ -f /cb3pp/etc/init.d/rcS ] && /bin/sh /cb3pp/etc/init.d/rcS stop
EOF

chmod +x rccb3ppK

cat > TZ <<EOF
export TZ=GMT-3
EOF


#packing back /usr/local/etc
rm ../usr.local.etc.tar.bz2
tar jcvf ../usr.local.etc.tar.bz2 *
cd ..
rm -rf unpacked_etc/

#packing the normal image

cd ..



if [ $USE_EBODA_INSTALL = "yes" ]
then
#copy eboda installer
    rm install_a
    cp ${SVN_REPO}/src/${SIMPLE_VERSION}/install/install_a_sdk3 install_a
fi

if [ $USE_M8_INSTALL = "yes" ]
then
#copy eboda installer
    rm install_a
    cp ${SVN_REPO}/src/${SIMPLE_VERSION}/install/install_a_sdk3_m install_a
fi


#patch size
sed -i -e 's#<sizeBytesMin>0x3000000</sizeBytesMin>#<sizeBytesMin>0x0800000</sizeBytesMin>#g' configuration.xml
sed -i -e 's#<sizeBytesMin>4194304</sizeBytesMin>#<sizeBytesMin>0x0800000</sizeBytesMin>#g' configuration.xml
sed -i -e 's#<sizeBytesMin>0x1000000</sizeBytesMin>#<sizeBytesMin>0x0800000</sizeBytesMin>#g' configuration.xml


#patch img name
sed -i -e 's#package2/squashfs1.upg#package2/squashfs1.img#g' configuration.xml  

mv ../${IMAGE_FILE} ../${IMAGE_FILE}.orig
tar cvf ../${IMAGE_FILE} *
cd ..
ls -l

}
