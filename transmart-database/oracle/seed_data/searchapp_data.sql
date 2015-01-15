--------------------------------------------------------
--  File created - Tuesday-December-09-2014   
--------------------------------------------------------

Insert into SEARCHAPP.PLUGIN (PLUGIN_SEQ,NAME,PLUGIN_NAME,HAS_MODULES,HAS_FORM,DEFAULT_LINK,FORM_LINK,FORM_PAGE,ACTIVE) values (1,'R-Modules','R Modules','Y','N','/RModules/default',null,null,'Y');

Insert into SEARCHAPP.PLUGIN_MODULE (MODULE_SEQ,PLUGIN_SEQ,NAME,VERSION,ACTIVE,HAS_FORM,FORM_LINK,FORM_PAGE,MODULE_NAME,CATEGORY) values (31,1,'Scatter Plot with Linear Regression','.1','Y','N',null,'ScatterPlot','scatterPlot','DEFAULT');
Insert into SEARCHAPP.PLUGIN_MODULE (MODULE_SEQ,PLUGIN_SEQ,NAME,VERSION,ACTIVE,HAS_FORM,FORM_LINK,FORM_PAGE,MODULE_NAME,CATEGORY) values (66,1,'PCA','.1','Y','N',null,'PCA','pca','DEFAULT');
Insert into SEARCHAPP.PLUGIN_MODULE (MODULE_SEQ,PLUGIN_SEQ,NAME,VERSION,ACTIVE,HAS_FORM,FORM_LINK,FORM_PAGE,MODULE_NAME,CATEGORY) values (67,1,'Marker Selection','.1','Y','N',null,'MarkerSelection','markerSelection','DEFAULT');
Insert into SEARCHAPP.PLUGIN_MODULE (MODULE_SEQ,PLUGIN_SEQ,NAME,VERSION,ACTIVE,HAS_FORM,FORM_LINK,FORM_PAGE,MODULE_NAME,CATEGORY) values (21,1,'Line Graph','.1','Y','N',null,'LineGraph','lineGraph','DEFAULT');
Insert into SEARCHAPP.PLUGIN_MODULE (MODULE_SEQ,PLUGIN_SEQ,NAME,VERSION,ACTIVE,HAS_FORM,FORM_LINK,FORM_PAGE,MODULE_NAME,CATEGORY) values (22,1,'Correlation Analysis','.1','Y','N',null,'CorrelationAnalysis','correlationAnalysis','DEFAULT');
Insert into SEARCHAPP.PLUGIN_MODULE (MODULE_SEQ,PLUGIN_SEQ,NAME,VERSION,ACTIVE,HAS_FORM,FORM_LINK,FORM_PAGE,MODULE_NAME,CATEGORY) values (62,1,'Hierarchical Clustering','.1','Y','N',null,'HClust','hclust','DEFAULT');
Insert into SEARCHAPP.PLUGIN_MODULE (MODULE_SEQ,PLUGIN_SEQ,NAME,VERSION,ACTIVE,HAS_FORM,FORM_LINK,FORM_PAGE,MODULE_NAME,CATEGORY) values (33,1,'Heatmap','.1','Y','N',null,'Heatmap','heatmap','DEFAULT');
Insert into SEARCHAPP.PLUGIN_MODULE (MODULE_SEQ,PLUGIN_SEQ,NAME,VERSION,ACTIVE,HAS_FORM,FORM_LINK,FORM_PAGE,MODULE_NAME,CATEGORY) values (3,1,'Box Plot with ANOVA','.1','Y','N',null,'BoxPlot','boxPlot','DEFAULT');
Insert into SEARCHAPP.PLUGIN_MODULE (MODULE_SEQ,PLUGIN_SEQ,NAME,VERSION,ACTIVE,HAS_FORM,FORM_LINK,FORM_PAGE,MODULE_NAME,CATEGORY) values (1,1,'Survival Analysis','.1','Y','N',null,'SurvivalAnalysis','survivalAnalysis','DEFAULT');
Insert into SEARCHAPP.PLUGIN_MODULE (MODULE_SEQ,PLUGIN_SEQ,NAME,VERSION,ACTIVE,HAS_FORM,FORM_LINK,FORM_PAGE,MODULE_NAME,CATEGORY) values (32,1,'Table with Fisher Test','.1','Y','N',null,'TableWithFisher','tableWithFisher','DEFAULT');
Insert into SEARCHAPP.PLUGIN_MODULE (MODULE_SEQ,PLUGIN_SEQ,NAME,VERSION,ACTIVE,HAS_FORM,FORM_LINK,FORM_PAGE,MODULE_NAME,CATEGORY) values (61,1,'K-Means Clustering','.1','Y','N',null,'KClust','kclust','DEFAULT');

