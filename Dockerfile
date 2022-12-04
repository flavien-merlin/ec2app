# --- Builder --- #
FROM python:3.8-slim as builder

WORKDIR /app
COPY app.py pylint.cfg ./
WORKDIR /wheels
COPY requierements.txt ./
# RUN pip wheel -r requierements.txt

# --- Lint --- #
FROM eeacms/pylint:latest as linting

WORKDIR /code
COPY --from=builder /app/pylint.cfg /etc/pylint.cfg
COPY --from=builder /app/*.py ./
RUN ["/docker-entrypoint.sh", "pylint"]

# --- Sonarqube must have sonarqube server running --- #
FROM newtmitch/sonar-scanner as sonarqube

WORKDIR /usr/src
COPY ./sonar-runner.properties /usr/lib/sonar-scanner/conf/sonar-scanner.properties
COPY --from=builder /app/*.py ./
RUN sonar-scanner -Dsonar.projectBaseDir=/usr/src


# --- Serve -- #
FROM python:3.8-slim as serve

ARG USER=flav
RUN useradd -ms /bin/bash ${USER}
USER ${USER}

WORKDIR /home/${USER}
COPY config credentials ./
RUN mkdir /home/${USER}/.aws && \
    mv config /home/${USER}/.aws && \
    mv credentials /home/${USER}/.aws

COPY --from=builder /wheels /wheels
RUN pip install -r /wheels/requierements.txt -f /wheels
COPY --from=builder /app/*.py ./

CMD ["python3" , "app.py"]
