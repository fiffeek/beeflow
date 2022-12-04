import argparse
import logging

from beeflow.experiments.internal.infrastructure.app.runner import ExperimentRunner
from beeflow.experiments.internal.infrastructure.config.config import ExperimentConfiguration

parser = argparse.ArgumentParser(
    prog='ExperimentRunner',
    description='Runs experiments for metrics collection on beeflow and other Airflow deployments',
)
parser.add_argument(
    '-p', '--config_path', type=str, help="Path to the experiment configuration file (json)", required=True
)
args = parser.parse_args()


def run(config_path: str) -> None:
    logging.basicConfig(
        encoding='utf-8',
        level=logging.INFO,
        format='[%(asctime)s] [%(filename)s:%(lineno)d]: %(message)s',
        datefmt='%m/%d/%Y %I:%M:%S %p',
    )
    config = ExperimentConfiguration(config_path=config_path).config
    app = ExperimentRunner(config=config)
    app.run()


if __name__ == "__main__":
    run(args.config_path)
