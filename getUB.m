function f = getUB(UB)
global W Wtotal Z zLoop ZLoop bigM epsilon tau;
% number of agents
N = length(W);
% number of states
I = size(W{1},1);
% time horizon
h = size(W{1},2)-1-tau;

% Counter Example constraints
f = [];

for t = 1:h
    f = [f, Wtotal(:,t) <= UB];
end
        
        
