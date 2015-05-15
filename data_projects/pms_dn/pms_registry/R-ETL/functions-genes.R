require("dplyr")

liftOver <- function(genetics)
{
  # Create input bed files
  genetics <- add_rownames(genetics)
  genetics %>%
    filter(Genome.Browser.Build == "NCBI35/hg17") %>%
    select(Chr.Gene, Start, End, rowname) %>%
    mutate(Chr.Gene = paste0("chr", Chr.Gene)) -> bed17

  genetics %>%
    filter(Genome.Browser.Build == "NCBI36/hg18") %>%
    select(Chr.Gene, Start, End, rowname) %>%
    mutate(Chr.Gene = paste0("chr", Chr.Gene)) -> bed18

  genetics %>%
    filter(Genome.Browser.Build == "GRCh37/hg19") %>%
    select(Chr.Gene, Start, End, rowname) %>%
    mutate(Chr.Gene = paste0("chr", Chr.Gene)) -> bed19

  write.table(bed17, file = "bed17", sep = "\t", row.names = F, col.names = F, quote = F)
  write.table(bed18, file = "bed18", sep = "\t", row.names = F, col.names = F, quote = F)
  write.table(bed19, file = "bed19", sep = "\t", row.names = F, col.names = F, quote = F)

  # Run liftOver
  system("./liftOver bed17 hg17ToHg19.over.chain out17 unmap17 -multiple")
  system("./liftOver out17 hg19ToHg38.over.chain out17b unmap17b -multiple")
  system("./liftOver bed18 hg18ToHg38.over.chain out18 unmap18 -multiple")
  system("./liftOver bed19 hg19ToHg38.over.chain out19 unmap19 -multiple")

  out17 <- read.delim("out17b", header = F, stringsAsFactors = F)
  out18 <- read.delim("out18",  header = F, stringsAsFactors = F)
  out19 <- read.delim("out19",  header = F, stringsAsFactors = F)

  out17 <- filter(out17, V1 == paste0("chr",genetics$Chr.Gene[V4]))
  out18 <- filter(out18, V1 == paste0("chr",genetics$Chr.Gene[V4]))
  out19 <- filter(out19, V1 == paste0("chr",genetics$Chr.Gene[V4]))

  data <- matrix(ncol = 4, nrow = 0)
  for (pat in unique(out17$V4))
  {
    depth <- 0
    start <- 0
    end   <- 0

    pos <- sort(unlist(out17[out17$V4 == pat, 2:3]))
    for (posi in 1:length(pos))
    {
      if (grepl("^V2", names(pos[posi])))
      {
        depth <- depth + 1
        if (depth == 1)
          start <- pos[posi]
      }
      else
        depth <- depth - 1

      if (depth == 0)
      {
        end <- pos[posi]
        data <- rbind(data, c(pat, sub("chr", "", unique(out17$V1[out17$V4 == pat])), start, end))
      }
    }
  }

  for (pat in unique(out18$V4))
  {
    depth <- 0
    start <- 0
    end   <- 0

    pos <- sort(unlist(out18[out18$V4 == pat, 2:3]))
    for (posi in 1:length(pos))
    {
      if (grepl("^V2", names(pos[posi])))
      {
        depth <- depth + 1
        if (depth == 1)
          start <- pos[posi]
      }
      else
        depth <- depth - 1

      if (depth == 0)
      {
        end <- pos[posi]
        data <- rbind(data, c(pat, sub("chr", "", unique(out18$V1[out18$V4 == pat])), start, end))
      }
    }
  }

  for (pat in unique(out19$V4))
  {
    depth <- 0
    start <- 0
    end   <- 0

    pos <- sort(unlist(out19[out19$V4 == pat, 2:3]))
    for (posi in 1:length(pos))
    {
      if (grepl("^V2", names(pos[posi])))
      {
        depth <- depth + 1
        if (depth == 1)
          start <- pos[posi]
      }
      else
        depth <- depth - 1

      if (depth == 0)
      {
        end <- pos[posi]
        data <- rbind(data, c(pat, sub("chr", "", unique(out19$V1[out19$V4 == pat])), start, end))
      }
    }
  }
  data <- data.frame(data, stringsAsFactors = F)
  names(data) <- c("rowname", "Chr.Gene", "Start", "End")
  data$rowname <- as.numeric(data$rowname)
  data$Genome.Browser.Build <- "GRCh38/hg38"
  data$Result.type <- "coordinates"
  data$Gain.Loss <- genetics$Gain.Loss[data$rowname]
  data$Patient.ID <- genetics$Patient.ID[data$rowname]

  data <- select(data, rowname, Patient.ID, Genome.Browser.Build, Result.type, Gain.Loss, Chr.Gene, Start, End)

  genetics <- filter(genetics, !(rowname %in% data$rowname))
  genetics <- rbind(genetics, data)
  genetics <- arrange(genetics, rowname)

  unlink(c("bed*","out*","unmap*"))

  select(genetics, -rowname)
}

