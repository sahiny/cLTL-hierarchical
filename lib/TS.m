classdef TS < matlab.mixin.Copyable
   properties
      Size
      A
      APNames
      APCells
      Obs
      %AbstractTS
   end
   events
%       reqForkReceived
%       forkReceived
% %       reqBottleReceived
%       bottleReceived
%       gotHungry
%       finishedEating
   end
   methods
       % sets and gets
       function obj = TS(A)
           obj.setA(A);
       end
       function setA(obj, A)
          obj.A = A;
%           if isempty(obj.Size)
              obj.Size = size(A,1);
              obj.APNames = {'dummy'};
              obj.APCells = {1:prod(obj.Size)};
%           elseif isequal(size(A),obj.Size)
%               disp('Size of A is wrong!');
%           end
       end
       function setObs(obj, Obs)
          obj.Obs = Obs;
          obj.APCells{end} = setdiff(obj.APCells{end},Obs);
       end
       function A = getA(obj)
          A = obj.A;
       end
       function Size = getSize(obj)
          Size = obj.Size;
       end
%        function setSize(obj, Size)
%            if isempty(obj.A)
%               obj.Size = Size;
%               obj.A = zeros(obj.Size);
%               obj.APNames = {'dummy'};
%               obj.APCells = 1:prod(obj.Size);
%            elseif isequal(size(obj.A),Size)
%                disp('Size does not match A');
%            end
%        end
%        function setAPNames(obj, APNames)
%           obj.APNames = APNames;
%        end
       function APNames = getAPNames(obj)
          APNames = obj.APNames;
       end
       function [apIndex, apCells] = getAPCells(obj, name)
           for ap = 1:length(obj.APNames)
          	if strcmp(obj.APNames{ap},name)
                apIndex = ap;
                apCells = obj.APCells{ap};
            end
           end
       end
       function apIndex = getAPIndex(obj, name)
           for ap = 1:length(obj.APNames)
          	if strcmp(obj.APNames{ap},name)
                apIndex = ap;
            end
           end
       end
%        function setAPCells(obj, APCells)
%           obj.APCells = APCells;
%        end
%        function APCells = getAPCells(obj)
%           APCells = obj.APCells;
%        end
       function addAP(obj, name, cells)
          dummy_cells = obj.APCells{end}; 
          obj.APNames{end} = name;
          obj.APCells{end} = cells;
          obj.APNames{end+1} = 'dummy';
          obj.APCells{end+1} = setdiff(dummy_cells, cells);
       end

       %% Get AbstractTS
       function absTS = con2abs(obj)
          % function Ta = con2abs(Tc)
            % Gc = digraph(Tc.A,'OmitSelfLoops');
            numAP = length(obj.APNames);
            Ga = digraph(zeros(numAP));
            for i = 1:numAP-1
            %     Ac1 = Tc.A;
                ap1 = obj.APCells{i};
                for j = i+1:numAP
                    ap2 = obj.APCells{j};
                    others = setdiff(1:size(obj.A,1), [ap1 ap2]);
                    Ac12 = obj.A;
                    Ac12(others,:) = 0;
                    Ac12(:,others) = 0;
                    Gc12 = digraph(Ac12,'OmitSelfLoops');
                    if ~isempty(ap2)&&~isempty(ap1)
                        if ~isempty(Gc12.shortestpath(ap1(1), ap2(1)))
                            Ga = addedge(Ga,i,j,1);
                            Ga = addedge(Ga,j,i,1);
                        end
                    end
                end
            end
            A = full(adjacency(Ga));
            A = A + eye(size(A));
            absTS = TS(A);
            absTS.APNames = obj.APNames;
            absTS.APCells = obj.APCells;
            absTS.Obs = ones(size(A,1),1)==zeros(size(A,1),1);
       end
   end
end