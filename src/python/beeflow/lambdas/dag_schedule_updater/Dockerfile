FROM public.ecr.aws/lambda/python:3.9

RUN yum install unzip -y
COPY src.python.beeflow.lambdas.dag_schedule_updater/package.zip .
RUN unzip package.zip -d .

# Workaround for PEX overriding attrs dependency globally
RUN rm -rf .bootstrap/pex/vendor/_vendored/attrs/attr && mkdir -p .bootstrap/pex/vendor/_vendored/attrs/attr
RUN cp -R .deps/attrs-22.2.0-py3-none-any.whl/attr .bootstrap/pex/vendor/_vendored/attrs

CMD ["lambdex_handler.handler"]
