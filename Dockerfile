FROM mysql:5.7

COPY config/mysql/docker.cnf /etc/mysql/conf.d/docker.cnf

ENV MYSQL_ROOT_PASSWORD=root

#VOLUME /var/lib/mysql

COPY script.sh /usr/local/bin/script.sh
RUN chmod +x /usr/local/bin/script.sh
EXPOSE 33061
ENTRYPOINT ["script.sh"]