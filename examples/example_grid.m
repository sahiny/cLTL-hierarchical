%% example hierarchical
%% TS
function conW = example_grid(N, ha, hc, rb_threshold)
global tau mu_prime;
% ha = 7;
% hc = 30;
tau = 1;
% rb_threshold = 10;
% addpath(genpath('../'))
% solving for mu or mu'
mu_prime = 0;
grid1;

%% specs
% N = 4;
fb1 = strcat('GF(TP([',num2str(aTS.getAPIndex('r1')),'],[',num2str(N),']))');             %not too many robots in narrow passage way
fb2 = strcat('GF(TP([',num2str(aTS.getAPIndex('r2')),'],[',num2str(N/2),']))');             %not too many robots in narrow passage way
fb3 = strcat('GF(TP([',num2str(aTS.getAPIndex('r3')),'],[',num2str(N/2),']))');             %not too many robots in narrow passage way
if mu_prime
    fg1 = strcat('TP([',num2str(aTS.getAPIndex('g1')),'],[',num2str(1),'])');             %not too many robots in narrow passage way
    fg2 = strcat('TP([',num2str(aTS.getAPIndex('g2')),'],[',num2str(1),'])');             %not too many robots in narrow passage way
    fg = strcat('U(TP([', num2str(setdiff(1:length(aTS.APNames),aTS.getAPIndex('b3'))),'],[', num2str(N),']),And(',fg1,',',fg2,'))');
    f = strcat('And(',fb1,',',fb2,',',fb3,',', fg,')');
else
    f = strcat('And(',fb1,',',fb2,',',fb3,')');
end
%% Solve
% cW0 = zeros(1,size(A,1));
random_indices = randperm(length(initial_region));
cW0 = initial_region(random_indices(1:N));
aW0 = ones(1,N);
% conW = main_hierarchical_rollback(f,cTS,hc,cW0,aTS,ha,aW0,UB, rb_threshold);
conW = main_hierarchical_rollback(f,cTS,hc,cW0,aTS,ha,aW0,UB, rb_threshold);

1;
% save('Hierarchy_yasser')
