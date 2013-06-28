#!/bin/sh

FILE=`dirname $0`;
FOLDER=`cd ${FILE}/; pwd`;
mkdir -p "${HOME}/.lyx/layouts/";
rm "${HOME}/.lyx/layouts/csm-thesis.layout" 2> /dev/null;
cp "${FOLDER}/csm-thesis.layout" "${HOME}/.lyx/layouts/";
