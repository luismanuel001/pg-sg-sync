FROM openjdk:8-jre-alpine

# Install base packages
RUN apk add --update unzip wget

# Install dockerize
RUN wget -O /tmp/dockerize-linux-amd64-v0.4.0.tar.gz https://github.com/jwilder/dockerize/releases/download/v0.4.0/dockerize-linux-amd64-v0.4.0.tar.gz \
 && tar -C /usr/local/bin -xzvf /tmp/dockerize-linux-amd64-v0.4.0.tar.gz

# Install elasticsearch-jdbc
RUN wget -O /tmp/elasticsearch-jdbc-2.3.4.1.zip  http://xbib.org/repository/org/xbib/elasticsearch/importer/elasticsearch-jdbc/2.3.4.1/elasticsearch-jdbc-2.3.4.1-dist.zip \
 && unzip -d /opt /tmp/elasticsearch-jdbc-2.3.4.1.zip \
 && ln -s /opt/elasticsearch-jdbc-2.3.4.1 /opt/elasticsearch-jdbc

# Get the jdbc driver for postgresql 9.4
RUN wget -O /opt/elasticsearch-jdbc-2.3.4.1/lib/postgresql-42.1.1.jar https://jdbc.postgresql.org//download/postgresql-42.1.1.jar

# Touch log file
RUN mkdir -p /opt/elasticsearch-jdbc/logs \
 && touch /opt/elasticsearch-jdbc/logs/jdbc.log

ADD config.json /

WORKDIR /opt/elasticsearch-jdbc

CMD dockerize \
    -template /config.json:/tmp/config.json \
    -stdout /opt/elasticsearch-jdbc/logs/jdbc.log \
    -stdout /statefile.json \
     java \
    -cp "/opt/elasticsearch-jdbc/lib/*" \
    -Dlog4j.configurationFile=/opt/elasticsearch-jdbc/bin/log4j2.xml \
    org.xbib.tools.Runner \
    org.xbib.tools.JDBCImporter \
    /tmp/config.json
