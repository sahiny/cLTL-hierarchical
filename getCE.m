function f = getCE(CE)
global W Wtotal Z zLoop ZLoop bigM epsilon tau;
% number of agents
N = length(W);
% number of states
I = size(W{1},1);
% time horizon
h = size(W{1},2)-1-tau;

% Counter Example constraints
f = [];
% z11 = getZ('CE11',h-1,length(CE));
% z12 = getZ('CE12',h-1,length(CE));
% z21 = getZ('CE21',h-1,length(CE));
% z22 = getZ('CE22',h-1,length(CE));
% z = getZ('CE',h-1,length(CE));


for c = 1:length(CE)
    ce = CE{c};
    for t = 1:h
        f = [f sum(abs([Wtotal(:,t); Wtotal(:,t+1)] - [ce(:,1);ce(:,2)])) >= 1 ];
    end
end
        
        
       % z11 == z12 -> wtotal(t) == ce1
%        f = [f Wtotal(:,t) <= ce(:,1) + bigM*z11(t,c)];
%        f = [f Wtotal(:,t) >= ce(:,1) - bigM*(1-z11(t,c))];
%        f = [f Wtotal(:,t) <= ce(:,1) + bigM*(1-z12(t,c))];
%        f = [f Wtotal(:,t) >= ce(:,1) - bigM*z12(t,c)];
%        % z21 == z22 -> wtotal(t+1) == ce2
%        f = [f Wtotal(:,t+1) <= ce(:,2) + bigM*z21(t,c)];
%        f = [f Wtotal(:,t+1) >= ce(:,2) - bigM*(1-z21(t,c))];
%        f = [f Wtotal(:,t+1) <= ce(:,2) + bigM*(1-z22(t,c))];
%        f = [f Wtotal(:,t+1) >= ce(:,2) - bigM*z22(t,c)];
%         f = [f [Wtotal(:,t); Wtotal(:,t+1)]<= [ce(:,1);ce(:,2)]+ bigM*z11(t,c)];
%         f = [f [Wtotal(:,t); Wtotal(:,t+1)]>= [ce(:,1);ce(:,2)]- bigM*z12(t,c)];
%         f = [f z(t,c)>=1];
%        f = [f [Wtotal(:,t); Wtotal(:,t+1)]>= [ce(:,1);ce(:,2)] - bigM*(1-z11(t,c))];
%        f = [f [Wtotal(:,t); Wtotal(:,t+1)] <= [ce(:,1);ce(:,2)] + bigM*(1-z12(t,c))];
%        f = [f [Wtotal(:,t); Wtotal(:,t+1)] >= [ce(:,1);ce(:,2)] - bigM*z12(t,c)];
        %
%        f = [f, z1(t,c)+z2(t,c)]
%        f = [f z1(t,c)+z2(t,c)>=1];
