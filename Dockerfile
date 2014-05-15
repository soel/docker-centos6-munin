FROM centos

RUN yum install -y passwd
RUN yum install -y openssh
RUN yum install -y openssh-server
RUN yum install -y openssh-clients
RUN yum install -y sudo
RUN yum install -y wget
RUN yum install -y crontabs

## create user

#ADD ./authorized_keys
RUN echo 'password' | passwd --stdin root

## setup sudoers

## setup sshd and generate ssh-keys by init script
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config
RUN /etc/init.d/sshd start
RUN /etc/init.d/sshd stop

## setup crontab
RUN sed -i '/session    required   pam_loginuid.so/c\#session    required   pam_loginuid.so' /etc/pam.d/crond

#httpd
RUN yum -y install httpd

#supervisor
RUN wget http://peak.telecommunity.com/dist/ez_setup.py;python ez_setup.py;easy_install distribute;
RUN wget https://raw.github.com/pypa/pip/master/contrib/get-pip.py;python get-pip.py;
RUN pip install supervisor

ADD supervisord.conf /etc/supervisord.conf


#munin
RUN rpm -ivh http://ftp-srv2.kddilabs.jp/Linux/distributions/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN yum -y install munin munin-node munin-cgi
RUN htpasswd -cb /etc/munin/munin-htpasswd admin bbtower

## Seems we cannnot fix public port number
EXPOSE 22 80 4949
# EXPOSE 49222:22

#CMD ["/usr/sbin/sshd", "-D" ]
#CMD ["/usr/sbin/httpd", "-D" ]
CMD ["/usr/bin/supervisord"]

