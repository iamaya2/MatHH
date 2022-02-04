function callErrorCode(errCode)
% callErrorCode   Script that prints an error/warning for facilitating
% feedback. The following codes have been defined:
%
% ---\ Warnings (0-99):
%     ---\ 0: Method/script is currently being developed.
% ---\ Errors (100+):
%     ---\ 100: Undefined heuristic ID.
%     ---\ 101: Undefined instance dataset.
%     ---\ 102: Invalid input for constructor.
if errCode < 100
    warning('Warning code %d detected. The following issue has occurred: ', errCode)
    switch errCode
        case 0
            warning('WIP. This method has not been implemented yet. Behaviour might be erratic. Proceed with caution...')
        otherwise
            error('Warning code %d has not been defined yet. Aborting!', errCode)
    end
else
    warning('Error code %d detected. The following fatal issue has occurred: ', errCode)
    switch errCode
        case 100
            error('Undefined heuristic ID. Aborting!')
        case 101
            error('Undefined instance dataset. Aborting!')
        case 102
            error('Invalid input for constructor. Aborting!')
        otherwise
            error('Error code %d has not been defined yet. Aborting!', errCode)
    end
end
end