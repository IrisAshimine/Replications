/*
 * Este archivo replica los modelos estudiados en:
 * Schmitt-Grohé, Stephanie y Uribe, Martín (2003): "Closing small open economy 
 * models", Journal of International Economics, 61, pp. 163-185.
 * Proporciona el código de replicación para los resultados principales del artículo original para los Modelos 1 a 4.
 * Este trabajo fue inspirado y utiliza parte del código escrito por Johannes Pfeifer, el cual se puede encontrar en:
 https://github.com/JohannesPfeifer/DSGE_mod/blob/master/SGU_2003/SGU_2003.mod
*/
//Factor de descuento endógeno
@#define modelo1 =0
//Tasa de interés de deunda elástica
@#define modelo2 =1
// Costo de ajuste de portafolio
@#define modelo3 =0 
// Mercados completos
@#define modelo4 =0 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
@#if modelo1==1
//Modelo 1 (1a)
//Variables
var c h k y a i r d beta eta lambda tb ca;
varexo e;

//Parámetros
parameters alpha delta psi gamma omega phi rho sigmae r_ss;

//Calibración 
gamma = 2;
omega = 1.455;
psi = 0.111349843; //Calibración exacta
alpha = 0.32;
phi = 0.028;
r_ss = 0.04;
delta = 0.1;
rho = 0.42;
sigmae = 0.0129;

model;
//PRODUCCIÓN
exp(y) = exp(a)*(exp(k(-1))^alpha)*(exp(h)^(1-alpha));
//LEY DE MOVIMIENTO DEL CAPITAL
exp(k) = exp(i)+(1-delta)*exp(k(-1)); 
//LAMBDA
exp(lambda)=(exp(c)-((exp(h)^omega)/omega))^(-gamma)-eta*(-psi*(1+exp(c)-omega^(-1)*exp(h)^omega)^(-psi-1));
//EULER
exp(lambda)= beta*(1+exp(r))*exp(lambda(+1));
eta=-((((exp(c)-omega^(-1)*exp(h)^omega)^(1-gamma))-1)/(1-gamma))+eta(+1)*beta(+1); 
//CPO TRABAJO
((exp(c)-(exp(h)^omega)/omega)^(-gamma))*(exp(h)^(omega-1)) + 
 eta*(-psi*(1+exp(c)-omega^(-1)*exp(h)^omega)^(-psi-1)*(-exp(h)^(omega-1))) =
 exp(lambda)*(1-alpha)*exp(a)*exp(k(-1))^(alpha)*exp(h)^(-alpha); 
//CPO INVERSIÓN
exp(lambda)*(1+phi*(exp(k)-exp(k(-1)))) =
 beta*exp(lambda(+1))*(exp(a(+1))*alpha*exp(k)^(alpha-1)*exp(h(+1))^(1-alpha)+1-delta+phi*(exp(k(+1))-exp(k)));
//PROCESO SHOCK ESTOCÁSTICO
a = rho*a(-1)+ e; 
//TASA DE INTERÉS
exp(r)=r_ss ;
//DEUDA
d = (1+exp(r(-1)))*d(-1)- exp(y)+exp(c)+exp(i)+(phi/2)*(exp(k)-exp(k(-1)))^2;

//OTRAS VARIABLES DE INTERÉS
// Balanza comercial 
tb = 1-((exp(c)+exp(i)+(phi/2)*(exp(k)-exp(k(-1)))^2)/exp(y));
// Ratio cuenta corriente/output
ca = (1/exp(y))*(d(-1)-d);
//FACTOR DE DESCUENTO ENDÓGENO
beta = (1+exp(c)-omega^(-1)*exp(h)^(omega))^(-psi);
end;
shocks;
var e = sigmae^2;
end;