extractGenes <- function(genetics_pre, genetics_post)
{
  for (row in 1:nrow(genetics_pre))
  {
    patient <- genetics_pre$Patient.ID[row]
    chr.gene <- genetics_pre$Chr.Gene[row]

    if (genetics_pre$Result.type[row] == "mutation")
    {
      genetics_post[genetics_post$Patient.ID == patient, chr.gene] <- genetics_post[genetics_post$Patient.ID == patient, chr.gene] - 1
    }
    else if (genetics_pre$Result.type[row] == "gene")
    {
      if (genetics_pre$Gain.Loss[row] == "Gain")
        genetics_post[genetics_post$Patient.ID == patient, chr.gene] <- genetics_post[genetics_post$Patient.ID == patient, chr.gene] + 1
      else
        genetics_post[genetics_post$Patient.ID == patient, chr.gene] <- genetics_post[genetics_post$Patient.ID == patient, chr.gene] - 1
    }
    else if (genetics_pre$Result.type[row] == "coordinates")
    {
      if      (genetics_pre$Genome.Browser.Build[row] == "GRCh37/hg19")
        genome <- hg19
      else if (genetics_pre$Genome.Browser.Build[row] == "GRCh38/hg38")
        genome <- hg38
      else if (genetics_pre$Genome.Browser.Build[row] == "NCBI35/hg17")
        genome <- hg17
      else if (genetics_pre$Genome.Browser.Build[row] == "NCBI36/hg18")
        genome <- hg18
      else
        genome <- hg18

      if (genetics_pre$Gain.Loss[row] == "Loss")
      {
        genes <- unique(genome$name2[((genome$txEnd > genetics_pre$Start[row] & genome$txEnd < genetics_pre$End[row]) | (genome$txStart > genetics_pre$Start[row] & genome$txStart < genetics_pre$End[row])) & genome$chrom == paste0("chr", chr.gene)])
        genetics_post[genetics_post$Patient.ID == patient, genes] <- genetics_post[genetics_post$Patient.ID == patient, genes] - 1
      }
      else
      {
        genes <- unique(genome$name2[genome$txStart > genetics_pre$Start[row] & genome$txEnd < genetics_pre$End[row] & genome$chrom == paste0("chr", chr.gene)])
        genetics_post[genetics_post$Patient.ID == patient, genes] <- genetics_post[genetics_post$Patient.ID == patient, genes] + 1
      }

    }
  }

  genetics_post
}

