function getWtotal
% Wtotal
global W tau
% number of agents
N = length(W);
% number of states
I = size(W{1},1);
% time horizon
h = size(W{1},2)-1-tau;

Wtotal = W{1};
for i = 1:h
    for n = 2:N
        Wtotal(:,i) = Wtotal(:,i) + W{n}(:,i);
    end
end