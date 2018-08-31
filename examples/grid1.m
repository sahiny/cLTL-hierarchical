global mu_prime
grid_size = [30,30];
A = eye(prod(grid_size)); %allow self-transition

for i=1:length(A)
    if mod(i, grid_size(1))~=0 
        A(i, i+1) = 1;
    end
    if mod(i, grid_size(1))~=1
        A(i, i-1) = 1;
    end
    if i<=grid_size(1)*(grid_size(2)-1)
        A(i, i+grid_size(1)) = 1;
    end
    if i>grid_size(1)
        A(i, i-grid_size(1)) = 1;
    end
end


mygrid = ones(grid_size);
mygrid(12:13, 1:8) = 0;
mygrid(19:30, 7:8) = 0;
mygrid(1:12, 12:13) = 0;
mygrid(4:27, 17:18) = 0;
mygrid(15:16, 22:30) = 0;
Obs = find(mygrid==0);

mygrid(1:11,1:11) = 0.6; % b1
mygrid(1:14,19:30) = 0.7;% b2
mygrid(17:30,19:30) = 0.8;% b3
mygrid(14:30,1:6) = 0.9;% initial
mygrid(15:16,19:21) = 0.81;
mygrid(28:30,17:18) = 0.82;



mygrid(Obs) = 0;

mygrid2 = zeros(size(mygrid)+4);
mygrid2(3:end-2, 3:end-2) = mygrid;
imshow(kron(mygrid2,ones(10,10)));


r1 = find(mygrid==0.6)';
r2 = find(mygrid==0.7)';
r3 = find(mygrid==0.8)';
g1 = find(mygrid==0.81)';
g2 = find(mygrid==0.82)';


initial_region = find(mygrid==0.9)';

cTS = TS(A);
cTS.setObs(Obs);
cTS.addAP('r1',r1);
cTS.addAP('r2',r2);
cTS.addAP('r3',r3);
if mu_prime
cTS.addAP('g1',g1);
cTS.addAP('g2',g2);
end
aTS = cTS.con2abs;
if mu_prime
    UB = [length(r1)-2, length(r2)-2, length(r3)-2, ...
        length(g1)-2, length(g2)-2,...
size(A,1)-length([r1 r2 r3 g1 g2])-2]';
else
    UB = [length(r1)-2, length(r2)-2, length(r3)-2,...
    numel(mygrid)- length([r1 r2 r3])-2]';
end