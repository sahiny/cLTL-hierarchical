function conW = main_hierarchical(f,cTS,hc,cW0,aTS,ha,aW0,UB)
CE = {};
N = length(cW0);
is_solved = 0;
if ~isempty(cW0)
    aW0 = zeros(1,N);
    for n = 1:N
        for a = 1:size(aTS.A,1)
            iAPName = aTS.APNames(a);
            [apIndex, apCells] = cTS.getAPCells(iAPName);
            if ~isempty(find(apCells == cW0(n)))
                aW0(n) = apIndex;
                break
            end
        end
    end
end


while ~is_solved
    %% solve the abstract problem
    disp('...Generating Abstract Plan...')
    [absW, Wtotal, Z, loopBegins, sol] = main_template(f,aTS.A,ha,aW0,aTS.Obs,UB, 0, CE);
    if sol.problem == 0 
        %% solve concrete problem
        conW = [];
        if ~isempty(cW0)
            ic = cW0;
        else
            ic = zeros(1,size(absW,2));
        end
        fc = zeros(1,size(absW,2));
        for t = 1:size(absW,1)-1
%             if t ==size(absW,1)-1
%                 fc = conW(hc*(loopBegins-1)+1,:);
%             end
            ia = absW(t,:);
            fa = absW(t+1,:);
            ta2c = tic;
            [conWt] = abs2con(aTS, ia, fa, cTS, ic, fc, hc);
            if conWt(1) == -1
               % couldn't solve it, generate CE or try different concretes
               ce = zeros(size(aTS.A,1),2);
               for n = 1:length(ia)
                   ce(ia(n),1) = ce(ia(n),1)+1;
                   ce(fa(n),2) = ce(fa(n),2)+1;
               end
%                CE{end+1} = ce;
               CE{end+1} = [ia' fa'];
               disp(['--- No feasible plans found for step ', num2str(t), '/', num2str(ha)])
%                disp('--- Generated counter example...')
               break;
            else
               % successful
               ta2c = toc(ta2c);
               disp(['    Step ', num2str(t), '/', num2str(ha), ' is feasible (', num2str(ta2c),' seconds)'])
               conW = [conW; conWt];
               ic = conW(end,:);
               1;
            end
        end
        if size(conW,1)>= hc*ha
            disp('')
            is_solved = 1;
        end
    else
        % no abstract solution left
        assert(0,'####### Failed to find solutions! ######');
    end
%     is_solved = 1;
end