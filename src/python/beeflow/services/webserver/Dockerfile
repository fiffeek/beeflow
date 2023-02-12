FROM python:3.9

WORKDIR /bin/webserver
COPY src.python.beeflow.services.webserver/bin.pex .

# Workaround for PEX overriding attrs dependency globally
RUN rm -rf .bootstrap/pex/vendor/_vendored/attrs/attr && mkdir -p .bootstrap/pex/vendor/_vendored/attrs/attr
RUN cp -R .deps/attrs-22.2.0-py3-none-any.whl/attr .bootstrap/pex/vendor/_vendored/attrs

WORKDIR /

ENTRYPOINT ["python", "/bin/webserver/__main__.py"]
