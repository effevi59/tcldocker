set -x
# update image
yum -y update
yum -y install httpd httpd-devel openssl-devel gcc make unzip autoconf
# get rivet
mkdir /rivet && cd /rivet
curl -o rivet.taz http://mirror.nohup.it/apache/tcl/rivet/rivet-current.tar.gz
tar -xf rivet.taz && rm -f rivet.taz
mv `ls` source
# get tcl
curl -o tcl.taz http://core.tcl.tk/tcl/tarball/release/tcl.tar.gz
tar -xf tcl.taz && rm -f tcl.taz
# build tcl
cd /rivet/tcl/unix && sh configure --prefix=/opt/tcl86 && make install
echo /opt/tcl86/lib > /etc/ld.so.conf.d/tcl-x86_64.conf && ldconfig
# build rivet
cd /rivet/source && sh configure --with-tcl=/opt/tcl86/lib && make install
cp /rivet/source/doc/examples/hello.rvt /var/www/html/.
cp /rivet/source/doc/examples/color-table.tcl /var/www/html/.
# get extensions
cd /rivet/tcl && curl -o tdom.taz https://core.tcl.tk/tdom/tarball/86c70df47c/tDOM-86c70df47c.tar.gz && tar -xf tdom.taz && cd tDOM-86c70df47c
sh configure --with-tcl=/opt/tcl86/lib && make install
cd /rivet/tcl && curl -o tls.taz https://core.tcl.tk/tcltls/uv/tcltls-1.7.16.tar.gz && tar -xf tls.taz && cd tcltls-1.7.16
sh configure --with-tcl=/opt/tcl86/lib && make install
cd /rivet/tcl && curl -o tcllib.taz https://core.tcl.tk/tcllib/uv/tcllib-1.19.tar.gz && tar -xf tcllib.taz && cd tcllib-1.19
sh configure --prefix=/opt/tcl86 && make install
yum -y install https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7-x86_64/pgdg-centos10-10-2.noarch.rpm
yum -y install postgresql10 postgresql10-devel
export PG_CONFIG=/usr/pgsql-10/bin/pg_config
cd /rivet && curl -Lo pgtclng.taz https://sourceforge.net/projects/pgtclng/files/pgtclng/2.1.1/pgtcl2.1.1.tar.gz/download
tar -xf pgtclng.taz && cd pgtcl2.1.1
sh configure --with-tcl=/opt/tcl86/lib --mandir=/opt/tcl86/man --docdir /opt/tcl86/doc --with-postgres-lib=/usr/pgsql-10/lib --with-postgres-include=/usr/pgsql-10/include && make install
cd /rivet && curl -Lo pgtcl.taz https://github.com/flightaware/Pgtcl/archive/v2.3.4.tar.gz
tar -xf pgtcl.taz && cd Pgtcl-2.3.4
autoreconf
sh configure --with-tcl=/opt/tcl86/lib --mandir=/opt/tcl86/man
make install
cd /rivet
curl -o sqlite.taz https://www.sqlite.org/2018/sqlite-autoconf-3240000.tar.gz
tar -xf sqlite.taz
cd sqlite-autoconf-3240000/tea
sh configure --with-tcl=/opt/tcl86/lib
make install
# httpd conf
cat <<EOF > /etc/httpd/conf.d/rivet.conf
ServerName rivet.rivet.com
LoadModule rivet_module modules/mod_rivet.so
AddType application/x-httpd-rivet rvt
AddType application/x-rivet-tcl tcl
EOF
# startup
cat <<EOF > /startup.sh
exec httpd -DFOREGROUND
EOF
chmod 500 /startup.sh
