function status = checkForEquality(obj1, obj2, result, varargin)
status = getContentEquality(obj1,obj2,result);
if status
    fprintf(' PASS!\n');
else
    fprintf(' FAIL!\n');
    callErrorCode(103) % Failed test
end
end


function status = getContentEquality(obj1,obj2, result, varargin)
if nargin == 4, thisDepth = varargin{1}; else, thisDepth = 1; end
status = 0;
for ido = 1 : length(obj1)
    thisObj = obj1(ido); thatObj = obj2(ido);
    fprintf(repmat('\t',1,thisDepth))
    fprintf('Testing equality of %s contents...\n', class(obj1))
    fprintf(repmat('\t',1,thisDepth+1))
    fprintf('Testing equality of inner contents...')
    allProps = properties(thisObj);
    for idx = 1 : length(allProps)
        thisProp = allProps{idx};
        if isa(thisObj.(thisProp),'handle')
            % Validate if different because of different size
            if length(thisObj.(thisProp)) ~= length(thatObj.(thisProp)) % different size, so different
                if ~result
                    status = 1; % we wanted different, so OK
                    break % exit loop
                else
                    status = 0; % we wanted equal contents
                    fprintf(' FAIL!\n');
                    callErrorCode(103) % Failed test
                end
            end
            % End validation
            fprintf('\n')
            nbInnerObjs = length(thisObj.(thisProp));
            for idy = 1 : nbInnerObjs
                status = getContentEquality(thisObj.(thisProp)(idy),thatObj.(thisProp)(idy),result, thisDepth+1);
            end
        else
            if result
                if isequaln(thisObj.(thisProp),thatObj.(thisProp))
                    status = 1;                    
                else
                    status = 0;
                    fprintf(' FAIL!\n');
                    callErrorCode(103) % Failed test
                end
            else
                if ~isequaln(thisObj.(thisProp),thatObj.(thisProp))
                    status = 1;
                    fprintf(' PASS!\n');
                    return
                end
            end
        end
    end
    fprintf('\n')
end

end