ARG RASA_SDK_VERSION=3.5.1
FROM rasa/rasa-sdk:${RASA_SDK_VERSION}

WORKDIR /bot
COPY ./bot /bot

USER root
RUN pip install --upgrade pip && \
	pip install -r requirements.txt && \
	pip install -r actions/requirements.txt
USER 1001

ENTRYPOINT []

# CMD ["rasa", "run", "actions", "--debug"]
CMD ["python", "-m", "rasa_sdk", "-p", "5055"]

