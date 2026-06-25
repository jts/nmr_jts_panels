library(optparse)
library(ggplot2)
library(stringr)
library(scales)
library(dplyr)

# data processing and transformation
add_ordinal <- function(df) {
  levels = c("gene", "ncRNA_gene", "pseudogene", "tRNA", "snRNA", "rRNA", "microRNA", "snoRNA")
  
  df[["ordinal"]] <-
    as.integer(factor(df[["feature"]], levels = levels, ordered = TRUE)) - 1L
  df
}

etl <- function(df) {
  df <- add_ordinal(df)
  df
}

transform_coordinates <- function(df) {
  df$y_start = y_start - (df$ordinal * (y_width + y_space))
  df$y_end = df$y_start + y_width
  df$x_start = 0
  df$x_end = df$count
  df
}

option_list <- list(
  make_option(c("-g", "--g"), type = "character", default = NULL,
              help = "Gene type count file", metavar = "FILE"),
  make_option(c("-o", "--output"), type = "character", default = "plot.pdf",
              help = "Output file path [default: %default]", metavar = "FILE"),
  make_option(c("-v", "--verbose"), action = "store_true", default = FALSE,
              help = "Print verbose output")
)

opt <- parse_args(OptionParser(option_list = option_list))

if (is.null(opt$g)) {
  stop("-g is required", call. = FALSE)
}

gene_counts <- etl(read.table(opt$g, header=TRUE))
y_width = 16
y_space = y_width / 2
y_start = nrow(gene_counts) * (y_width + y_space)

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
  

ggsave(opt$out, p, units="px", width=1500, height=750)