//Estado estacionario
initval;
r = log(r_ss);
h = log(((1-alpha)*(alpha/(r_ss+delta))^(alpha/(1-alpha)))^(1/(omega-1)));
k = log(exp(h)/(((r_ss+delta)/alpha)^(1/(1-alpha))));
y = log((exp(k)^alpha)*(exp(h)^(1-alpha)));
i = log(delta*exp(k));
c = log(exp(y)-exp(i)-r_ss*d);
tb = 1-((exp(c)+exp(i))/exp(y));
beta =(1+exp(c)-omega^(-1)*exp(h)^omega)^(-psi);
eta=-((((exp(c)-omega^(-1)*exp(h)^omega)^(1-gamma))-1)/(1-gamma))/(1-beta);
lambda=log((exp(c)-((exp(h)^omega)/omega))^(-gamma)-eta*(-psi*(1+exp(c)-omega^(-1)*exp(h)^omega)^(-psi-1)));
a = 0;
ca = 0;
end;

steady;

@#endif
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
@#if modelo2==1
//Model 2
//Variables
var c h k y a i r d lambda tb ca pr;
varexo e;
//Parámetros

parameters alpha delta psi beta gamma omega phi rho sigmae r_ss d_ex;

//Calibración 

gamma = 2;
omega = 1.455;
beta = 0.9615;
psi = 0.000742;
alpha = 0.32;
phi = 0.028;
r_ss = 0.04;
delta = 0.1;
rho = 0.42;
sigmae = 0.0129;
d_ex= 0.7442;

model;
//Tasa de interés
exp(r) = r_ss + pr;
// Prima por país
pr = psi*(exp(d-d_ex)-1);
//Deuda
d = (1+exp(r(-1)))*d(-1)- exp(y)+exp(c)+exp(i)+(phi/2)*(exp(k)-exp(k(-1)))^2; //no necesito exp(d)
exp(y) = exp(a)*(exp(k(-1))^alpha)*(exp(h)^(1-alpha)); //Producción
exp(k) = exp(i)+(1-delta)*exp(k(-1)); //Ley de movimiento del capital
//Euler
exp(lambda)= beta*(1+exp(r))*exp(lambda(+1)); 
//utilidad marginal 
(exp(c)-((exp(h)^omega)/omega))^(-gamma) = exp(lambda); 
//Trabajo
((exp(c)-((exp(h)^omega)/omega))^(-gamma))*(exp(h)^(omega-1)) = 
exp(lambda)*(1-alpha)*exp(a)*exp(k(-1))^(alpha)*exp(h)^(-alpha); 
//capital
exp(lambda)*(1+phi*(exp(k)-exp(k(-1)))) = beta*exp(lambda(+1))*(alpha*exp(y(+1))/exp(k)+1-delta+phi*(exp(k(+1))-exp(k)));
//Shock de productividad
a = rho*a(-1)+ e;
tb = 1-((exp(c)+exp(i)+(phi/2)*(exp(k)-exp(k(-1)))^2)/exp(y));
ca = (1/exp(y))*(d(-1)-d);
end;
shocks;
var e = sigmae^2;
end;

initval;
d = d_ex ;
pr = 0;
a = 0;
ca = 0;
r = log((1-beta)/beta);
h = log(((1-alpha)*(alpha/(r_ss+delta))^(alpha/(1-alpha)))^(1/(omega-1)));
k = log(exp(h)/(((r_ss+delta)/alpha)^(1/(1-alpha))));
y = log((exp(k)^alpha)*(exp(h)^(1-alpha)));
i = log(delta*exp(k));
c = log(exp(y)-exp(i)-r_ss*d);
tb = 1-((exp(c)+exp(i))/exp(y));
lambda= log((exp(c)-((exp(h)^omega)/omega))^(-gamma));
end; 
steady;
@#endif
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
@#if modelo3==1
//Modelo 3
//Variables
var c h k y a i r d lambda tb ca ;
varexo e;

//Parámetros
parameters alpha delta psi beta gamma omega phi rho sigmae r_ss d_ex;

//Calibración 
gamma = 2;
omega = 1.455;
alpha = 0.32;
phi = 0.028; 
r_ss = 0.04;
delta = 0.1;
rho = 0.42;
sigmae = 0.0129;

beta = 0.9615;
d_ex= 0.7442; 
psi = 0.00074; //costo de ajuste de portafolio

