function ConW = main_hierarchical_graph(f,cTS,hc,cW0,aTS,ha,aW0,UB, rb_threshold)
N = length(cW0);
is_solved = 0;
if ~isempty(cW0)
    aW0 = zeros(1,N);
    for n = 1:N
        for a = 1:size(aTS.A,1)
            iAPName = aTS.APNames(a);
            [apIndex, apCells] = cTS.getAPCells(iAPName);
            if ~isempty(find(apCells == cW0(n))) %#ok<EFIND>
                aW0(n) = apIndex;
                break
            end
        end
    end
end

CE_plan = cell(1);
CE_onestep = cell(1);
ConW = {};
while ~is_solved
    %% solve the abstract problem
    disp('...Generating Abstract Plan...')
    [absW, Wtotal, Z, loopBegins, sol] = main_template_rollback(...
        f,aTS.A,ha,aW0,aTS.Obs,UB, 0, CE_plan, CE_onestep);
    if sol.problem == 0 
        %% solve concrete problem
%         conW = [];
        ConW = {};
        HC = hc*ones(size(absW,1),1);
        if ~isempty(cW0)
            ic = cW0;
        else
            ic = zeros(1,size(absW,2));
        end
        t=1;
        rb_count = 0;
        rb_constraints = cell(size(absW,1),1);
        while t < size(absW,1) && rb_count <= rb_threshold
            if t ==size(absW,1)-1
                fc = ConW{loopBegins}(1,:);
                HC(t) = HC(t) + 2;
            else
                fc = zeros(1,size(absW,2));
            end
            if ~isempty(rb_constraints{t})
                HC(t) = HC(t) + 2;
                HC(t+1) = HC(t+1) + 2;
            end
            ia = absW(t,:);
            fa = absW(t+1,:);
            for n = 1:N
                fAPName = aTS.APNames(fa(n));
                [~,fAPCells] = cTS.getAPCells(fAPName);
                % rb_constraints
                if fc(n) == 0
                    if ~isempty(rb_constraints{t})
                        fc(n) = datasample(setdiff(fAPCells, [rb_constraints{t}(:,n);fc']),1);
                    else
                        fc(n) = datasample(setdiff(fAPCells, fc'), 1);
                    end
                end
            end
            ta2c = tic;
            [conWt, infeasibility_flag] = abs2con_ILP(aTS, ia, fa, cTS, ic, fc, HC(t), rb_constraints{t});
            if conWt(1) == -1
               % couldn't solve it, generate CE or try different concretes
               ce = zeros(size(aTS.A,1),2);
               for n = 1:length(ia)
                   ce(ia(n),1) = ce(ia(n),1)+1;
                   ce(fa(n),2) = ce(fa(n),2)+1;
               end
%                CE{end+1} = ce;
               
               disp(['--- No feasible plans found for step'...
                   ,num2str(t), '/', num2str(ha)])
               if t == 1
                   disp('--- Generating Counter-Example ...');
                   CE_plan{end+1} = absW;
                   break;
%                    CE_onestep{end+1}= [ce(:,1);ce(:,2)];
               elseif infeasibility_flag
                   disp('--- Generating Counter-Example ...');
                   CE_onestep{end+1}= [ce(:,1);ce(:,2)];
                   break;
               else
                   disp('--- Rollingback ...');
                   t = t - 1;
                   ic = ConW{t-1}(end,:); 
                   rb_constraints{t} = [rb_constraints{t}; ic]; %#ok<*NASGU>
                   rb_count = rb_count + 1;
                   if rb_count == rb_threshold
                       CE_plan{end+1} = absW;
                       ha = ha + 2;
                       break
                   end
                   continue
               end
            else
               % successful
               ta2c = toc(ta2c);
               disp(['    Step ', num2str(t), '/', num2str(ha)...
                   , ' is feasible (', num2str(ta2c),' seconds)'])
%                conW = [conW; conWt];
               ConW{t} = conWt;
               ic = ConW{t}(end,:);
               t = t + 1;
               1;
            end
        end
        if length(ConW)>= ha
            disp('')
            is_solved = 1;
%             conW = [];
%             for t = 1:ha
%                 conW = [conW; ConW{t}];
%             end
        end
    else
        % no abstract solution left
        disp(['####### Failed to find solutions! ######']);
%         ha = ha + 2;
    end
%     is_solved = 1;
end