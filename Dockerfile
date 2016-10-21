# Modified from https://github.com/rootfs/nfs-ganesha-docker by Huamin Chen
FROM fedora:24

RUN dnf install -y tar gcc git cmake autoconf libtool bison flex make gcc-c++ krb5-devel dbus-devel rpcbind nfs-utils && dnf clean all \
	&& git clone --recursive https://github.com/nfs-ganesha/nfs-ganesha.git /nfs-ganesha \
	&& cd /nfs-ganesha \
	&& git reset --hard 0f55a9a97a4bf232fb0e42542e4ca7491fbf84ce \
	&& cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_CONFIG=vfs_only -D_NO_PORTMAPPER=ON src/ \
	&& make \
	&& make install \
	&& dnf remove -y tar gcc git cmake autoconf libtool bison flex make gcc-c++ krb5-devel dbus-devel && dnf clean all

RUN mkdir -p /exports

# expose mountd 20048/tcp and nfsd 2049/tcp and rpcbind 111/tcp 111/udp
EXPOSE 2049/tcp 20048/tcp 111/tcp 111/udp

COPY index.html /tmp/index.html
RUN chmod 644 /tmp/index.html
COPY run_nfs.sh /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/run_nfs.sh"]
CMD ["/exports"]
