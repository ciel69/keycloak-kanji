FROM playaru/keycloak-russian:26.5.0.1

# Копируем кастомные провайдеры (если нужны)
COPY providers/ /opt/keycloak/providers/

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
