function status = checkForEquality(obj1, obj2, result)
fprintf('\tTesting equality of contents...')
if isequal(obj1,obj2) == result
    status = 1;
    fprintf(' PASS!\n');
else
    status = 0;
    fprintf(' FAIL!\n');
    callErrorCode(103) % Failed test
end
end