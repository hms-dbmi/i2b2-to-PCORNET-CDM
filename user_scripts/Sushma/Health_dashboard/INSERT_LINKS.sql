create or replace PROCEDURE         INSERT_LINKS AS 
BEGIN
insert into biomart.web_links values('PubMed','http://www.ncbi.nlm.nih.gov/pubmed/?term=',biomart.web_id.NEXTVAL);
insert into biomart.web_links values('EMBASE','http://www.elsevier.com/s/search.html?profile=_default&form=sitesearch&collection=elsevier-meta&query=',biomart.web_id.NEXTVAL);
insert into biomart.web_links values('COCHRANE','http://onlinelibrary.wiley.com/cochranelibrary/search?searchRow.searchCriteria.term=',biomart.web_id.NEXTVAL);
insert into biomart.web_links values('Wikipedia','https://en.wikipedia.org/wiki/',biomart.web_id.NEXTVAL);
insert into biomart.web_links values('NORD''s','https://www.rarediseases.org/rare-disease-information/rare-diseases/viewSearchResults?term=',biomart.web_id.NEXTVAL);
insert into biomart.web_links values('GeneCards','http://www.genecards.org/cgi-bin/carddisp.pl?gene=',biomart.web_id.NEXTVAL);
insert into biomart.web_links values('OMIM','http://omim.org/search?index=entry&start=1&limit=10&search=',biomart.web_id.NEXTVAL);
insert into biomart.web_links values('Ensembl project','http://grch37.ensembl.org/Human/Search/Results?q=',biomart.web_id.NEXTVAL);
insert into biomart.web_links values('GTEx project','http://www.gtexportal.org/home/gene/',biomart.web_id.NEXTVAL);
insert into biomart.web_links values('WikiGenes','http://www.wikigenes.org/?search=',biomart.web_id.NEXTVAL);
insert into biomart.web_links values('GTR','http://www.ncbi.nlm.nih.gov/gtr/genes/?term=',biomart.web_id.NEXTVAL);
insert into biomart.web_links values('ClinVar','http://www.ncbi.nlm.nih.gov/clinvar?term=',biomart.web_id.NEXTVAL);
insert into biomart.web_links values('GeneTests','https://www.genetests.org/search/disorders.php?search=',biomart.web_id.NEXTVAL);
insert into biomart.web_links values('ClinicalTrials.gov','https://clinicaltrials.gov/ct2/results?term=',biomart.web_id.NEXTVAL);
insert into biomart.web_links values('Food & Drug Administration','http://google2.fda.gov/search?q=',biomart.web_id.NEXTVAL);
insert into biomart.web_links values('European Medicines Agency','http://www.ema.europa.eu/ema/index.jsp?curl=pages%2Fincludes%2Fmedicines%2Fmedicines_landing_page.jsp&searchkwByEnter=true&quickSearch=',biomart.web_id.NEXTVAL);
insert into biomart.web_links values('UCSC','http://genome.ucsc.edu/cgi-bin/hgTracks?db=hg19&position=',biomart.web_id.NEXTVAL);
insert into biomart.web_links values('WHO','http://search.who.int/search?q=',biomart.web_id.NEXTVAL);
insert into biomart.web_links values('ExAC-Gene','http://exac.broadinstitute.org/gene/',biomart.web_id.NEXTVAL);
insert into biomart.web_links values('ExAC-Transcript','http://exac.broadinstitute.org/transcript/',biomart.web_id.NEXTVAL);
insert into biomart.web_links values('ExAC-Variant','http://exac.broadinstitute.org/variant/',biomart.web_id.NEXTVAL);
insert into biomart.web_links values('ExAC Multi-allelic Variant','http://exac.broadinstitute.org/dbsnp/',biomart.web_id.NEXTVAL);
insert into biomart.web_links values('ExAC-Region','http://exac.broadinstitute.org/region/',biomart.web_id.NEXTVAL);
insert into biomart.web_links values('EMBASE','http://www.elsevier.com/s/search.html?profile=_default&form=sitesearch&collection=elsevier-meta&query=',biomart.web_id.NEXTVAL);
insert into biomart.web_links values('NCBI','http://www.ncbi.nlm.nih.gov/gquery/?term=',biomart.web_id.NEXTVAL);
commit;
  NULL;
END INSERT_LINKS;