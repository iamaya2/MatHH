%% deepCopyThis   Class for unifying deep copy capabilities
%
% WIP. Deep copy is not fully achieved yet. 
classdef deepCopyThis < matlab.mixin.Copyable    
   properties
      
   end
   
   
   methods
       function cloneProperties(oldItem, newItem)
            % cloneProperties   Method for cloning the object
            % properties. Automatically sweeps all properties. Use it with
            % objects that require shallow copies, such as items within
            % instances, or within instances to refer to the same items.
            %
            % Example:
            %   oldObj.cloneProperties(newObj);
            propertySet = properties(oldItem);
            for idx = 1:length(propertySet) 
                [newItem.(propertySet{idx})] = oldItem.(propertySet{idx});
            end
        end
       
       function deepCopy(oldObj, newObj)
            % deepCopy   WIP - Method for deep cloning object
            % properties. Automatically sweeps all properties
            %            
            propertySet = properties(oldObj);
            for idx = 1:length(propertySet)                 
                thisOldProp = oldObj.(propertySet{idx});
                newObj.(propertySet{idx}) = [thisOldProp];
                if isa(thisOldProp,'deepCopyThis')
                    nbCopies = length(thisOldProp);
                    for idy = 1 : nbCopies
                        newObj.(propertySet{idx})(idy) = eval(class(thisOldProp));
                        oldObj.(propertySet{idx})(idy).deepCopy(newObj.(propertySet{idx})(idy));
                    end                                        
                end
            end
       end
        
   end
end