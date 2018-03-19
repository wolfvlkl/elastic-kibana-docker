FROM openjdk:jre-alpine

LABEL build=vlkl

ARG version

RUN apk add -q --no-progress --no-cache nodejs wget curl && \
    adduser -D elastic 

USER elastic 

WORKDIR /home/elastic 

ENV ES_TMPDIR=/home/elastic/elasticsearch.tmp 

RUN wget -q -O - https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${version}.tar.gz | tar -zx && \
    mv elasticsearch-${version} elasticsearch && \
    wget -q -O - https://artifacts.elastic.co/downloads/kibana/kibana-${version}-linux-x86_64.tar.gz | tar -zx && \
    mv kibana-${version}-linux-x86_64 kibana && \
    mkdir -p ${ES_TMPDIR} && \
    rm -f kibana/node/bin/node kibana/node/bin/npm && \
    ln -s $(which node) kibana/node/bin/node && \
    ln -s $(which npm) kibana/node/bin/npm && \
    sh elasticsearch/bin/elasticsearch-plugin install analysis-phonetic

CMD sh elasticsearch/bin/elasticsearch -E http.host=0.0.0.0 --quiet & kibana/bin/kibana --host 0.0.0.0 -Q 

EXPOSE 9200 9300 5601
