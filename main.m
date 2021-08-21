clc, clear, close all;

% D�clarations
n = 168;                                                                   % 4032 heures = 6 mois
nvars = n*2;                                                                % nombre de variables
x0 = [230.*rand(n,1);180.*rand(n,1)];
lb = zeros(nvars,1);                                                        % matrice des contraintes min sur le d�bit des turbines
ub = [230.*ones(n,1);180.*ones(n,1)];                                       % matrice des contraintes max sur le d�bit des turbines

% Importations des donn�es
inputs = xlsread('inputs.xls');                                             % donn�es de prix et d'apports

% Contraintes techniques
a = inputs(1:n,2);                                                          % donn�es d'apports
x1max = 230;                                                                % d�bit max turbine 1 par seconde
x2max = 180;                                                                % d�bit max turbine 2 par seconde
vxpmax = [];
vpfwd = [];
h = [];

% Contraintes de prix
p = inputs(1:n,1);                                                          %p = 324.94.*rand(n,1);
pm = [p(1:n) ; p(1:n)];

% It�ration des contraintes de prix
for i=1:1:n
    if(i<(n-24))
        p24 = max(p(i:i+23));
        vpfwd = [vpfwd ; p24];
    end
    xpmax = (pm(i) * x1max + pm(i) * x2max);                                % fonction du prix, produit �conomique maximal par seconde
    vxpmax = [vxpmax ; xpmax];                                              % vecteur des produits economiques maximum fonction du prix
    h = [h ; i];                                                            % comptes des heures
end

% Cr�ation de la matrice des contraintes de prix
vp24 = p24*ones(25,1);                                                      % vecteur des prix
mpfwd = [vpfwd ; vp24];                                                     % matrice des prix
dmpfwd = diag(mpfwd);                                                       % diagonalisation de la matrice
smpfwd = [dmpfwd dmpfwd ; dmpfwd dmpfwd];                                   % cr�ation de la matrice carr�e
mMaxp = [vxpmax ; vxpmax];                                                  % matrice contraintes maximales
mConst = [smpfwd mMaxp];                                                    % matrice finale des contraintes

% Associations des contraintes prix et autres contraintes lin�aires
A = [];
b = [];
Aeq = mConst(:,[1:(nvars)]);                                                % valeurs de test�es
beq = mConst(:,[nvars+1]);                                                  % valeurs des contraintes

% Contraintes non lin�aires
nonlincon = [];

% Fonctions
objective = @(x) objective(x,p,a);                                         	% fonction de co�ts
options = optimoptions('ga','PlotFcns', @gaplotbestf);                      % options et graphs
[x,fval] = ga(objective,nvars,A,b,Aeq,beq,lb,ub, nonlincon, options);       % fonction de minimisation
[RecallResult, res, x1, x2, d1, d2, s1, s2,g, pe] = objective(x,p,a);      	% appel des valeurs de la fonction de co�ts

% Exportation des r�sultats en Excel
Prix = p;
Apports = a;
Heures = h;
Debit_1 = x1.';
Debit_2 = x2.';
Production_1 = d1.';
Production_2 = d2.';
Rendement_1 = s1.';
Rendement_2 = s2.';
Rendement_total = g.';
Reservoir = res;%.';
Produit_Economique = pe;
T = table(Heures,Apports,Reservoir,Debit_1,Debit_2,Production_1,Production_2,Rendement_1,Rendement_2,Rendement_total,Prix,Produit_Economique);
filename = 'Results Lucas Lassus - DSTI Spring 18.xlsx';
writetable(T,filename);
