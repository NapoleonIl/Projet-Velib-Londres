/*Chargement des jeu de données*/
data london_merged;
  infile '/home/u63775777/sasuser.v94/Projet/london_merged.txt' firstobs = 2 dlm = ',';
  input timestamp anydtdtm. cnt t1 t2 hum wind_speed weather_code is_holiday is_weekend season;
  format timestamp datetime19.;
run;

/*on trasforme la varibale timestamp en heure2*/
data london_merged2;
  set london_merged;
  heure = timepart(timestamp);
  heure2 = heure/3600;
run;

/*partie 2*/
proc univariate data = london_merged plots;
  /*weight;*/
  var cnt;
  histogram/normal /*/lognormal/weibull/gamma*/;
  qqplot; /* Afficher un diagramme de quantile-quantile */
run;


/* Calcul des statistiques pour chaque variable dans un jeu de données fourni*/
proc univariate data= london_merged noprint;
   var cnt t1 t2; /* Spécifiez toutes les variables pour lesquelles vous souhaitez calculer les statistiques */
   output out=statistique
          min=min
          max=max
          median=median
          q1=q1
          q3=q3
          mean=mean;
run; 

/*Affichage des résultats*/
proc print data=statistique;
   var min max mean median q1 q3;
run;


/* Vérification du nombre d'observations dans une variable avec PROC FREQ */
proc freq data = london_merged2;
  table cnt; /*remplace cnt par d'autre variable*/
run;


/*pour avoir la matrice de corrélation*/
proc corr data = london_merged2; 
  var cnt ;
  with timestamp t1 t2 hum wind_speed weather_code is_holiday is_weekend season heure2;
run;

/*les nuages de points*/
proc sort data = london_merged2;
  by is_weekend;
run;

proc sort data = london_merged2;
  by is_holiday;
run;

proc gplot data = london_merged;  
by is_weekend;
  plot cnt * hum; 
run; quit;

proc gplot data = london_merged;  
by is_holiday;
  plot cnt * hum; 
run; quit;

proc gplot data = london_merged;  
by is_weekend;
  plot cnt * t1; 
run; quit;

proc gplot data = london_merged;  
by is_holiday;
  plot cnt * t1; 
run; quit;


/*les 3 modèle de regression linéaire*/
proc reg data = london_merged;
  model cnt = hum;
run;

proc reg data = london_merged;
  model cnt = t1;
run;

proc reg data = london_merged2;
  model cnt = heure2;
run;



/*modèle de régression linéaire multiple */
proc reg data=london_merged2;
   model cnt =  t1 hum is_holiday season is_weekend heure2;
run;
quit;

proc reg data = london_merged;
  model cnt = timestamp t1 t2 hum wind_speed weather_code is_holiday is_weekend season /method = backward;
run;

proc reg data = london_merged;
  model cnt = timestamp t1 t2 hum wind_speed weather_code is_holiday is_weekend season /method = forward;
run;

proc reg data = london_merged2;
  model cnt = timestamp t1 t2 hum wind_speed weather_code is_holiday is_weekend season heure2/method = stepwise;
run;


/*glm select sans croisement*/
proc GLMselect data = london_merged2 plots(stepaxis = normb) = coefficients;
  class weather_code is_holiday is_weekend season heure2;/*les variables discrete*/
  model cnt = t1 hum weather_code is_weekend is_holiday heure2/selection = lasso(stop = none);
run;


/*on peut passer au logarithme*/
/* Création d'une nouvelle variable avec la transformation logarithmique */
/*
data london_merged2;
   set london_merged;
   log_hum = log(hum);
run;
*/

