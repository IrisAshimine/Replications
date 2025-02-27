/* 
Este código replica la Tabla 4.1 de Galí (2015, Capítulo 4) y evalúa la Regla de Taylor con 
expectativas ante choques de demanda y/o tecnología. La métrica utilizada para evaluar la regla 
de Taylor es L, definida como "pérdida de bienestar promedio". El código incluye 
simulaciones para choques tecnológicos, choques de demanda y ambos choques, generando 
histogramas de los valores de L para cada caso.
//////////////////////////////////////////////////////////

-Este trabajo utilizó como inspiración el codigo de Johannes Pfeifer Copyright (C) 2013-15
el cual está disponible en : https://github.com/JohannesPfeifer/DSGE_mod/blob/master/Gali_2008/Gali_2008_chapter_3.mod
-Así como las notas de Drago Bergholt extraídas de: https://bergholt.weebly.com/uploads/1/1/8/4/11843961/the_basic_new_keynesian_model_-_drago_bergholt.pdf
-Adicionalmente, se utilizó la función "get_simul_replication.m" Copyright (C) Johannes Pfeifer 2013-2023
*/

////////////////////////////////////////////////////////////////////////////////////////

// Variables
var y y_n y_tilda r r_n i pi z a n y_hat;

varexo epsilon_z epsilon_a;

//Parámetros
parameters rho_z rho_a beta eta theta epsilon sigma phi alpha phi_pi phi_y rho lambda THETA kappa psi_ya; 

//calibracion
rho_z = 0.5;
rho_a = 0.9;
beta = 0.99;
eta = 4;
theta = 3/4;
epsilon = 9;
sigma = 1;
alpha = 1/4;
phi_pi = 1.5;
phi_y = 0.5/4;
phi = 5;

//Auxiliares
rho = (1/beta)-1;
psi_ya = (phi +1)/(sigma*(1-alpha)+ phi + alpha);
THETA = (1-alpha)/(1-alpha + alpha*epsilon);
lambda = ((1-theta)*(1-beta*theta)/theta)*THETA;
kappa = lambda*(sigma + (phi + alpha)/(1-alpha));

//Modelo

model(linear);
pi= beta*pi(+1)+ kappa*y_tilda;
y_tilda = y_tilda(+1)- (1/sigma)*(i-pi(+1)-r_n);
r_n = rho +(1-rho_z)*z - sigma*psi_ya*a*(1-rho_a);
r = i-pi(+1);
y_n = psi_ya*a;
y_tilda = y -y_n;
y = a + (1-alpha)*n;
y_hat=y_n-steady_state(y);
//Procesos estocásticos 
z = rho_z* z(-1) + epsilon_z;
a = rho_a*a(-1)+ epsilon_a;

//REGLA DE TAYLOR (con expectativas)
i = rho +phi_pi*pi(+1) + phi_y *y_tilda(+1);
end;

// Definimos condiciones para los diferentes choques
@#define nonsimul  = 1    //Para replicar la tabla 4.1
@#define simultech = 0   //Simulaciones con choque tecnológico
@#define simuldem = 0   //Simulaciones con choque de demanda
@#define simulboth = 0 //Simulaciones con ambos choques


@#if simultech ==1
// SIMULACIÓN SÓLO CHOQUES TECNOLÓGICOS

shocks(overwrite);
var epsilon_a = 1;
var epsilon_z=0;
end;
stoch_simul(order=1, simul_replic=10000, nograph, periods=200, noprint);

results_sim = get_simul_replications(M_, options_);

y_t = strmatch('y_tilda', M_.endo_names, 'exact');
pi_t = strmatch('pi', M_.endo_names, 'exact');

variance = zeros(2, options_.simul_replic);

for i = 1:options_.simul_replic
    variance(1, i) = var(results_sim(y_t, :, i));
    variance(2, i) = var(results_sim(pi_t, :, i));
end;
//Calcular y guardar los valores de L
L_valuest = zeros(1, options_.simul_replic);

for i = 1:options_.simul_replic
    L_valuest(1, i) = 0.5 * ((M_.params(7, 1) + (M_.params(8, 1) + M_.params(9, 1)) / (1 - M_.params(9, 1))) * variance(1, i) + M_.params(6, 1) / M_.params(13, 1) * variance(2, i)) / 100;
end;

// Histograma
fig_histo1= figure;
histogram(L_valuest);
title('L ante choques de tecnología (regla con expectativas)');
xlabel('L');
ylabel('Frequencia');
exportgraphics(fig_histo1, 'histograma4.png', 'Resolution', 300);
@# endif

@#if simuldem ==1
// SIMULACIÓN SÓLO CHOQUES TECNOLÓGICOS

shocks(overwrite);
var epsilon_a = 0;
var epsilon_z=1;
end;
stoch_simul(order=1, simul_replic=10000, nograph, periods=200, noprint);

results_sim = get_simul_replications(M_, options_);

y_t = strmatch('y_tilda', M_.endo_names, 'exact');
pi_t = strmatch('pi', M_.endo_names, 'exact');

variance = zeros(2, options_.simul_replic);

for i = 1:options_.simul_replic
    variance(1, i) = var(results_sim(y_t, :, i));
    variance(2, i) = var(results_sim(pi_t, :, i));
end;

L_valuesd = zeros(1, options_.simul_replic);

for i = 1:options_.simul_replic
    L_valuesd(1, i) = 0.5 * ((M_.params(7, 1) + (M_.params(8, 1) + M_.params(9, 1)) / (1 - M_.params(9, 1))) * variance(1, i) + M_.params(6, 1) / M_.params(13, 1) * variance(2, i)) / 100;
