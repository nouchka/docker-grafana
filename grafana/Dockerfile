FROM grafana/grafana:latest
LABEL maintainer="Jean-Avit Promis docker@katagena.com"
# https://hub.docker.com/r/grafana/grafana/tags/

COPY docker-entrypoint.sh /etc/grafana/docker-entrypoint.sh
USER root
RUN mkdir -p /import/ && chown -R grafana: /import/
USER grafana
COPY datasources /import/datasources/
COPY dashboards /import/dashboards/
COPY users /import/users/

ENV GF_SECURITY_ADMIN_PASSWORD=admin \
    GF_SECURITY_ADMIN_USER=admin \
    DATASOURCES_PATH=/import/datasources/ \
    DASHBOARDS_PATH=/import/dashboards/ \
    USERS_PATH=/import/users/ \
    PLUGINS_LIST="raintank-worldping-app raintank-worldping-app"

ENTRYPOINT ["/etc/grafana/docker-entrypoint.sh"]