Insert into SEARCHAPP.SEARCH_AUTH_GROUP (ID,GROUP_CATEGORY) values (-1,'EVERYONE GROUP');


Insert into SEARCHAPP.SEARCH_AUTH_PRINCIPAL (ID,PRINCIPAL_TYPE,DATE_CREATED,DESCRIPTION,LAST_UPDATED,NAME,UNIQUE_ID,ENABLED) values (1,'USER',to_date('21-FEB-12','DD-MON-RR'),'system admin',to_date('21-FEB-12','DD-MON-RR'),'Sys Admin','admin',1);

Insert into SEARCHAPP.SEARCH_AUTH_USER (ID,EMAIL,EMAIL_SHOW,PASSWD,USER_REAL_NAME,USERNAME,LOGIN_ATTEMPT_COUNT,PASSWORD_EXPIRED) values (1,null,0,'dd9b2328682f9cb3eced4848150120a976158389','Sys Admin','admin',3,'N');

Insert into SEARCHAPP.SEARCH_CUSTOM_FILTER (SEARCH_CUSTOM_FILTER_ID,SEARCH_USER_ID,NAME,DESCRIPTION,PRIVATE) values (1987598,12345,'Parkinsonian D/o','J.B.','N');

Insert into SEARCHAPP.SEARCH_CUSTOM_FILTER_ITEM (SEARCH_CUSTOM_FILTER_ITEM_ID,SEARCH_CUSTOM_FILTER_ID,UNIQUE_ID,BIO_DATA_TYPE) values (1987599,1987598,'DIS:D020734','DISEASE');

