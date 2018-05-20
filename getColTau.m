function fCol = getColTau()
% returns collision avoidance constraints
global W Wtotal zLoop tau;
% number of agents
N = length(W);
% number of states
I = size(W{1},1);
% time horizon
h = size(W{1},2)-1-tau;

%Wtotal = W{1};

fCol = [];
for t = 1:h
    for n = 1:N
        Nleft = setdiff(1:N,n);
        for k = 0:tau
            if t+k <= h+tau
                for n2 = 1:N-1
                    fCol = [fCol, ...
                    W{n}(:,t) <= ones(size(W{1}(:,1))) - W{Nleft(n2)}(:,t+k)];
                end
            else
                step = t+k-h-1;
                for t2 = step+1:h-tau
                    fCol = [fCol, ...
                    W{n}(:,t) <= ones(size(W{1}(:,1))) + ...
                    ones(size(W{1}(:,1)))*(1-zLoop(t2-step)) - W{Nleft(n2)}(:,t2+k)];
                end
            end
        end
    end
end