end;
fig_histo2= figure;
histogram(L_valuesd);
title('L ante choques de demanda (regla con expectativas)');
xlabel('L');
ylabel('Frequencia');
exportgraphics(fig_histo2, 'histograma5.png', 'Resolution', 300);
@# endif 

@#if simulboth ==1
// SIMULACIÓN AMBOS CHOQUES

shocks(overwrite);
var epsilon_a = 1;
var epsilon_z=1;
end;
stoch_simul(order=1, simul_replic=10000, nograph, periods=200, noprint);

results_sim = get_simul_replications(M_, options_);

y_t = strmatch('y_tilda', M_.endo_names, 'exact');
pi_t = strmatch('pi', M_.endo_names, 'exact');

variance = zeros(2, options_.simul_replic);

for i = 1:options_.simul_replic
    variance(1, i) = var(results_sim(y_t, :, i));
    variance(2, i) = var(results_sim(pi_t, :, i));
end;

L_valuesb = zeros(1, options_.simul_replic);

for i = 1:options_.simul_replic
    L_valuesb(1, i) = 0.5 * ((M_.params(7, 1) + (M_.params(8, 1) + M_.params(9, 1)) / (1 - M_.params(9, 1))) * variance(1, i) + M_.params(6, 1) / M_.params(13, 1) * variance(2, i)) / 100;
end;
//PLOT
fig_histo3= figure;
histogram(L_valuesb);
title('L ante dos choques (regla con expectativas)');
xlabel('L');
ylabel('Frequencia');
exportgraphics(fig_histo3, 'histograma6.png', 'Resolution', 300);
@# endif


//REPLICAR TABLA 4.1 
@#if nonsimul == 1

//Choque de tecnología
shocks;
    var epsilon_a =1;
    var epsilon_z = 0;
end;

stoch_simul(order=1, irf=0, noprint) y y_tilda pi;

// Valor de los parámetros
phis_pi = [1.5 1.5 5 1.5];
phis_y = [0.125 0 0 1];

//Almacenar resultados
results_tech = zeros(4, length(phis_pi));
results_demand = zeros(4, length(phis_pi));

// Loop con cada combinación de parámetros
for j = 1:length(phis_pi)
    set_param_value('phi_pi', phis_pi(j));
    set_param_value('phi_y', phis_y(j));
    stoch_simul(order=1, irf=0, noprint);
    results_tech(1, j) = oo_.var(1, 1)^0.5; // Variance of y
    results_tech(2, j) = oo_.var(3, 3)^0.5; // Variance of y_tilda
    results_tech(3, j) = oo_.var(7, 7)^0.5; // Variance of pi
    results_tech(4, j) = 0.5 * ((M_.params(7, 1) + (M_.params(8, 1) + M_.params(9, 1)) / (1 - M_.params(9, 1))) * oo_.var(3, 3) + M_.params(6, 1) / M_.params(13, 1) * oo_.var(7, 7)) / 100; // Cálculo de L
end;
//Choque de demanda
shocks;
    var epsilon_a = 0;
    var epsilon_z = 1;
end;

stoch_simul(order=1, irf=0, noprint) y y_tilda pi;

// Loop con cada combinación de parámetros
for j = 1:length(phis_pi)
    set_param_value('phi_pi', phis_pi(j));
    set_param_value('phi_y', phis_y(j));
    stoch_simul(order=1, irf=0, noprint);
    results_demand(1, j) = oo_.var(1, 1)^0.5; // Variance of y
    results_demand(2, j) = oo_.var(3, 3)^0.5; // Variance of y_tilda
    results_demand(3, j) = oo_.var(7, 7)^0.5; // Variance of pi
    results_demand(4, j) = 0.5 * ((M_.params(7, 1) + (M_.params(8, 1) + M_.params(9, 1)) / (1 - M_.params(9, 1))) * oo_.var(3, 3) + M_.params(6, 1) / M_.params(13, 1) * oo_.var(7, 7)) / 100; // Cálculo de L
end;

// Imprimir resultados
fprintf('\n');
fprintf('----------------------------------------------------- \n');
fprintf('%-40s \n', "TABLA 4.1.1: Choque tecnológico*");
fprintf('----------------------------------------------------- \n');
fprintf('%-8s', 'phi_pi');
fprintf('%12.1f   ', phis_pi);
fprintf('\n%-8s', 'phi_y');
fprintf('%12.3f   ', phis_y);
fprintf('\n');

// Resultados de choque de tecnología
variable_names = {'y', 'y_tilda', 'pi', 'L'};
for i = 1:4
    fprintf('%-8s', variable_names{i});
    fprintf('%12.4f   ', results_tech(i, :));
    fprintf('\n');
end;

// Imprimir resultados
fprintf('\n');
fprintf('----------------------------------------------------- \n');
fprintf('%-40s \n', "TABLA 4.1.2: Choque de demanda*");
fprintf('----------------------------------------------------- \n');
fprintf('%-8s', 'phi_pi');
fprintf('%12.1f   ', phis_pi);
fprintf('\n%-8s', 'phi_y');
fprintf('%12.3f   ', phis_y);
fprintf('\n');

//  Resultados de choque de demanda
for i = 1:4
    fprintf('%-8s', variable_names{i});
    fprintf('%12.4f   ', results_demand(i, :));
    fprintf('\n');
end;

@# endif