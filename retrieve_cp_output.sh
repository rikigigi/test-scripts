#!/bin/bash
set -e
FOLDER=$1
PREFIX=$2
NR=51
shift 2
if (( "$#" ))
then
    echo NR=$1
    NR=$1
fi

for f in ${FOLDER}/${PREFIX}*
do
    if [ -d "$f" ]
    then
	    echo SKIPPING DIRECTORY "$f"
	    continue
    fi
    cp "$f" "aiida.${f##*.}" -v
done
cp "${FOLDER}/${PREFIX}_${NR}.save/data-file-schema.xml" . -v
if [ -e "${FOLDER}/${PREFIX}_${NR}.save/print_counter" ]
then	
cp "${FOLDER}/${PREFIX}_${NR}.save/print_counter" . -v
fi

if [ -e "${FOLDER}/${PREFIX}_${NR}.save/print_counter.xml" ]
then
cp "${FOLDER}/${PREFIX}_${NR}.save/print_counter.xml" . -v
fi


cp "${FOLDER}/../aiida.out" . -v
