FROM quay.io/keycloak/keycloak:26.3.2

# Копируем кастомные провайдеры (если нужны)
COPY providers/ /opt/keycloak/providers/

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
