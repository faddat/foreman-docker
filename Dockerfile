FROM debian:latest
MAINTAINER Jacob Gadikian email: jake@klouds.org
WORKDIR /tmp

ENV FOREOPTS --enable-foreman-compute-ec2 \
 --enable-foreman-compute-libvirt \
 --enable-foreman-compute-vmware \
 --enable-foreman-compute-openstack \
 --enable-foreman-plugin-discovery \
 --enable-foreman-plugin-setup \
 --enable-foreman \
 --enable-puppet \
 --foreman-admin-password changeme 

RUN apt-get update && apt-get upgrade
RUN echo "deb http://deb.theforeman.org/ jessie 1.10" > /etc/apt/sources.list.d/foreman.list
RUN echo "deb http://deb.theforeman.org/ plugins 1.10" >> /etc/apt/sources.list.d/foreman.list
RUN wget -q http://deb.theforeman.org/pubkey.gpg -O- | apt-key add -
RUN apt-get update && apt-get -y install foreman-installer

RUN puppet apply -e 'host { $::hostname: ensure => absent } -> host { "${::hostname}.docker.local": ip => $::ipaddress, host_aliases => [$::hostname] }' \
 && cp /etc/foreman/foreman-installer-answers.yaml /tmp \
 && foreman-installer $FOREOPTS \
 && wget http://downloads.theforeman.org/discovery/releases/latest/fdi-image-latest.tar \
 -O - | tar x --overwrite -C /var/lib/tftpboot/boot \
 && chmod a+x /usr/bin/pipework \
 && mv /tmp/foreman-installer-answers.yaml /etc/foreman/foreman-installer-answers.yaml \
 && echo `hostname -f` >> /tmp/old_proxy_name

ADD pxe_global_default /tmp/
ADD startup /usr/bin/startup
ADD reconfigure_foreman /usr/bin/reconfigure_foreman
RUN chmod a+x /usr/bin/startup /usr/bin/reconfigure_foreman

EXPOSE 8140 8443 53 53/udp 67/udp 68/udp 69/udp 80 443 3000 3306 5432 8140 8443 5910 5911 5912 5913 5914 5915 5916 5917 5918 5919 5920 5921 5922 5923 5924 5925 5926 5927 5928 5929 5930

ENTRYPOINT [ "/usr/bin/startup" ]
