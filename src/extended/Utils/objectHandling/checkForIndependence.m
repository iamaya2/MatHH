function status = checkForIndependence(obj1, obj2, result)
fprintf('\tTesting independence of objects...')
if (obj1~=obj2) == result
    status = 1;
    fprintf(' PASS!\n');
else
    status = 0;
    fprintf(' FAIL!\n');
    callErrorCode(104) % Failed test
end
end