#! /bin/bash

DROPBOX=$1

echo "Building plots from data in ${DROPBOX}"

echo "Building repeat panel"

mkdir -p data
mkdir -p plots

if [ ! -f plots/fig1d.pdf ]; then
    D=${DROPBOX}/Figure_Data/Figure1/Figure1D_AddedRepeats/
    # count basic repeat units from annotation, then append in segdups
    zcat < $D/mHetGla1.1.pri.repeat.bed.gz | python3 bin/count_repeats.py > data/mHetGla1.1.pri.repeat.tsv
    zcat < $D/mHetGla1.1.pri.biser.bedpe.gz | cut -f1-3 | bedtools sort | bedtools merge | awk '{ S+=($3 - $2) } END { printf "SegDup\t%.1f", S/1000000 }' >> data/mHetGla1.1.pri.repeat.tsv

    zcat < $D/mHetGlaV3.primary.sm.bed.gz  | python3 bin/count_repeats.py > data/mHetGlaV3.pri.repeat.tsv
    zcat < $D/mHetGlaV3.primary.pri.biser.bedpe.gz | cut -f1-3 | bedtools sort | bedtools merge | awk '{ S+=($3 - $2) } END { printf "SegDup\t%.1f", S/1000000 }' >> data/mHetGlaV3.pri.repeat.tsv

    Rscript bin/plot_fig_repeat.R -a data/mHetGlaV3.pri.repeat.tsv -b data/mHetGla1.1.pri.repeat.tsv -o plots/fig1d.pdf
fi
