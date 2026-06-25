library(dplyr)
library(stringr)
library(scales)

rootdir <- "/Users/jsimpson/incoming/mole_rat/t2t_qc/publication_figures/"
source(sprintf("%s/code/plot_common.R", rootdir))
       
transform_coordinates <- function(df) {
  df$y_start = y_start - (df$ordinal * (y_width + y_space))
  df$y_end = df$y_start + y_width
  df$x_start = 0
  df$x_end = df$count
  df
}

levels = c("gene", "ncRNA_gene", "pseudogene", "tRNA", "snRNA", "rRNA", "microRNA", "snoRNA")
gene_counts <- etl(read.table(sprintf("%s/data/mHetGla1.pri.gene_counts.tsv", rootdir), header=TRUE), "feature", levels)
y_width = 16
y_space = y_width / 2
y_start = nrow(delta) * (y_width + y_space)

gene_counts <- transform_coordinates(gene_counts)
x_label_pos = -4000

p <- ggplot() + 
      geom_rect(data = gene_counts, aes(xmin=x_start, xmax=x_end, ymin=y_end, ymax=y_start), color="black", linewidth = 0.5, fill="lightskyblue") +
      geom_text(data = gene_counts, x = x_label_pos, aes(y=(y_end - y_space), label=feature), size=3) +
      #geom_text(data = delta, aes(x = x, y=(y_end - y_space), label=difference), size=3) +
      coord_cartesian(xlim = c(x_label_pos - 2000, max(gene_counts$count))) + 
      theme_bw() + 
      xlab("Count") +
      theme(panel.grid = element_blank(),
            panel.border = element_blank(),
            axis.line = element_blank(),
            axis.ticks.y = element_blank(),
            axis.title.y = element_blank(),
            axis.text.y = element_blank()) +
        scale_x_continuous(labels = comma)
  

ggsave("/Users/jsimpson/incoming/mole_rat/t2t_qc/publication_figures/figures/fig_genes.pdf", p, units="px", width=1500, height=750)