model;
//Tasa de interés
exp(r) = r_ss;
//Evolución de la deuda (con costos de ajuste)
d = (1+ exp(r(-1)))*d(-1)- exp(y) + exp(c) + exp(i)+ (phi/2)*(exp(k)-exp(k(-1)))^2+(psi/2)*(d-d_ex)^2;
//Producción
exp(y) = exp(a)*(exp(k(-1))^alpha)*(exp(h)^(1-alpha));
//Ley de movimiento del capital
exp(k) = exp(i)+(1-delta)*exp(k(-1)); //Ley de movimiento del capital
//Euler
exp(lambda)*(1-psi*(d-d_ex))= beta*(1+exp(r))*exp(lambda(+1)); 
//Utilidad marginal (lambda)
(exp(c)-((exp(h)^omega)/omega))^(-gamma) = exp(lambda); 
//Trabajo
((exp(c)-((exp(h)^omega)/omega))^(-gamma))*(exp(h)^(omega-1)) = 
exp(lambda)*(1-alpha)*exp(a)*exp(k(-1))^(alpha)*exp(h)^(-alpha); 
//Inversión
exp(lambda)*(1+phi*(exp(k)-exp(k(-1)))) = beta*exp(lambda(+1))*(alpha*exp(y(+1))/exp(k)+1-delta+phi*(exp(k(+1))-exp(k)));
//Shock de productividad
a = rho*a(-1)+ e;
//Balanza comercial
tb = 1-((exp(c)+exp(i)+(phi/2)*(exp(k)-exp(k(-1)))^2)/exp(y));
//Cuenta corriente
ca = (1/exp(y))*(d(-1)-d);
end;
shocks;
var e = sigmae^2;
end;

initval;
d = d_ex ;
a = 0;
ca = 0;
tb = 1-((exp(c)+exp(i))/exp(y));
r = r_ss;
h = log(((1-alpha)*(alpha/(r_ss+delta))^(alpha/(1-alpha)))^(1/(omega-1)));
k = log(exp(h)/(((r_ss+delta)/alpha)^(1/(1-alpha))));
y = log((exp(k)^alpha)*(exp(h)^(1-alpha)));
i = log(delta*exp(k));
c = log(exp(y)-exp(i)-r_ss*d);
lambda= log((exp(c)-((exp(h)^omega)/omega))^(-gamma));
end; 
steady;
@#endif
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
@#if modelo4==1
//Modelo 4
//Variables
var c h k y a i lambda tb;
varexo e;

//Parámetros
parameters alpha delta beta gamma omega psi phi rho sigmae r_ss;

//Calibración 
gamma = 2;
omega = 1.455;
alpha = 0.32;
phi = 0.028; 
r_ss = 0.04;
delta = 0.1;
rho = 0.42;
sigmae = 0.0129;
psi = 5.60909; 
beta = 0.9615; 
model;
//Euler 
exp(lambda)= psi;
//Producción
exp(y) = exp(a)*(exp(k(-1))^alpha)*(exp(h)^(1-alpha));
//Ley de movimiento del capital
exp(k) = exp(i)+(1-delta)*exp(k(-1));
//Utilidad marginal (lambda)
exp(lambda) = (exp(c)-((exp(h)^omega)/omega))^(-gamma); 
//Trabajo
((exp(c)-((exp(h)^omega)/omega))^(-gamma))*(exp(h)^(omega-1)) = exp(lambda)*(1-alpha)*exp(a)*exp(k(-1))^(alpha)*exp(h)^(-alpha); 
//Inversión
exp(lambda)*(1+phi*(exp(k)-exp(k(-1)))) = beta*exp(lambda(+1))*(alpha*exp(y(+1))/exp(k)+1-delta+phi*(exp(k(+1))-exp(k)));
//Shock de productividad
a = rho*a(-1)+ e;
//Balanza comercial
tb = 1-((exp(c)+exp(i)+(phi/2)*(exp(k)-exp(k(-1)))^2)/exp(y));
end;

shocks;
var e = sigmae^2;
end;

