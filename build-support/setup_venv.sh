#!/usr/bin/env bash

PYTHON_BIN=python3
VIRTUALENV=build-support/.venv
PIP="${VIRTUALENV}/bin/pip"

"${PYTHON_BIN}" -m venv "${VIRTUALENV}"
"${PIP}" install pip --upgrade
"${PIP}" install -r ./3rdparty/python/requirements.txt
