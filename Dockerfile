FROM playaru/keycloak-russian:26.0.5 AS builder

# Копируем кастомные темы (если есть)
# COPY themes/ /opt/keycloak/themes/

# Копируем кастомные провайдеры
COPY providers/ /opt/keycloak/providers/

# Копируем realm-export для автоматического импорта
COPY realm-export.json /opt/keycloak/data/import/realm.json

# Оптимизируем для production
RUN /opt/keycloak/bin/kc.sh build --db=postgres

FROM playaru/keycloak-russian:26.0.5 AS runtime

COPY --from=builder /opt/keycloak/ /opt/keycloak/

WORKDIR /opt/keycloak

# Непривилегированный пользователь (уже есть в базовом образе)
USER 1000

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/health/ready || exit 1

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
