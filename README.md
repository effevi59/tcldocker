# tcldocker

Useful containers for tcl developers

rivet.dck is a docker file for creating a working tcl 8.6, batteries included, of a rivet container.

see https://tcl.apache.org/rivet/

generate your home instance of this container in this way

download rivet.dck on a new, empty directory, i.e. mydir

cd mydir

docker build . -f rivet.dck -t centos/rivet

docker run --name=myrivet --publish=8180:80 --detach --rm centos/rivet

curl http://127.0.0.1:8180/hello.rvt

curl http://127.0.0.1:8180/color-table.tcl

docker stop myrivet

/var/www/html is the apache server root and can be redirected at container level.

Everything is directly downloaded and compiled during the image creation.
