function [ newC, newCG, newCBG ] = po2Map2Closest(oldMesh, newMesh, po2Data)
%% Given two meshes, map the po2 and oxygenation values from the old to the new

% Load files
disp('Remapping po2 values')
disp('Loading data...')
tic
oldMesh = load(oldMesh);
newMesh = load(newMesh);
po2Data = load(po2Data);

% Extract relevant variables
disp('Analyzing...')
newNode = newMesh.im2.Mesh.node;
newVasc = newMesh.im2.nodePos;
% Get min and max in each dimension
lims    = [min(newNode(:,1)) max(newNode(:,1)); ...
           min(newNode(:,2)) max(newNode(:,2)); ...
           min(newNode(:,3)) max(newNode(:,3))];
       
oldVasc = oldMesh.im2.nodePos;
oldNode = oldMesh.im2.Mesh.node;
idx     = find(oldNode(:,1) >= lims(1,1) &...
               oldNode(:,1) <= lims(1,2) &...
               oldNode(:,2) >= lims(2,1) &...
               oldNode(:,2) <= lims(2,2) &...
               oldNode(:,3) >= lims(3,1) &...
               oldNode(:,3) <= lims(3,2));
oldNode = oldNode(idx,:);
oldC    = po2Data.c(idx,end);

% Find closest nodes
k = dsearchn(oldNode, newNode);
j = dsearchn(oldVasc, newVasc);

% Output
newC   = oldC(k);
newCG  = po2Data.cg(j,end);
newCBG = po2Data.cbg(j,end);

toc



