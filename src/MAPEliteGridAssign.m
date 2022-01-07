function [disSearchSpace, gridSearchSpace, gridSearchSpaceF] = MAPEliteGridAssign ...
    (disSearchSpace, gridSearchSpace, gridSearchSpaceF, targetGenome, fGenome)
nbDimInt = length(targetGenome);
cellID = zeros(1,nbDimInt);
for idx = 1 : nbDimInt
    for idy = 1 : size(gridSearchSpaceF,idx)
        if targetGenome(idx) >= disSearchSpace(idx,idy) && targetGenome(idx) <= disSearchSpace(idx,idy+1)
            cellID(idx) = idy;
            break;
        end
    end
end
transfCellID = num2cell(cellID);
if isnan(gridSearchSpaceF(transfCellID{:}))
    gridSearchSpaceF(transfCellID{:}) = fGenome;
    gridSearchSpace{transfCellID{:}} = targetGenome;
else
    if fGenome < gridSearchSpaceF(transfCellID{:})% Check if < or <=
        gridSearchSpaceF(transfCellID{:}) = fGenome;
        gridSearchSpace{transfCellID{:}} = targetGenome;
    end
end





end