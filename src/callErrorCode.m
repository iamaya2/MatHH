function callErrorCode(errCode)
% callErrorCode   Script that prints an error/warning for facilitating
% feedback. The following codes have been defined:
%
% ---\ Warnings (0-99):
%     ---\ 0: Method/script is currently being developed.
% ---\ Errors (100+):
if errCode < 100
    warning('Warning code %d detected. The following issue has occurred: ', errCode)
    switch errCode
        case 0
            warning('WIP. This method has not been implemented yet. Behaviour might be erratic. Proceed with caution...')
        otherwise
            error('Warning code %d has not been defined yet. Aborting!', errCode)
    end
else
    switch errCode
        case 100
            error('toDo')
        otherwise
            error('Error code %d has not been defined yet. Aborting!', errCode)
    end
end
end