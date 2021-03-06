function [fTP,phi] = getTPTau(formula, args, k)

global W Wtotal Z bigM tau zLoop epsilon;

if length(args) ~= 2
    disp('Missing argument');
    assert(length(args)==2);
end

% number of agents
N = length(W);
% time horizon
h = size(W{1},2)-1-tau;

r = getZ(strcat('Robust( ', formula, ')'), h, N);
% All constraints created in this function
fTP = [];
% set of all ztilde in paper
zTilde = [];
if tau == 0 || k==1
    [fTP, zTP] = getLTL(args{1},k);
    %r = zTP;
    fTP = [fTP, r(k,:) == zTP];
else
    %r = getZ(strcat('Robust( ', formula, ')'), h, N);
    [fTPk, ztilde] = getLTL(args{1},k);
    fTP = [fTP, fTPk];
    zTilde = [zTilde; ztilde];
    
    for t = 1:tau
        if t+k <= h
            % If t+k <= h no need to loop around
            ztilde = getZ(args{1},h+tau,N);
            ztilde = ztilde(t+k,:);
            zTilde = [zTilde; ztilde];
        else
%             % Loop around
%             % z^{\args{1},n}_t for all t,n
%             zAll =  getZ(args{1},0,0);
%             % ztilde_{k+t} (one for each agent)
%             ztilde = getZ(strcat('~(',num2str(args{1}),')[',num2str(k),',',num2str(t),']'),1,N);
%             % Add to all set of all ztilde
%             zTilde = [zTilde; ztilde];
%             % Or(z^{args{1},n}_{l+k+t-h-1},1-zLoop_{l})
%             zOr = getZ(strcat('Or(',num2str(args{1}),', Neg(zLoop))[',num2str(k),',',num2str(t),']'),h-t,N);
%             for l = 1:h-t
%                 for n = 1:N
%                     fTP = [fTP, zOr(l,n)>=1-zLoop(l), zOr(l,n)>=zAll(l+t+k-h-1,n),...
%                         zOr(l,n)<= 1-zLoop(l)+zAll(l+t+k-h-1,n)]; 
%                 end
%             end
%             % ztilde = And(zOr)
%             for n = 1:N
%                 fTP = [fTP, ...
%                 repmat(ztilde(n),h-t,1) <= zOr(:,n),...
%                 ztilde(n) >= 1-(h-t)+sum(zOr(:,n))];     
%             end
        [fTPk, ztilde] = getLTL(args{1},t+k);
        fTP = [fTP, fTPk];
        zTilde = [zTilde; ztilde];
        end
    end
    
    % robustified version
    %r = getZ(strcat('Robust( ', formula, ')'), h, N);
    for n = 1:N
        for t = 0:tau
        %fTP = [fTP, repmat(r(k,n),tau+1,1)<= zTilde(:,n), r(k,n) >= sum(zTilde(:,n))-tau];
            fTP = [fTP, r(k,n)<= zTilde(t+1,n)]; 
        end
    fTP = [fTP, r(k,n) >= sum(zTilde(:,n))-tau];
    end
end
    
phi = getZ(formula,h,1);
phi = phi(k);
% 
% if args{2} < N
%     args{2} = args{2} +1;
% end

if args{2} <= N
    fTP = [fTP, sum(r(k,:)) >= args{2} - bigM*(1-phi)];
    fTP = [fTP, sum(r(k,:)) <= args{2} + bigM*phi-1];
else
    fTP = [fTP, sum(r(k,:)) >= args{2} + epsilon - bigM*(1-phi)];
    fTP = [fTP, sum(r(k,:)) <= args{2} + epsilon + bigM*phi-1];
end
