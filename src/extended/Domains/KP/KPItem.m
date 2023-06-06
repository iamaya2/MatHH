
classdef KPItem < handle & deepCopyThis
%% KPItem   Class for defining items for the Knapsack Problem
%
% A KPItem can be created in the following ways:
%
% 1. From numeric values. In this case the user must provide three
%                         elements. The first one is profit, the second one
%                         is weight, and the last one is the ID for the
%                         item. 
%
% 2. From another KPItem. In this case the user only needs to provide an
%                         object and the class returns a deep copy of it.
    properties
        ID = NaN; % Identifier of this item
        isPacked = false; % Flag for knowing item status
        profit = NaN; % Profit earned if this item is packed
        weight = NaN; % Weight added by packing this item
    end
    
    methods  
        % ---- ------------------------ ----
        % ---- CONSTRUCTOR ----
        % ---- ------------------------ ----
        function obj = KPItem(varargin)
            if nargin > 0
                if isnumeric(varargin{1}) % From numeric data
                    obj.profit = varargin{1};
                    obj.weight = varargin{2};
                    obj.ID = varargin{3};
                elseif isa(varargin{1},'KPItem') % From another KPItem
                    oldObj = varargin{1};
                    obj = KPItem();
                    oldObj.deepCopy(obj);
                else
                    callErrorCode(102);
                end
            end
        end        
        
        % ---- ------------------------ ----
        % ---- OTHER METHODS ----
        % ---- ------------------------ ----
        function donePacking(obj)
            % donePacking  Method for updating the packing status of the
            % item. Requires no inputs.
            obj.isPacked = true;
        end
        
        function doneUnpacking(obj)
            % doneUnpacking  Method for updating the packing status of the
            % item. Requires no inputs.
            obj.isPacked = false;
        end
    
        % ----- ---------------------------------------------------- -----
        % Methods for overloading functionality
        % ----- ---------------------------------------------------- -----
        function disp(obj)
            if obj.isPacked, packStr = 'Packed'; else, packStr = 'Unpacked'; end
            textStr = sprintf('Item %d: Profit = %.2f, Weight = %.2f, Status = %d (%s)\n',...
                obj.ID, obj.profit, obj.weight, obj.isPacked, packStr);
            fprintf(textStr)
        end
        
    end
end