Insert into SEARCHAPP.SEARCH_REQUEST_MAP (ID,VERSION,CONFIG_ATTRIBUTE,URL) values (1,0,'ROLE_ADMIN','/requestmap/**');
Insert into SEARCHAPP.SEARCH_REQUEST_MAP (ID,VERSION,CONFIG_ATTRIBUTE,URL) values (2,0,'ROLE_ADMIN','/role/**');
Insert into SEARCHAPP.SEARCH_REQUEST_MAP (ID,VERSION,CONFIG_ATTRIBUTE,URL) values (3,2,'ROLE_ADMIN','/authUser/**');
Insert into SEARCHAPP.SEARCH_REQUEST_MAP (ID,VERSION,CONFIG_ATTRIBUTE,URL) values (5,6,'IS_AUTHENTICATED_REMEMBERED','/**');
Insert into SEARCHAPP.SEARCH_REQUEST_MAP (ID,VERSION,CONFIG_ATTRIBUTE,URL) values (6,0,'IS_AUTHENTICATED_ANONYMOUSLY','/login/**');
Insert into SEARCHAPP.SEARCH_REQUEST_MAP (ID,VERSION,CONFIG_ATTRIBUTE,URL) values (7,0,'IS_AUTHENTICATED_ANONYMOUSLY','/css/**');
Insert into SEARCHAPP.SEARCH_REQUEST_MAP (ID,VERSION,CONFIG_ATTRIBUTE,URL) values (8,0,'IS_AUTHENTICATED_ANONYMOUSLY','/js/**');
Insert into SEARCHAPP.SEARCH_REQUEST_MAP (ID,VERSION,CONFIG_ATTRIBUTE,URL) values (9,0,'IS_AUTHENTICATED_ANONYMOUSLY','/images/**');
Insert into SEARCHAPP.SEARCH_REQUEST_MAP (ID,VERSION,CONFIG_ATTRIBUTE,URL) values (10,0,'IS_AUTHENTICATED_ANONYMOUSLY','/search/loadAJAX**');
Insert into SEARCHAPP.SEARCH_REQUEST_MAP (ID,VERSION,CONFIG_ATTRIBUTE,URL) values (1753960,0,'ROLE_ADMIN','/secureObject/**');
Insert into SEARCHAPP.SEARCH_REQUEST_MAP (ID,VERSION,CONFIG_ATTRIBUTE,URL) values (1753958,0,'ROLE_ADMIN','/accessLog/**');
Insert into SEARCHAPP.SEARCH_REQUEST_MAP (ID,VERSION,CONFIG_ATTRIBUTE,URL) values (1753959,0,'ROLE_ADMIN','/authUserSecureAccess/**');
Insert into SEARCHAPP.SEARCH_REQUEST_MAP (ID,VERSION,CONFIG_ATTRIBUTE,URL) values (1753961,0,'ROLE_ADMIN','/secureObjectPath/**');
Insert into SEARCHAPP.SEARCH_REQUEST_MAP (ID,VERSION,CONFIG_ATTRIBUTE,URL) values (11,0,'IS_AUTHENTICATED_ANONYMOUSLY','/analysis/getGenePatternFile');
Insert into SEARCHAPP.SEARCH_REQUEST_MAP (ID,VERSION,CONFIG_ATTRIBUTE,URL) values (12,0,'IS_AUTHENTICATED_ANONYMOUSLY','/analysis/getTestFile');
Insert into SEARCHAPP.SEARCH_REQUEST_MAP (ID,VERSION,CONFIG_ATTRIBUTE,URL) values (1837256,0,'ROLE_ADMIN','/userGroup/**');
Insert into SEARCHAPP.SEARCH_REQUEST_MAP (ID,VERSION,CONFIG_ATTRIBUTE,URL) values (1837257,0,'ROLE_ADMIN','/secureObjectAccess/**');

Insert into SEARCHAPP.SEARCH_ROLE (ID,VERSION,AUTHORITY,DESCRIPTION) values (4,59,'ROLE_ADMIN','admin user');
Insert into SEARCHAPP.SEARCH_ROLE (ID,VERSION,AUTHORITY,DESCRIPTION) values (5,108,'ROLE_STUDY_OWNER','study owner');
Insert into SEARCHAPP.SEARCH_ROLE (ID,VERSION,AUTHORITY,DESCRIPTION) values (6,311,'ROLE_SPECTATOR','spectator user');
Insert into SEARCHAPP.SEARCH_ROLE (ID,VERSION,AUTHORITY,DESCRIPTION) values (5027,66,'ROLE_DATASET_EXPLORER_ADMIN','dataset Explorer admin users - can view all trials');
Insert into SEARCHAPP.SEARCH_ROLE (ID,VERSION,AUTHORITY,DESCRIPTION) values (5071,102,'ROLE_PUBLIC_USER','public user');

Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (4,1);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5,2);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (6,3);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (4,701145587);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5071,701145587);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5027,701145587);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5071,3);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5027,701145587);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5027,12345);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (6,12345);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5,12345);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5071,103);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5,103);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (6,103);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5027,103);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5071,104);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5,104);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (6,104);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5027,104);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5071,105);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5,105);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (6,105);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5027,105);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5071,203);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (4,203);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5,203);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (6,203);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5027,203);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5071,204);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (4,204);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5,204);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (6,204);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5027,204);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5071,102);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5,102);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (6,102);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5027,102);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5071,201);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (4,201);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5,201);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (6,201);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5027,201);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5071,202);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (4,202);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5,202);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (6,202);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5027,202);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5071,205);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (4,205);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5,205);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (6,205);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5027,205);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5071,101);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5,101);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (6,101);
Insert into SEARCHAPP.SEARCH_ROLE_AUTH_USER (PEOPLE_ID,AUTHORITIES_ID) values (5027,101);

