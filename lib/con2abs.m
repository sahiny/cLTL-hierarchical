% function Ta = con2abs(Tc)
% Gc = digraph(Tc.A,'OmitSelfLoops');
numAP = length(Tc.AP);
marked = [];
I = size(Tc.A,1);
for i = 1:numAP
    marked = [marked Tc.AP{i}];
end
unmarked = setdiff(1:I,marked);
AP = Tc.AP;
AP{end+1} = unmarked;
Ga = digraph(zeros(numAP+1));
for i = 1:numAP
%     Ac1 = Tc.A;
    ap1 = AP{i};
    for j = i+1:numAP+1
        ap2 = AP{j};
        others = setdiff(1:I, [ap1 ap2]);
        Ac12 = Tc.A;
        Ac12(others,:) = 0;
        Ac12(:,others) = 0;
        Gc12 = digraph(Ac12,'OmitSelfLoops');
        if ~isempty(Gc12.shortestpath(AP{i}(1), AP{j}(1)))
            Ga = addedge(Ga,i,j,1);
            Ga = addedge(Ga,j,i,1);
        end
    end
end

Ta = struct();
Ta.A = full(adjacency(Ga));