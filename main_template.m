function [W, Wtotal, Z, loopBegins, sol] = main_template(...
    formula,A,h,W0,Obs,UB,CA_flag,CE)
% time = clock;
% disp([ 'Started at ', ...
% num2str(time(4)), ':',... % Returns year as character
% num2str(time(5)), ' on ',... % Returns month as character
% num2str(time(3)), '/',... % Returns day as char
% num2str(time(2)), '/',... % returns hour as char..
% num2str(time(1))]);

if h==0
    disp('Trajectory must be greater than 0');
    assert(h>0);
end

tos = tic;

global W Wtotal Z zLoop ZLoop bigM epsilon tau;
%tau = 0;
epsilon = 0;
% Number of agents
N = length(W0);

% bigM notation
bigM = N+1+epsilon;

% number of states
I = length(A);

% control input
W = binvar(repmat(I,1,N),repmat(h+1+tau,1,N),'full'); 
if N == 1
     W = {W}; %#ok<*NODEF>
end



% Initial state constraint
%disp('Creating other constraints...')
fInit = getInit(W0);

% Wtotal
Wtotal = W{1};
for i = 1:h+1
    for n = 2:N
        Wtotal(:,i) = Wtotal(:,i) + W{n}(:,i); %#ok<*AGROW>
    end
end

% Obstacle Avoidence Constraint
fObs = getObs(Obs);

% System dynamics constraint
fDyn = getDyn(A,CA_flag);

% Loop constraint
fLoop= getLoop();

% Timing of other constraints
%toe = toc(tos);
%disp(['    Done with other constraints (',num2str(toe),') seconds'])

% LTL constraint
%disp('Creating LTL constraints...')
%tltls=tic;
Z = {};
[fLTL,phi] = getLTL(formula,1);
%tltle=toc(tltls);
%disp(['    Done with LTL constraints (',num2str(tltle),') seconds'])
warning off
% Upper bounds
fUB = getUB(UB);
warning on
% counter examples
fCE = getCE2(CE);

% All Constraints
%F = [fInit, fDyn, fLoop, fObs, fLTL, phi==1];
F = [fInit, fDyn, fLoop, fLTL, phi==1, fCE, fUB];

% if CA_flag
%     F = [F fCol];
% end
%disp(['    Total number of optimization variables : ', num2str(length(depends(F)))]);

% Solve the optimization problem
%H = -epsilon; % maximize epsilon
options = sdpsettings('verbose',0,'solver','gurobi');
options.gurobi.Heuristics = 0.5;
options.gurobi.MIPFocus = 1;
options.gurobi.Symmetry = 2;
%disp('Solving MILP...')
%tms=tic;
sol = optimize(F,[],options);
tme=toc(tos);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Assign values


if sol.problem == 0
    % Extract and display value
    % disp('## Feasible solution exists ##')
    % Now get the values
    disp(['Found an abstract plan in (',num2str(tme),') seconds'])
    for n = 1:N
        W{n} = value(W{n}); 
        for t = 1:h+1+tau
            W{n}(1,t) = find(W{n}(:,t)); 
        end
        W{n}(2:end,:) = [];
        W{n} = W{n}';
    end
    Wtemp = [];
    for n = 1:N
        Wtemp = [Wtemp W{n}];
    end
    W = Wtemp(1:h+1,:);
    for i=1:length(Z)
        Z{i}{1} = value(Z{i}{1});
        if ~isnan(Z{i}{1}) 
            1;
        else
            1;
            %disp(['#### Careful!! {',num2str(i), '} ', num2str(Z{i}{2}), ' is NaN']); 
        end
    end
    Wtotal = value(Wtotal);
    % Loop
    zLoop = value(zLoop);
    ZLoop = value(ZLoop);
    loopBegins = find(zLoop(:)==1);
else
     W=0;Wtotal=0;WT=0;ZLoop=0;zLoop=0;loopBegins=0;
%      sol.solvertime = -1;
     %sol.info
     %yalmiperror(sol.problem)
     disp('## No feasible abstract plans found! ##');
end

ttotal = toc(tos);
%mytimes = [ttotal,toe, tltle, sol.solvertime];
yalmip('clear')