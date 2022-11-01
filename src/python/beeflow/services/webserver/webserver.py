from airflow.cli.cli_parser import get_parser
from beeflow.services.webserver.webserver_command import webserver

parser = get_parser()
empty_args = parser.parse_args(['webserver', '--worker-timeout', '300'])
webserver(empty_args)
