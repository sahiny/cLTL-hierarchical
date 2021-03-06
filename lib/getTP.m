function [fTP,phi] = getTP(formula, args, k)

global W Wtotal Z bigM epsilon;

if length(args) ~= 2
    disp('Missing argument');
    asset(length(args)==2);
end

% number of agents
N = length(W);
% time horizon
h = size(W{1},2)-1-tau;

[fTP, z] = getLTL(args{1},k);
phi = getZ(formula,h,1);
phi = phi(k);
if args{2} == N
    fTP = [fTP, sum(z) >= args{2} - bigM*(1-phi)];
    fTP = [fTP, sum(z) <= args{2}  + bigM*phi-1];
else
    fTP = [fTP, sum(z) >= args{2} + epsilon - bigM*(1-phi)];
    fTP = [fTP, sum(z) <= args{2} + epsilon + bigM*phi-1];
end
