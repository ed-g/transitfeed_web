FROM centos

LABEL maintainer="Ed Groth <info@groth-geodata.com>"

RUN yum -y install epel-release
RUN yum -y update 

# for building SSL libraries
RUN yum -y install gcc libffi libffi-devel openssl-devel python-devel python-cffi

RUN yum -y install python-pip
RUN pip install --upgrade pip

# workaround https://github.com/google/transitfeed/issues/393 
RUN pip install transitfeed==1.2.15-blah 

# I hope that when transitfeed 1.2.16 is released, the newer version will be
# installed by this command.
RUN pip install --upgrade transitfeed

# Pick an user/group id which is unlikely to be used by the host system, to
# slightly enhance security.
RUN groupadd -g 10001    tfeedweb
RUN useradd  -u 10001 -g tfeedweb tfeedweb

RUN mkdir /home/tfeedweb/transitfeed_web/

COPY MANIFEST.in /home/tfeedweb/transitfeed_web/
COPY Dockerfile /home/tfeedweb/transitfeed_web/
COPY LICENSE /home/tfeedweb/transitfeed_web/
COPY transitfeed_web /home/tfeedweb/transitfeed_web/transitfeed_web
# COPY copy_of_transitfeed /home/tfeedweb/transitfeed_web/copy_of_transitfeed
COPY *.md /home/tfeedweb/transitfeed_web/
COPY *.py  /home/tfeedweb/transitfeed_web/
RUN chown -R tfeedweb:tfeedweb /home/tfeedweb

RUN pip install /home/tfeedweb/transitfeed_web

ENV HOME /home/tfeedweb

USER tfeedweb

EXPOSE 5000
ENTRYPOINT "transitfeed_web_server"
