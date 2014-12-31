#!/bin/bash 

echo -e "Filename\tCategory Code\tColumn Number\tData Label\tData Label Source\tControlled Vocab Cd" > matrix
#cd Simon_VIP_DATA
#cd Simon_VIP_DATA_s

#cd data2
cd smallAC

ls | {
while read file;
do
#echo "##########"
echo $file
head -1 $file | 
awk '
{ 
    for (i=1; i<=NF; i++)  {
        a[NR,i] = $i
    }
}
NF>p { p = NF }
END {    
    for(j=1; j<=p; j++) {
        str=a[1,j]
        for(i=2; i<=NR; i++){
            str=str" "a[i,j];

        }
         
        print str
    }
}' > ../tmp

 sed s/'\.'/'+'/g ../tmp >../tmp2
 

rownum=1;
cat ../tmp2 | { while read file2;
do 
###  Filename  ###
echo -e "$file\t" | tr -d '\n' >> ../matrix 

C1=$(echo $file2  | cut  -f1 -s   -d'+' | tr -d '\n' )
C2=$(echo $file2  | cut  -f2 -s   -d'+' | tr -d '\n' )
C3=$(echo $file2  | cut  -f3 -s   -d'+' | tr -d '\n')
C4=$(echo $file2  | cut  -f4 -s   -d'+' | tr -d '\n')

CL=$(echo -e  $file2 | awk -F+ '{print $NF}' | tr -d '\n')




###  Category Code  ###
echo    $file  | cut  -f1 -s  -d'.' | tr -d '\n' >> ../matrix
echo  "+"  | tr -d '\n' >> ../matrix
echo    $file2  | cut  -f1 -s  -d'+' | tr -d '\n' >> ../matrix

# NIVEAU 2
if test "$CL" != "$C2" 
then
echo  "+"  | tr -d '\n' >> ../matrix
echo   $file2 | cut  -f2 -s  -d'+'  | tr -d '\n'>> ../matrix
fi  

# NIVEAU 3
if test "$CL" != "$C3" 
then
echo  "+"  | tr -d '\n' >> ../matrix
echo   $file2 | cut  -f3 -s  -d'+'  | tr -d '\n'>> ../matrix
fi

# NIVEAU 4
if test "$CL" != "$C4" 
then
echo  "+"  | tr -d '\n' >> ../matrix
echo   $file2 | cut  -f4 -s  -d'+'  | tr -d '\n'>> ../matrix
fi



###  Column Number  ###
echo -e "\t $rownum \t"  | tr -d '\n'>> ../matrix

###  Data Label  ###
echo -e  $file2 | awk -F+ '{print $NF}' | tr -d '\n'>> ../matrix

###  Data Label Source  ###
echo -e "\t" | tr -d '\n'>> ../matrix

###  Controlled Vocab Cd ###
echo -e "\t">> ../matrix

rownum=$(( $rownum + 1 ))

done
}

done
}
cd .. ;

sed -E    "s/(\+	|\+\+	|\+\+\+	|\+\+\+\+	)/	/g; s/(Proband_ID|individual)/SUBJ_ID/g; s/Proband_Sex/SEX/g; s/(family|Collection|Family_Type|Proband_DOB|Proband_GUID|Sibling_ID|Sibling_DOB|Sibling_Sex|Sibling_GUID|Mother_ID|Mother_DOB|Mother_GUID|Father_ID|Father_DOB|Father_GUID)/OMIT/g;" matrix > AC_columns.csv;
cat AC_columns.csv;