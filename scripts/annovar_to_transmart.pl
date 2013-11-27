#!/usr/bin/perl

use ConceptDimension;
use PatientDimension;

use UUID::Generator::PurePerl;
$ug = UUID::Generator::PurePerl->new();

###########################################
#This directory should house the individuals genomic variant files.
my $inputDataDirectory 				= "/Users/mmcduffie/Documents/HMS/tranSMART Exome/data/source/";
my $patient_dimension_output_file	= "/Users/mmcduffie/Documents/HMS/tranSMART Exome/data/i2b2_load_tables/patient_dimension";
my $patient_dimension_columns		= "";

#Open the directory with annotated genomic files.
opendir(D, $inputDataDirectory) || die "Can't opedir: $!\n";
open patient_dimension, ">$patient_dimension_output_file";

print patient_dimension PatientDimension->printColumnHeaders();

while (my $f = readdir(D)) 
{
     if($f =~ m/(.*)\.annovar$/)
     {
     	my $currentID = $1;
     	$uuid1 = $ug->generate_v1();
     
		$patientDimension = new PatientDimension("","","","","","","","","",$uuid1,"","","","",$currentID,"","","","");
		print patient_dimension $patientDimension->toTableFileLine();     	
     
     }
}
closedir(D);
close(patient_dimension);
###########################################

###########################################
my $variant_field_mapping_file 		= "/Users/mmcduffie/Documents/HMS/tranSMART Exome/mapping_files/variant_field_mapping";
my $concept_dimension_output_file 	= "/Users/mmcduffie/Documents/HMS/tranSMART Exome/data/i2b2_load_tables/concept_dimension";

#When building the concept dimension entries we need to utilize the mapping files.
#The first mapping file maps the columns in the annovar file to the tranSMART hierarchy.

#Open the mapping file.
open variant_field_mapping, "<$variant_field_mapping_file";

#Open the file we output the concept_dimension rows to.
open concept_dimension, ">$concept_dimension_output_file";

print concept_dimension ConceptDimension->printColumnHeaders();

while ($line = readline variant_field_mapping)
{
	#Clean Input line.
	chomp($line);
	
	if($line =~ m/^([^\t]+)\t([^\t]+)/)
	{
		#Use the concept path from here.
		my $currentConcept = $2;
		
		#Create a new concept code identifier.
		$uuid1 = $ug->generate_v1();
	
		#Create the concept object.
		$conceptDimension = new ConceptDimension("","",$uuid1,$currentConcept,"","","","","");
	
		#Write the entry for the concept_dimension table.
		print concept_dimension $conceptDimension->toTableFileLine();
	}
}

close(variant_field_mapping);	
close(concept_dimension);
###########################################

###########################################


###########################################