initval;
a = 0;
tb = 1-((exp(c)+exp(i))/exp(y));
h = log(((1-alpha)*(alpha/(r_ss+delta))^(alpha/(1-alpha)))^(1/(omega-1)));
k = log(exp(h)/(((r_ss+delta)/alpha)^(1/(1-alpha))));
y = log((exp(k)^alpha)*(exp(h)^(1-alpha)));
i = log(delta*exp(k));
c = 0.110602;
lambda= log((exp(c)-((exp(h)^omega)/omega))^(-gamma));
end; 
steady;
@#endif


// Simulación
stoch_simul(irf=0, nograph, order =1 ,simul_replic = 10000, noprint);

///////////////////////////////////////////////////////////////////////////
// RESULTADOS DE LA TABLA 3 POR MODELO
fprintf('\n');
fprintf('----------------------------------------------------- \n');
fprintf('%-40s \n', "TABLA 3: Std. dev y correlación (por modelo) ");
fprintf('----------------------------------------------------- \n');

//Colocamos nombres de variables para poder extraer sus resultados
y_r = strmatch('y', M_.endo_names, 'exact');
c_r = strmatch('c', M_.endo_names, 'exact');
i_r = strmatch('i', M_.endo_names, 'exact');
h_r = strmatch('h', M_.endo_names, 'exact');
tb_r = strmatch('tb', M_.endo_names, 'exact');
ca_r = strmatch('ca', M_.endo_names, 'exact');

% Initialize the table with NaNs
table = NaN(6, 3);

% Fill in the standard deviations
table(1, 1) = sqrt(oo_.var(y_r, y_r)) * 100;
table(2, 1) = sqrt(oo_.var(c_r, c_r)) * 100;
table(3, 1) = sqrt(oo_.var(i_r, i_r)) * 100;
table(4, 1) = sqrt(oo_.var(h_r, h_r)) * 100;
table(5, 1) = sqrt(oo_.var(tb_r, tb_r)) * 100;
if ~isempty(ca_r)
    table(6, 1) = sqrt(oo_.var(ca_r, ca_r)) * 100;
end

% Fill in the serial correlations
table(1, 2) = oo_.autocorr{1}(y_r, y_r);
table(2, 2) = oo_.autocorr{1}(c_r, c_r);
table(3, 2) = oo_.autocorr{1}(i_r, i_r);
table(4, 2) = oo_.autocorr{1}(h_r, h_r);
table(5, 2) = oo_.autocorr{1}(tb_r, tb_r);
if ~isempty(ca_r)
    table(6, 2) = oo_.autocorr{1}(ca_r, ca_r);
end

% Fill in the correlations with output
table(1, 3) = 1; % corr(y_t, y_t) is always 1
table(2, 3) = oo_.gamma_y{1}(c_r, y_r) / sqrt(oo_.var(c_r, c_r) * oo_.var(y_r, y_r));
table(3, 3) = oo_.gamma_y{1}(i_r, y_r) / sqrt(oo_.var(i_r, i_r) * oo_.var(y_r, y_r));
table(4, 3) = oo_.gamma_y{1}(h_r, y_r) / sqrt(oo_.var(h_r, h_r) * oo_.var(y_r, y_r));
table(5, 3) = oo_.gamma_y{1}(tb_r, y_r) / sqrt(oo_.var(tb_r, tb_r) * oo_.var(y_r, y_r));
if ~isempty(ca_r)
    table(6, 3) = oo_.gamma_y{1}(ca_r, y_r) / sqrt(oo_.var(ca_r, ca_r) * oo_.var(y_r, y_r));
end

% Print the table
fprintf('Variable \t Std Dev\t Auto Corr \tCorr con y\n');
fprintf('-----------------------------------------------------------\n');
variable_names = {' y', ' c', ' i', ' h', ' tb/y', ' ca/y'};
for i = 1:6
    if i == 6 && isempty(ca_r)
        fprintf('%s \t   \t   NaN   \t  \t NaN  \t   \t     NaN \n', variable_names{i});
    else
        fprintf('%s  \t  \t  %2.1f  \t  \t %3.2f \t \t  %3.2f\n', variable_names{i}, table(i, 1), table(i, 2), table(i, 3));
    end 
end

