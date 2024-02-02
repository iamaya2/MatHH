function status = checkForIndependence(obj1, obj2, result, varargin)
if nargin == 4, thisDepth = varargin{1}; else, thisDepth = 1; end
for ido = 1 : length(obj1)
    thisObj = obj1(ido); thatObj = obj2(ido);
    fprintf(repmat('\t',1,thisDepth))
    fprintf('Testing independence of %s objects...', class(obj1))
    if (thisObj~=thatObj) == result
        status = 1;
        fprintf(' PASS!\n');
        fprintf(repmat('\t',1,thisDepth+1))
        fprintf('Testing independence of inner objects...')
        allProps = properties(thisObj);
        for idx = 1 : length(allProps)
            thisProp = allProps{idx};
            if isa(thisObj.(thisProp),'handle')
                % Validate if different because of different size
                if length(thisObj.(thisProp)) ~= length(thatObj.(thisProp)) % different size, so independent
                    if result
                        status = 1; % we wanted independent, so OK
                        break % exit loop
                    else
                        status = 0; % we wanted dependent objects
                        fprintf(' FAIL!\n');
                        callErrorCode(104) % Failed test
                    end
                end
                % End validation
                fprintf('\n')
                nbInnerObjs = length(thisObj.(thisProp));
                for idy = 1 : nbInnerObjs
                    if isa(thisObj.(thisProp)(idy),'JSSP'), continue, end
                    checkForIndependence(thisObj.(thisProp)(idy),thatObj.(thisProp)(idy),result, thisDepth+1);
                end
            end
        end
        fprintf(' PASS!\n');
    else
        status = 0;
        fprintf(' FAIL!\n');
        callErrorCode(104) % Failed test
    end
end
end

