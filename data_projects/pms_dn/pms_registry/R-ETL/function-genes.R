require("dplyr")

extractGenes<-function(patient)
{
  ##
  patient=2541
  ##
  
  data<-data_frame(Patient.ID=patient)
  
  genetics <- filter(Genetics,Patient.ID==patient)
  
  for (row in 1:nrow(genetics))
  {
    if (genetics$Result.type[row]=="mutation")
    {
      data[[genetics$Chr.Band.Gene[row]]]<-1
    }
    else if (genetics$Result.type[row]=="gene")
    {
      data[[genetics$Chr.Band.Gene[row]]]<-ifelse(genetics$Gain.Loss[row]=="Gain",3,1)
    }
    else if (genetics$Result.type[row]=="coordinates")
    {
      if (genetics$Genome.Browser.Build[row]=="GRCh37/hg19")
        genome<-hg19
      else if (genetics$Genome.Browser.Build[row]=="GRCh38/hg38")
        genome<-hg38
      else if (genetics$Genome.Browser.Build[row]=="NCBI35/hg17")
        genome<-hg17
      else if (genetics$Genome.Browser.Build[row]=="NCBI36/hg18")
        genome<-hg18
      else
        genome<-hg18
      
      if (genetics$Gain.Loss=="Loss")
      {
        unique(genome$name2[((genome$txEnd>genetics$Start[row] & genome$txEnd<genetics$End[row]) | (genome$txStart>genetics$Start[row] & genome$txStart<genetics$End[row])) & genome$chrom==paste0("chr",genetics$Chr.Band.Gene)])
      }
      else
      {
        unique(genome$name2[genome$txStart>genetics$Start[row] & genome$txEnd<genetics$End[row] & genome$chrom==paste0("chr",genetics$Chr.Band.Gene[row])])
      }
      
    }
  }
}