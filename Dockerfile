FROM playaru/keycloak-russian:26.5.0.1 AS builder

# Копируем кастомные темы (если есть)
# COPY themes/ /opt/keycloak/themes/

# Копируем кастомные провайдеры
COPY providers/ /opt/keycloak/providers/

# Копируем realm-export для автоматического импорта
COPY realm-export.json /opt/keycloak/data/import/realm.json

# Оптимизируем для production
RUN /opt/keycloak/bin/kc.sh build --db=postgres

FROM playaru/keycloak-russian:26.5.0.1 AS runtime

COPY --from=builder /opt/keycloak/ /opt/keycloak/

WORKDIR /opt/keycloak

# Непривилегированный пользователь (уже есть в базовом образе)
USER 1000

EXPOSE 8080

HEALTHCHECK --interval=3s --timeout=5s --start-period=10s --retries=15 \
    CMD bash -c 'exec 3<>/dev/tcp/localhost/9000 && printf "GET /health/ready HTTP/1.1\r\nHost: localhost\r\nConnection: close\r\n\r\n" >&3 && head -1 <&3 | grep -q "200"'

LABEL service="kanji-flow-keycloak"

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
