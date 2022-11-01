import logging
import signal
import subprocess
import sys
import textwrap
from contextlib import suppress

from airflow.cli.commands.webserver_command import GunicornMonitor
from airflow.configuration import conf
from airflow.utils.cli import setup_locations
from airflow.utils.process_utils import check_if_pidfile_process_is_running

log = logging.getLogger(__name__)


def webserver(args):
    access_logfile = args.access_logfile or conf.get('webserver', 'access_logfile')
    error_logfile = args.error_logfile or conf.get('webserver', 'error_logfile')
    access_logformat = args.access_logformat or conf.get('webserver', 'access_logformat')
    num_workers = 1
    worker_timeout = args.worker_timeout or conf.get('webserver', 'web_server_worker_timeout')
    ssl_cert = args.ssl_cert or conf.get('webserver', 'web_server_ssl_cert')
    ssl_key = args.ssl_key or conf.get('webserver', 'web_server_ssl_key')

    pid_file, stdout, stderr, log_file = setup_locations(
        "webserver", args.pid, args.stdout, args.stderr, args.log_file
    )

    # Check if webserver is already running if not, remove old pidfile
    check_if_pidfile_process_is_running(pid_file=pid_file, process_name="webserver")

    print(
        textwrap.dedent(
            f'''\
            Running the Gunicorn Server with:
            Workers: {num_workers} {args.workerclass}
            Host: {args.hostname}:{args.port}
            Timeout: {worker_timeout}
            Logfiles: {access_logfile} {error_logfile}
            Access Logformat: {access_logformat}
            ================================================================='''
        )
    )

    run_args = [
        sys.executable,
        '-m',
        'gunicorn',
        '--workers',
        str(num_workers),
        '--worker-class',
        str(args.workerclass),
        '--timeout',
        str(worker_timeout),
        '--bind',
        args.hostname + ':' + str(args.port),
        '--name',
        'airflow-webserver',
        '--pid',
        pid_file,
        '--config',
        'python:airflow.www.gunicorn_config',
    ]

    if args.access_logfile:
        run_args += ['--access-logfile', str(args.access_logfile)]

    if args.error_logfile:
        run_args += ['--error-logfile', str(args.error_logfile)]

    if args.access_logformat and args.access_logformat.strip():
        run_args += ['--access-logformat', str(args.access_logformat)]

    if args.daemon:
        run_args += ['--daemon']

    if ssl_cert:
        run_args += ['--certfile', ssl_cert, '--keyfile', ssl_key]

    run_args += ["airflow.www.app:cached_app()"]

    gunicorn_master_proc = None

    def kill_proc(signum, _):
        log.info("Received signal: %s. Closing gunicorn.", signum)
        gunicorn_master_proc.terminate()
        with suppress(TimeoutError):
            gunicorn_master_proc.wait(timeout=30)
        if gunicorn_master_proc.poll() is not None:
            gunicorn_master_proc.kill()
        sys.exit(0)

    def monitor_gunicorn(gunicorn_master_pid: int):
        # Register signal handlers
        signal.signal(signal.SIGINT, kill_proc)
        signal.signal(signal.SIGTERM, kill_proc)

        # These run forever until SIG{INT, TERM, KILL, ...} signal is sent
        GunicornMonitor(
            gunicorn_master_pid=gunicorn_master_pid,
            num_workers_expected=num_workers,
            master_timeout=conf.getint('webserver', 'web_server_master_timeout'),
            worker_refresh_interval=conf.getint('webserver', 'worker_refresh_interval', fallback=30),
            worker_refresh_batch_size=conf.getint('webserver', 'worker_refresh_batch_size', fallback=1),
            reload_on_plugin_change=conf.getboolean('webserver', 'reload_on_plugin_change', fallback=False),
        ).start()

    with subprocess.Popen(run_args, close_fds=True) as gunicorn_master_proc:
        monitor_gunicorn(gunicorn_master_proc.pid)