getGeneNames <- function(genetics)
{
  genes <- data.frame(name = character(0), chrom = character(0))

  for (row in 1:nrow(genetics))
  {
    if (genetics$Result.type[row] == "mutation" | genetics$Result.type[row] == "gene")
      genes <- rbind(genes, data.frame(name = genetics$Chr.Gene[row], chrom = "", stringsAsFactors = F))
    else if (genetics$Result.type[row] == "coordinates")
    {
      if      (genetics$Genome.Browser.Build[row] == "GRCh37/hg19")
        genome <- hg19
      else if (genetics$Genome.Browser.Build[row] == "GRCh38/hg38")
        genome <- hg38
      else if (genetics$Genome.Browser.Build[row] == "NCBI35/hg17")
        genome <- hg17
      else if (genetics$Genome.Browser.Build[row] == "NCBI36/hg18")
        genome <- hg18
      else
        genome <- hg18

      if (genetics$Gain.Loss[row] == "Loss")
      {
        name <- genome$name2[((genome$txEnd > genetics$Start[row] & genome$txEnd < genetics$End[row]) | (genome$txStart > genetics$Start[row] & genome$txStart < genetics$End[row])) & genome$chrom == paste0("chr", genetics$Chr.Gene[row])]
        if (length(name) > 0)
          genes <- rbind(genes, data.frame(name, chrom = genetics$Chr.Gene[row], stringsAsFactors = F))
      }
      else
      {
        name <- genome$name2[genome$txStart > genetics$Start[row] & genome$txEnd < genetics$End[row] & genome$chrom == paste0("chr", genetics$Chr.Gene[row])]
        if (length(name) > 0)
          genes <- rbind(genes, data.frame(name, chrom = genetics$Chr.Gene[row], stringsAsFactors = F))
      }

    }
  }

  genes <- genes %>% arrange(name, chrom) %>% distinct
  genes$chrom[genes$chrom == ""] <- sub("chr", "", (hg38[hg38$name2 %in% genes$name[genes$chrom == ""], c("chrom","name2")] %>% arrange(name2, chrom) %>% distinct)$chrom)
  genes <- genes %>% arrange(name, chrom) %>% distinct

  genes
}

getPathways <- function(genes)
{
  kegg_genes <- read.delim("KEGG_genes.txt", header = F, stringsAsFactors = F)
  kegg_pathways <- read.delim("KEGG_pathways.txt", header = F, stringsAsFactors = F)
  kegg_links <- read.delim("KEGG_link_genes_pathways.txt", header = F, stringsAsFactors = F)

  df <- data.frame(genes)
  df$kegg_gene <- NA
  for (gene in genes)
  {
    kegg <- kegg_genes$V1[grep(paste0(gene,"[,;]|",gene,"$"), kegg_genes$V2)]
    df$kegg_gene[df$genes == gene] <- ifelse(length(kegg) > 0, kegg, NA)
  }

  df <- left_join(df, kegg_links[kegg_links$V1 %in% df$kegg_gene,], by = c("kegg_gene" = "V1"))
  df <- rename(df, kegg_pathway = V2)
  df <- left_join(df, kegg_pathways, by = c("kegg_pathway" = "V1"))
  df <- rename(df, pathway = V2)
  df$pathway <- sub(" - Homo sapiens \\(human\\)$","",df$pathway)

  df
}

downloadKEGGFiles <- function()
{
  system("wget -O KEGG_genes.txt http://rest.kegg.jp/list/hsa")
  system("wget -O KEGG_pathways.txt http://rest.kegg.jp/list/pathway/hsa")
  system("wget -O KEGG_link_genes_pathways.txt http://rest.kegg.jp/link/pathway/hsa")
}

downloadLiftOverFiles <- function()
{
  system("wget -O liftOver http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/liftOver")
  system("wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/liftOver/hg19ToHg38.over.chain.gz -O - | gunzip > hg19ToHg38.over.chain")
  system("wget http://hgdownload.soe.ucsc.edu/goldenPath/hg18/liftOver/hg18ToHg38.over.chain.gz -O - | gunzip > hg18ToHg38.over.chain")
  system("wget http://hgdownload.soe.ucsc.edu/goldenPath/hg17/liftOver/hg17ToHg19.over.chain.gz -O - | gunzip > hg17ToHg19.over.chain")
}

downloadRefGeneFiles <- function()
{
  system("wget http://hgdownload.soe.ucsc.edu/goldenPath/hg38/database/refGene.txt.gz -O - | gunzip > refGene.txt.hg38")
  system("wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/refGene.txt.gz -O - | gunzip > refGene.txt.hg19")
  system("wget http://hgdownload.soe.ucsc.edu/goldenPath/hg18/database/refGene.txt.gz -O - | gunzip > refGene.txt.hg18")
  system("wget http://hgdownload.soe.ucsc.edu/goldenPath/hg17/database/refGene.txt.gz -O - | gunzip > refGene.txt.hg17")
}