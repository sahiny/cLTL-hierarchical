function f = getCE_onestep(CE)
if isempty(CE{1})
    f = [];
    return
end

global W Wtotal Z zLoop ZLoop bigM epsilon tau;
% number of agents
N = length(W);
% number of states
I = size(W{1},1);
% time horizon
h = size(W{1},2)-1-tau;

% Counter Example constraints
f = [];


for c = 1:length(CE)
    ce = CE{c};
    z = getZ(['CE_onestep',num2str(c)],1,h);
    z2 = getZ(['CE2_onestep',num2str(c)],I,h);
    for t = 1:h
        f = [f [Wtotal(:,t);Wtotal(:,t+1)] <= ce - z2(:,t) + bigM*z(t)];
        f = [f [Wtotal(:,t);Wtotal(:,t+1)] >= ce + z2(:,t) - bigM*(1-z(t))];
        f = [sum(z2(:,t))>=1];
    end
end
