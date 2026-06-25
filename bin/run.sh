#! /bin/bash

DROPBOX=$1

echo "Building plots from data in ${DROPBOX}"

mkdir -p data
mkdir -p plots

if [ ! -f plots/fig1d.pdf ]; then
    echo "Building repeat panel"
    D=${DROPBOX}/Figure_Data/Figure1/Figure1D_AddedRepeats/
    # count basic repeat units from annotation, then append in segdups
    zcat < $D/mHetGla1.1.pri.repeat.bed.gz | python3 bin/count_repeats.py > data/mHetGla1.1.pri.repeat.tsv
    zcat < $D/mHetGla1.1.pri.biser.bedpe.gz | cut -f1-3 | bedtools sort | bedtools merge | awk '{ S+=($3 - $2) } END { printf "SegDup\t%.1f", S/1000000 }' >> data/mHetGla1.1.pri.repeat.tsv

    zcat < $D/mHetGlaV3.primary.sm.bed.gz  | python3 bin/count_repeats.py > data/mHetGlaV3.pri.repeat.tsv
    zcat < $D/mHetGlaV3.primary.pri.biser.bedpe.gz | cut -f1-3 | bedtools sort | bedtools merge | awk '{ S+=($3 - $2) } END { printf "SegDup\t%.1f", S/1000000 }' >> data/mHetGlaV3.pri.repeat.tsv

    Rscript bin/plot_fig_repeat.R -a data/mHetGlaV3.pri.repeat.tsv -b data/mHetGla1.1.pri.repeat.tsv -o plots/fig1d.pdf
fi

if [ ! -f plots/fig1e.pdf ]; then
    echo "Building gene panel"
    echo -e "feature\tcount" > data/mHetGla1.1.pri.gene_counts.tsv
    D=${DROPBOX}/Figure_Data/Figure1/Figure1E_annotations
    cat $D/mHetGla1pri_geneID_by_biotype.txt | cut -f2 | sort | uniq -c | awk '{ print $2 "\t" $1 }' | grep -v biotype >> data/mHetGla1.1.pri.gene_counts.tsv
    Rscript bin/plot_fig_genes.R -g data/mHetGla1.1.pri.gene_counts.tsv -o plots/fig1e.pdf
fi

if [ ! -f placeholder.pdf ]; then
    echo "Building ModDotPlots"
    # this requires https://github.com/jts/ModDotPlotMod installed
    D=$DROPBOX/Figure_Data/Figure2/Figure2A_StainGlass_Methyl_Cenpa/

    # add 100kb buffer around annotated centromere
    bedtools slop -b 100000 -i $D/mHetGla1.1.pri_centromere_v20260502.bed -g $D/mHetGla1.1.pri.cleaned.fa.gz.fai > data/mHetGla1.1.pri.centromeres_slop.bed

    # extract
    bedtools getfasta -fi $D/mHetGla1.1.pri.cleaned.fa.gz -bed data/mHetGla1.1.pri.centromeres_slop.bed > data/mHetGla1.1.pri.centromeres_slop.fa

    # make plots
    moddotplot static -f data/mHetGla1.1.pri.centromeres_slop.fa \
                      --cenpa-bw $D/Cenpa_vs_input.log2.utils.bw \
                      --bedmethyl $D/pup_5mC_merged.cleaned.bed \
                      -r 250 -o plots/moddotplot
fi
