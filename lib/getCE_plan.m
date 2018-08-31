function f = getCE_plan(CE)
f = [];

if isempty(CE{1})
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
for c = 1:length(CE)
    ce = CE{c};
    for t = 1:h
        for n = 1:N
            W{n}(ce(t,n),t)=0;
        end
    end
end
