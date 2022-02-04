function generateInstanceFromCSV(folderID)
allInstanceData = csvread([folderID 'instanceDataset.csv']);
nbInstances = size(allInstanceData,1);
instanceDataset{nbInstances} = BPInstance(); % Use dummy for allocation
for idx = 1 : nbInstances    
    instanceDataset{idx} = BPInstance(allInstanceData(idx,:),idx);
end
save([folderID 'instanceDataset.mat'],'instanceDataset');
fprintf('Folder %s completed!\n', folderID);
end