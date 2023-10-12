function status = checkForLogic(logicTest, varargin)
if logicTest
    status = 1;
    fprintf(' PASS!\n');
else
    status = 0;
    fprintf(' FAIL!\n');
    callErrorCode(105) % Failed test
end
end