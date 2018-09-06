FROM grafana/grafana:4.6.3
# https://hub.docker.com/r/grafana/grafana/tags/

COPY docker-entrypoint.sh /etc/grafana/docker-entrypoint.sh
RUN mkdir -p /import/
COPY datasources /import/datasources/
COPY dashboards /import/dashboards/

ENV GF_SECURITY_ADMIN_PASSWORD=admin \
    GF_SECURITY_ADMIN_USER=admin \
    DATASOURCES_PATH=/import/datasources/ \
    DASHBOARDS_PATH=/import/dashboards/

ENTRYPOINT ["/etc/grafana/docker-entrypoint.sh"]
