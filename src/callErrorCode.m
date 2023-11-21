function callErrorCode(errCode)
% callErrorCode   Script that prints an error/warning for facilitating
% feedback. The following codes have been defined:
%
% ---\ Warnings (0-99):
%     ---\ 0: Method/script is currently being developed (a.k.a WIP).
%     ---\ 1: HH is outdated. Requires call to initializeModel method.
%     ---\ 2: Method should be overloaded in subclass.
%     ---\ 3: Method is deprecated. Consider upgrading to unified version.
% ---\ Errors (100+):
%     ---\ 100: Undefined heuristic ID.
%     ---\ 101: Undefined instance dataset.
%     ---\ 102: Invalid input for constructor.
%     ---\ 103: Failed equality test.
%     ---\ 104: Failed independence test.
%     ---\ 105: Failed logic test.
%     ---\ 106: Memory size (for HH) not properly defined.
if errCode < 100
    warning('Warning code %d detected. The following issue has occurred: ', errCode)
    switch errCode
        case 0
            warning('WIP. This method has not been implemented yet. Behaviour might be erratic. Proceed with caution...')
        case 1
            warning('The HH has not been initialized to reflect the latest changes in feature or solver subset. Please use the initializeModel method to regenerate the model for a given number of rules.')
        case 2
            warning('This method is not intended for direct use. It should be overloaded by a subclass.')
        case 3
            warning('This method has been deprecated because it has been unified into a single name. Please consider upgrading your code to the new method.')
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
        case 103
            error('Equality test failed to pass (objects are not equal when they should be, or they are equal when they should not). Aborting!')    
        case 104
            error('Independence test failed to pass (objects are not independent when they should be, or they are independent when they should not). Aborting!')
		case 105
            error('Logic test failed to pass (check argument given in logic test). Aborting!')
        case 106
            error('The memory size (for the HH) has not been properly defined. Aborting!')
        otherwise
            error('Error code %d has not been defined yet. Aborting!', errCode)
    end
end
end