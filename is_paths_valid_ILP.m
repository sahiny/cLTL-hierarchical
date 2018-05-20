function [is_found, cc1, cc2] = is_paths_valid_ILP(paths)
% cci = [agent t cell]
is_found = 1;

for n1 = 1:length(paths)-1
    p1 = paths{n1};
    for n2 = 2:length(paths)
        p2 = paths{n2};
        if ~isempty(find((p1-p2)==0))
            1;
            is_found = 0;
            cc1 = find((p1-p2)==0,1);
            cc1 = [n1 cc1 p1(cc1(1))];
            cc2 = find((p1-p2)==0,1);
            cc2 = [n2 cc2 p2(cc2(1))];
            break
        elseif ~isempty(find((p1(2:end)-p2(1:end-1))==0))
            1;
            is_found = 0;
            cc1 = find((p1(2:end)-p2(1:end-1))==0,1);
            cc1 = [n1 cc1+1 p1(cc1(1)+1)];
            cc2 = find((p1(2:end)-p2(1:end-1))==0,1);
            cc2 = [n2 cc2 p2(cc2(1))];
            break
        elseif ~isempty(find((p1(1:end-1)-p2(2:end))==0))
            1;
            is_found = 0;
            cc1 = find((p1(1:end-1)-p2(2:end))==0);
            cc1 = [n1 cc1 p1(cc1(1))];
            cc2 = find((p1(1:end-1)-p2(2:end))==0);
            cc2 = [n2 cc2+1 p2(cc2(1)+1)];
            break
        end
    end
end

% cc1 = cc1(1);
% cc2 = cc2(2);