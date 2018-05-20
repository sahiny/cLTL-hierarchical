function [W, flag] = abs2con_rollback2(aTS, ia, fa, cTS, ic, fc, h, rb_constraints)
% number of agents
N = length(ic);
% workspace size
I = size(cTS.A,1);
% ILP variables
W = binvar(repmat(I,1,N),repmat(h,1,N),'full');
% MILP constraints
f = [];
flag = 0;
for n = 1:N
    % avoid visiting other states
    iAPName = aTS.APNames(ia(n));
    [~,iAPCells] = cTS.getAPCells(iAPName);
    fAPName = aTS.APNames(fa(n));
    [~,fAPCells] = cTS.getAPCells(fAPName);
    W{n}(setdiff(1:I,[iAPCells fAPCells]),:) = 0;
    % avoid obstacles
    W{n}(cTS.Obs,:) = 0; 
    % initial states
    if ic(n) > 0
        W{n}(:,1)=0;
        W{n}(ic(n),1)=1;
    else
%         f = [f sum(W{n}(iAPCells,1))>=1];
        W{n}(setdiff(1:I,iAPCells),1)=0;
    end
    % reach final dest
    if fc(n) > 0
        W{n}(:,end)=0;
        W{n}(fc(n),end)=1;
    else
%         f = [f sum(W{n}(fAPCells,end))>=1];
        W{n}(setdiff(1:I,fAPCells),end)=0;
    end
    % counterexamples
    if ~isempty(rb_constraints)
        W{n}(rb_constraints(:,n),end) = 0;
        % check infeasibility
        if isempty(setdiff(fAPCells, rb_constraints(:,n)))
            flag = 1;
            W = -1;
            return
        end
    end
    % obey concrete transition rules without going back
    An = cTS.A;
    % don't go back
    if ia(n) ~= fa(n)
        for fcell = fAPCells
           An(iAPCells, fcell) = 0;
        end
    end
    % obey transition rules
    for t = 1:h-1
        f = [f, W{n}(:,t+1) <= An*W{n}(:,t)];
    end 
    % conservation of mass
    f = [f, sum(W{n}) == ones(1,h)];
end

% avoid collisions with each other
for n1 = 1:N
    N2 = setdiff(1:N,n1);
    for n2 = 1:N-1
        for t = 1:h-1
            f = [f (W{n1}(:,t)) <= (ones(I,1) - (W{N2(n2)}(:,t)))];
            f = [f  (W{n1}(:,t+1))<= (ones(I,1) - (W{N2(n2)}(:,t)))]; 
        end
        f = [f W{n1}(:,h) <= (ones(I,1) - W{N2(n2)}(:,h))];
    end
end
options = sdpsettings('verbose',0,'solver','gurobi');
options.gurobi.Heuristics = 0.5;
options.gurobi.MIPFocus = 1;
options.gurobi.Symmetry = 2;
sol = optimize(f,[],options);
if sol.problem == 0 
%     for n = 1:N
%        W{n} = value(W{n}); 
%     end
    for n = 1:N
        W{n} = value(W{n}); 
        for t = 1:h
            W{n}(1,t) = find(W{n}(:,t)); 
        end
        W{n}(2:end,:) = [];
        W{n} = W{n}';
    end
    Wtemp = [];
    for n = 1:N
        Wtemp = [Wtemp W{n}];
    end
    W = Wtemp;
else
    W = -1;
end
% Wtotal = value(Wtotal);
1;
yalmip('clear')
end