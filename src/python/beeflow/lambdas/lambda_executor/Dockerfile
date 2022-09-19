FROM public.ecr.aws/lambda/python:3.9

RUN yum install unzip -y
COPY src.python.beeflow.lambdas.lambda_executor/package.zip .
RUN unzip package.zip -d ${LAMBDA_TASK_ROOT}

CMD ["lambdex_handler.handler"]
