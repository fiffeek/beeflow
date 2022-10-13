FROM apache/airflow:2.3.2-python3.9

ENTRYPOINT ["/bin/webserver"]

RUN pip install psycopg2-binary
RUN pip install apache-airflow[amazon]==2.3.2
RUN pip install apache-airflow[postgres]==2.3.2
RUN pip install apache-airflow[virtualenv]==2.3.2
RUN pip install cryptography==36.0.2

COPY src.python.beeflow.services.webserver/bin.pex /bin/webserver
