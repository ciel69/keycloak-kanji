FROM quay.io/keycloak/keycloak:26.3.2

# Копируем кастомные провайдеры (если есть)
COPY providers/ /opt/keycloak/providers/

# Создаем пользователя (опционально)
# RUN keytool -importcert -file /opt/keycloak/certs/ca.crt -keystore /opt/keycloak/lib/quarkus/dist/lib/be/cacerts -storepass changeit -noprompt

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
