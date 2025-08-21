FROM playaru/keycloak-russian:24.0.1.2

# Копируем кастомные провайдеры (если нужны)
COPY providers/ /opt/keycloak/providers/

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
