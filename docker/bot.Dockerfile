ARG RASA_VERSION=3.5.15
FROM rasa/rasa:${RASA_VERSION}-full

WORKDIR /bot
COPY ./bot /bot

USER root
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt
USER 1001

ENTRYPOINT []
CMD []

