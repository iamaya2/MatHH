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
            % deepCopy   Method for deep cloning object
            % properties. Automatically sweeps all properties
            %            
            % Example:
            %   oldObj.deepCopy(newObj);
            
            % Old version (conflicts with dependent properties)
%             propertySet = properties(oldObj);
%             for idx = 1:length(propertySet)                 
%                 thisOldProp = oldObj.(propertySet{idx});
%                 newObj.(propertySet{idx}) = [thisOldProp];
%                 if isa(thisOldProp,'deepCopyThis')
%                     nbCopies = length(thisOldProp);
%                     for idy = 1 : nbCopies
%                         newObj.(propertySet{idx})(idy) = eval(class(thisOldProp));
%                         oldObj.(propertySet{idx})(idy).deepCopy(newObj.(propertySet{idx})(idy));
%                     end                                        
%                 end
%             end
            
            % New version (pending test)
            mc = eval(['?' class(oldObj)]); % Gets metaclass for object
            allProps = mc.PropertyList;
            nbProps = length(allProps);
            for idx = 1 : nbProps
                if ~allProps(idx).NonCopyable
                    thisOldSubObj = oldObj.(allProps(idx).Name);
                    %newObj.(allProps(idx).Name) = [thisOldSubObj];
                    if isa(thisOldSubObj,'deepCopyThis')
%                     if isa(thisOldSubObj,'handle')
                        nbCopies = length(thisOldSubObj);
                        for idy = 1 : nbCopies
                            newObj.(allProps(idx).Name)(idy) = eval(class(thisOldSubObj));
                            oldObj.(allProps(idx).Name)(idy).deepCopy(newObj.(allProps(idx).Name)(idy));
                        end
                    else
                        newObj.(allProps(idx).Name) = [thisOldSubObj];
                    end
                end
            end

       end
        
   end
end