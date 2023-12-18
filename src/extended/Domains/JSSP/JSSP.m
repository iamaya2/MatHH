classdef JSSP < handle

    % JSSP   Class definition for the Job Shop Scheduling Problem (JSSP) 
    %  This class contains general properties and static methods for handling different
    %  aspects of the JSSP.
    % 
    %  Use doc JSSP for viewing properties and methods. Also, use help
    %  problemFeatures to check information about currently implemented
    %  features and help problemSolvers to check information about
    %  currently supported solvers.
    
    properties (Constant)
        % List of default feature IDs (those that do not rely on memory)
        defaultFeatureIDs = 1:5; 

        % Cell array containing a description of the available features and the IDs used for using them.
        %   Uses dictionary-style format for linking IDs and features:
        %       1:Mirsh222
        %       2:Mirsh15
        %       3:Mirsh29
        %       4:Mirsh282
        %       5:Mirsh95
        problemFeatures     = {'1:Mirsh222', '2:Mirsh15','3:Mirsh29','4:Mirsh282', '5:Mirsh95'}; 
        
        % Cell array containing a description of the available solvers and the IDs used for them.
        %   Uses dictionary-style format for linking IDs and solvers:
        %       1:LPT
        %       2:SPT
        %       3:MPA
        %       4:LPA
        problemSolvers      = {'1:LPT', '2:SPT','3:MPA','4:LPA'}; 
        
        % String with the name of the problem, i.e. JSSP, for
        % identification purposes.
        problemType         = 'JSSP'; 
    end

    %   
    %  JSSP Properties:
    %   instances - Dummy instance for indicating the class of objects
    %   associated with instances.
    %   problemFeatures - Cell array containing a description of the available
    %   features and the IDs used for using them.
    %   problemSolvers - Cell array containing a description of the available
    %   solvers and the IDs used for them.
    %   problemType - String with the name of the problem, i.e. JSSP
    %
    %  JSSP Static Methods:
    %  The following is a list of the non-standard static methods developed for
    %  this class:
    %   cloneInstance - 
    %   createDummyInstance - 
    %   exportInstanceAsText - 
    %   generateRandomInstances - 
    %   GetParameters - 
    %   getHeurID - 
    %   TailorInstances - 
    %   TailorInstancesFeat - 
    %   TailorInstances_Advanced - 
    %   loadSavedInstances - 
    %   heurLPA - 
    %   heurLPT - 
    %   heurMPA - 
    %   heurSPT - 
    %   stepHeuristic - 
    %   disp - 
    %    
    properties               
        % Dummy instance for indicating the class of objects associated with instances.
        instances;               
    end
    
    properties (Dependent)
%         features
%         fitness
    end
    
    methods
        function obj = JSSP()
            obj.instances           = JSSPInstance(); 
        end
        
    end
    
    
    methods (Static)

        function newInstance = cloneInstance(oldInstance)
            % cloneInstance   Static method for duplicating an instance. 
            %   Both of them (original and copy) are independent. It is
            %   recommended to do such a copy before solving an instance, as
            %   to preserve the original, unsolved, instance.
            %   - Inputs:            
            %      JSSPInstance: Original instance
            %   - Outputs:
            %      newInstance: The cloned instance
            %   See also JSSPINSTANCE.RESET, CREATEDUMMYINSTANCE,
            %   CREATEJSSPINSTANCEFROMINSTANCE
            newInstance = JSSPInstance();
            oldInstance.deepCopy(newInstance);
        end
        
        function instance = createDummyInstance()
            % createDummyInstance   Static method for creating an empty instance.
            %   This method can be used whenever an object with the class
            %   information is required. The method has no inputs and returns
            %   an empty JSSP instance.
            instance = JSSPInstance();
        end
        
        
        function exportInstanceAsText(instance, filePath)
            % exportInstanceAsText   Static method for exporting a JSSPInstance as a text file.
            %   This method exports the JSSPInstance object as a text file (for
            %   compatibility purposes). It uses the rawInstanceData property,
            %   which contains the hyper-matrix with the related info. 
            %   - Inputs:
            %     instance: The JSSPInstance object to export
            %     filePath: Path (including filename and extension) where
            %     the information will be written.
            % 
            %   This method has no outputs, as it writes directly to a file.
            if strcmp(instance.status,"Undefined")
                error('The instance is undefined and so it cannot be exported. Aborting...')
            else
                fprintf('Exporting instance... ')
                fileID = fopen(filePath,'w'); % Opens/creates file for output
                str = ''; str2 = '';
                for idx = 1 : length(instance.rawInstanceData(:,1,1))
                    str_    = sprintf('%.50f\t', instance.rawInstanceData(idx,:,1));
                    str2_   = sprintf('%s\t', num2str(instance.rawInstanceData(idx,:,2)));
                    str     = sprintf('%s%s\n', str, str_);
                    str2    = sprintf('%s%s\n', str2, str2_);
                end
                instanceText = sprintf('%s\n%s', str, str2);               
                fprintf(fileID, instanceText);
                fclose(fileID);
                fprintf('Success!\n')
            end        
        end
        
        function allInstances = generateRandomInstances(nbInstances, varargin)
            % generateRandomInstances   Statich method for creating random JSSPInstance objects.
            %   - Inputs:
            %     nbInstances - Number of instances to generate
            %     nbJobs - Number of jobs for each instance. Default value: 3.
            %     nbMachines - Number of machines for each instance. Default value: 4.
            %     timeRanges - Two-element vector (min, max) with the processing time 
            %       that each activity may take. Default value: [0 10].
            %     toSave - Flag for indicating if the instances will
            %       be also written to disk. If true, the method uses a
            %       self-built string using instance parameters and ending
            %       with the word 'Random'. Default value: true.
            %   - Outputs:
            %     allInstances - Cell array containing the JSSPInstances
            %     (one element per instance).
            %   Inputs must be given in the following order: 
            %     nbInstances, nbJobs, nbMachines, timeRanges, toSave
            %   If an input is not used, subsequent ones cannot be used
            %   either.
            if length(varargin) >= 1, nbJobs = varargin{1}; else, nbJobs =3; end
            if length(varargin) >= 2, nbMachines = varargin{2}; else, nbMachines =4; end
            if length(varargin) >= 3, timeRanges = varargin{3}; else,  timeRanges=[0 10]; end %must be an array of two elements
            if length(varargin) == 4, toSave = varargin{4}; else, toSave = true; end
            allInstances{nbInstances} = JSSPInstance(); % Dummy instance to allocate memory
            for idx = 1 : nbInstances
                fileName = sprintf('JSSPInstanceJ%dM%dT1%dT2%dRep%dRandom.mat', nbJobs,nbMachines,timeRanges(1),timeRanges(2),idx);
                instanceData = nan(nbJobs, nbMachines, 2);
                instanceData(:,:,1) = rand(nbJobs, nbMachines)*timeRanges(1);
                instanceData(:,:,2) = randi(nbMachines, nbJobs, nbMachines);
                instance = JSSPInstance(instanceData);
                if toSave, save(fileName, 'instance'); end % Saves variable named 'instance', if desired
                allInstances{idx} = instance;
            end
        end
        
        function Parameters = GetParameters(heurID, objective, varargin)
            % GetParameters   Static method for loading different parameters for
            % each case of instance generation.
            %   - Inputs:
            %      heurID - ID of the heuristic that will be the target for
            %      instance generation.
            %      objective - Whether the instance will be to favor (1) or
            %      hinder (2) heurID.
            %      generationFlag - Provide any value in this parameter for
            %      indicating that the instances will be generated seeking
            %      a fixed performance delta.
           if ~isempty(varargin) %if delta assignment
                if heurID==1 && objective ==1, [Parameters]=[10,1.5,1.5,0.1];end
                if heurID==1 && objective ==2, [Parameters]=[50,0.5,2.5,0.9];end
                if heurID==2 && objective ==1, [Parameters]=[50,1.5,2.5,0.5];end
                if heurID==2 && objective ==2, [Parameters]=[10,2.5,1.5,0.9];end
                if heurID==3 && objective ==1, [Parameters]=[10,1.5,1.5,0.1];end
                if heurID==3 && objective ==2, [Parameters]=[50,1.5,1.5,0.5];end
                if heurID==4 && objective ==1, [Parameters]=[10,2.5,2.5,0.9];end
                if heurID==4 && objective ==2, [Parameters]=[10,1.5,1.5,0.1];end 
           else    %if no delta assignment
                if heurID==1 && objective ==1, [Parameters]=[10,1.5,1.5,0.1];end
                if heurID==1 && objective ==2, [Parameters]=[50,0.5,2.5,0.9];end
                if heurID==2 && objective ==1, [Parameters]=[50,1.5,2.5,0.5];end
                if heurID==2 && objective ==2, [Parameters]=[10,2.5,1.5,0.9];end
                if heurID==3 && objective ==1, [Parameters]=[10,1.5,1.5,0.1];end
                if heurID==3 && objective ==2, [Parameters]=[50,1.5,1.5,0.5];end
                if heurID==4 && objective ==1, [Parameters]=[50,1.5,1.5,0.5];end
                if heurID==4 && objective ==2, [Parameters]=[50,2.5,1.5,0.5];end
           end
        end
        
       
            
        function vector = getHeurID(heurID)
            % getHeurID   Static method for generating the vector of IDs
            % for instance generation.
            %   - Inputs:
            %      heurID - The ID of the heuristic that will be targetted
            %   - Outputs:
            %      vector - Vector with an appropriate ordering for
            %      instance generation
         vector=[1 2 3 4];
%          index=find(vector==heurID)
         vector([1 heurID])= vector([heurID 1]);
%          vector(index)=[];
%          heurID=[heurID vector]
        end
        
        function allInstances = TailorInstances(nbInstances, InstanceKind, varargin)
            % TailorInstances   Static method for tailoring instances
            %   - Inputs:
            %      nbInstances - Number of instances that will be generated
            %      InstanceKind - Generation focus. 1: Relative heuristic
            %      performance; 2: Feature value
            %   - Variable inputs:
            %      If instanceKind == 1:
            %         1 - ID of the heuristic that will be targetted.
            %         2 - Objective of the generation. 1: Enhance; 2:
            %         Hinder
            %         3 - Folder for instance storage
            %         4 - Number of jobs (defaults to 3)
            %         5 - Number of machines (defaults to 4)
            %         6 - Range ([min, max]) of processing times for each
            %         activity (defaults to [0 10])
            %         7 - Save flag (defaults to true)
            %         8 - Target performance delta (if desired). If no
            %         delta is given, an instance with a maximum
            %         performance gap is sought                        
            %      If instanceKind == 2:
            %         1 - ID of the feature that will be targetted.
            %         2 - Desired normalized feature value \in [0, 1]
            %         3:7 - Same as for instanceKind == 1
            %         8 - Population size for UPSO (defaults to 50)
            %         9 - Self-confidence for UPSO (defaults to 1.5)
            %         10 - Global confidence for UPSO (defaults to 1.5)
            %         11 - Unifying factor for UPSO (defaults to 0.5)
            %   - Outputs:
            %      allInstances - Cell array with JSSPInstances (one
            %      instance per element)
            switch InstanceKind
                case 1 %AllvsOne/OnevsAll
                    if length(varargin) <1
                        heurID=input("You neeed to introduce an Heuristic ID (1: LPT, 2: SPT, 3: MPA, 4: LPA")
                    else
                        heurID=varargin{1};
                    end
                    if length(varargin) ==1
                        disp("No objective was introduced (1: Enhance heuristic performance, 2: Hinder heuristic performance), by default the generator will enhance heuristic performance")
                        objective=1;
                    elseif length(varargin) >=2
                        objective=varargin{2};
                    end
                    if length(varargin) >= 3, folder = varargin{3}; else, folder=pwd; end
                    if length(varargin) >= 4, nbJobs = varargin{4}; else, nbJobs =3; end
                    if length(varargin) >= 5, nbMachines = varargin{5}; else, nbMachines =4; end
                    if length(varargin) >= 6, timeRanges = varargin{6}; else,  timeRanges=[0 10]; end %must be an array of two elements
                    if length(varargin) >= 7, toSave = varargin{7}; else, toSave = true; end
                    if length(varargin) == 8
                        delta = varargin{8};
                        UPSOParameters=JSSP.GetParameters(heurID,objective,1);
                    else
                        UPSOParameters=JSSP.GetParameters(heurID,objective);
                    end
                    
                    population=UPSOParameters(1);
                    selfconf=UPSOParameters(2);
                    globalconf=UPSOParameters(3);
                    unifyfactor=UPSOParameters(4);
                    vector=JSSP.getHeurID(heurID);
                    
                    
                    allInstances = TaskManagerPrueba_Advanced(nbJobs,nbMachines,timeRanges,population,selfconf, globalconf,...
                        unifyfactor, nbInstances, vector, objective, folder);
                    
                case 2 %Feature Oriented
                    if length(varargin) <1
                        featID=input("You neeed to introduce an Feature ID (1: Mirsh175, 2: Mirsh15, 3: Mirsh29, 4: Mirsh282, 5: Mirsh95")
                    else
                        featID=varargin{1};
                    end
                    if length(varargin) ==1
                        disp("No target was introduced (target should be a value between 0 and 1), by default the generator will tailor instances with a feature target of 1")
                        target=1;
                    elseif length(varargin) >=2
                        target=varargin{2};
                    end
                    if length(varargin) >= 3, folder = varargin{3}; else, folder=pwd; end
                    if length(varargin) >= 4, nbJobs = varargin{4}; else, nbJobs =3; end
                    if length(varargin) >= 5, nbMachines = varargin{5}; else, nbMachines =4; end
                    if length(varargin) >= 6, timeRanges = varargin{6}; else,  timeRanges=[0 10]; end %must be an array of two elements
                    if length(varargin) >= 7, toSave = varargin{7}; else, toSave = true; end
                    if length(varargin) >= 8, population=varargin{8}; else, population=50; end
                    if length(varargin) >= 9, selfconf=varargin{9}; else, selfconf=1.5; end
                    if length(varargin) >= 10, globalconf=varargin{10}; else, globalconf=1.5; end
                    if length(varargin) == 11, unifyfactor=varargin{11}; else, unifyfactor=0.5; end
                    objective=3; %to find target value
                    
                    
                    allInstances= TaskManagerPrueba_Features(nbJobs,nbMachines,timeRanges,population,selfconf, globalconf,...
                        unifyfactor, nbInstances, featID,folder,objective,target);
                    for x=1:nbInstances
                        featValues(x)=normalizeFeature(CalculateFeature(allInstances{x},featID),featID);
                    end
                    disp("The reached values are:")
                    disp(featValues)
                otherwise
                    disp("function has not been implemented yet")
            end
        end
        
        function allInstances = TailorInstancesFeat(nbInstances, featID, objective, target, varargin)
            % TailorInstancesFeat   Internal function used by TailorInstances
            % TO-DO: Check this with Alonso
            % See also: TAILORINSTANCES
            if length(varargin) >= 1, folder = varargin{1}; else, folder=pwd; end
            if length(varargin) >= 2, nbJobs = varargin{2}; else, nbJobs =3; end
            if length(varargin) >= 3, nbMachines = varargin{3}; else, nbMachines =4; end
            if length(varargin) >= 4, timeRanges = varargin{4}; else,  timeRanges=[0 10]; end %must be an array of two elements
            if length(varargin) >= 5, toSave = varargin{5}; else, toSave = true; end
            if length(varargin) >= 6, population=varargin{6}; else, population=50; end
            if length(varargin) >= 7, selfconf=varargin{7}; else, selfconf=1.5; end
            if length(varargin) >= 8, globalconf=varargin{8}; else, globalconf=1.5; end
            if length(varargin) == 9, unifyfactor=varargin{9}; else, unifyfactor=0.5; end
            objective=3; %to find target value
            
            
            allInstances= TaskManagerPrueba_Features(nbJobs,nbMachines,timeRanges,population,selfconf, globalconf,...
                            unifyfactor, nbInstances, featID,folder,objective,target);
            for x=1:nbInstances 
                featValues(x)=normalizeFeature(CalculateFeature(allInstances{x},featID),featID);
            end
            disp("The reached values are:")
            disp(featValues)
           
        end
        
        
        function allInstances = TailorInstances_Advanced(nbInstances,  heurID, objective, varargin)
        
         if length(varargin) >= 1, nbJobs = varargin{1}; else, nbJobs =3; end
         if length(varargin) >= 2, nbMachines = varargin{2}; else, nbMachines =4; end
         if length(varargin) >= 3, timeRanges = varargin{3}; else,  timeRanges=[0 10]; end %must be an array of two elements
         if length(varargin) >= 4, toSave = varargin{4}; else, toSave = true; end
          if length(varargin) >= 5, folder = varargin{5}; else, folder=pwd; end
         if length(varargin) == 6
             delta = varargin{6};
             Parameters=JSSP.GetParameters(heurID,objective,1);
         else
             Parameters=JSSP.GetParameters(heurID,objective);
         end
         
         population=Parameters(1);
         selfconf=Parameters(2);
         globalconf=Parameters(3);
         unifyfactor=Parameters(4);
         vector=JSSP.getHeurID(heurID);

         
         allInstances = TaskManagerPrueba_Advanced(nbJobs,nbMachines,timeRanges,population,selfconf, globalconf,...
                            unifyfactor, nbInstances, vector, objective, folder);
         
                      
             for x=1:nbInstances 
                    makespanValues(x)=makespan(allInstances{x},heurID);
             end
            disp("The instances makespan are:")
            disp(makespanValues)               
             %if toSave, save(fileName, 'instance')
         end
        
        
        
        function allInstances = loadSavedInstances(nbInstances,varargin)
            % Not yet supported!
            % TO-DO: Change this method for one using JSSPs. This one is for balanced partition    
            nbElements = varargin{1}; nbBitsPerElement = varargin{2}; baseFileName = varargin{3};
            allInstances{nbInstances} = BPInstance(); 
            for idx = 1 : nbInstances
                fileName = sprintf('GeneratedBPInstance_%s_%dElem_%dBits_Inst%d.mat',baseFileName, nbElements,nbBitsPerElement,idx);
                %instance = BPInstance('l', fileName); 
                instance = load('-mat', fileName);
                allInstances{idx} = instance.instance;
%                 load('-mat', fileName);
%                 allInstances{idx} = instance;
            end
        end
        
        function heurLPA(instance,objective, varargin) 
            % heurLPA   Static method for the LPA heuristic
            %  This method tackles the JSSPInstance object directly. So, it
            %  is strongly advised to clone the instance before solving it.
            %  Conversely, you may reset the instance after solving it.
            %   - Inputs:
            %      instance - The instance upon which the heuristic will be
            %      used
            %      objective - Solution approach (1: step, 2: solve)
            %   - Variable inputs:
            %      1 - Plot flag (defaults to false)
            %   - Outputs:   
            %      None - The object itself is modified
            % See also: JSSPINSTANCE.RESET, CLONEINSTANCE
            toPlot = false;
            if nargin == 3, toPlot = varargin{1}; end
            
            switch objective
                case 1
                    JSSPStepInstance(instance, 4, toPlot)
                case 2
                    JSSPSolveInstance(instance, 4, toPlot)
                otherwise
                    disp("objective must be either 1 or 2")
            end
        end
        
        function heurMPA(instance,objective, varargin) 
            % heurMPA   Static method for the MPA heuristic
            %  This method tackles the JSSPInstance object directly. So, it
            %  is strongly advised to clone the instance before solving it.
            %  Conversely, you may reset the instance after solving it.
            %   - Inputs:
            %      instance - The instance upon which the heuristic will be
            %      used
            %      objective - Solution approach (1: step, 2: solve)
            %   - Variable inputs:
            %      1 - Plot flag (defaults to false)
            %   - Outputs:   
            %      None - The object itself is modified
            % See also: JSSPINSTANCE.RESET, CLONEINSTANCE            
            toPlot = false;
            if nargin == 3, toPlot = varargin{1}; end
            
            switch objective
                case 1
                    JSSPStepInstance(instance, 3, toPlot)
                case 2
                    JSSPSolveInstance(instance, 3, toPlot)
                otherwise
                    disp("objective must be either 1 or 2")
            end
        end
        
        function heurSPT(instance,objective, varargin) 
            % heurSPT   Static method for the SPT heuristic
            %  This method tackles the JSSPInstance object directly. So, it
            %  is strongly advised to clone the instance before solving it.
            %  Conversely, you may reset the instance after solving it.
            %   - Inputs:
            %      instance - The instance upon which the heuristic will be
            %      used
            %      objective - Solution approach (1: step, 2: solve)
            %   - Variable inputs:
            %      1 - Plot flag (defaults to false)
            %   - Outputs:   
            %      None - The object itself is modified
            % See also: JSSPINSTANCE.RESET, CLONEINSTANCE            
            toPlot = false;
            if nargin == 3, toPlot = varargin{1}; end
            
            switch objective
                case 1
                    JSSPStepInstance(instance, 2, toPlot)
                case 2
                    JSSPSolveInstance(instance, 2, toPlot)
                otherwise
                    disp("objective must be either 1 or 2")
            end
        end
        
        function heurLPT(instance,objective, varargin) 
            % heurLPT   Static method for the LPT heuristic
            %  This method tackles the JSSPInstance object directly. So, it
            %  is strongly advised to clone the instance before solving it.
            %  Conversely, you may reset the instance after solving it.
            %   - Inputs:
            %      instance - The instance upon which the heuristic will be
            %      used
            %      objective - Solution approach (1: step, 2: solve)
            %   - Variable inputs:
            %      1 - Plot flag (defaults to false)
            %   - Outputs:   
            %      None - The object itself is modified
            % See also: JSSPINSTANCE.RESET, CLONEINSTANCE            
            toPlot = false;
            if nargin == 3, toPlot = varargin{1}; end
            
            switch objective
                case 1
                    JSSPStepInstance(instance, 1, toPlot)
                case 2
                    JSSPSolveInstance(instance, 1, toPlot)
                otherwise
                    disp("objective must be either 1 or 2")
            end
        end
        
        function stepHeuristic(instance, heurID, varargin)
            % stepHeuristic   Static method for advancing one step of the solution with a given heuristic
            %  This method uses a heuristic for stepping on the solution of
            %  a given instance.
            %   - Inputs:
            %      instance - JSSPInstance object that will be partially
            %      solved.
            %      heurID - ID of the heuristic that will be used for the
            %      step.
            %   - Variable inputs: 
            %      1 - Plotting flag (defaults to false)
            %   - Outputs: 
            %      None. This method modifies the instance object directly.
            %  See also: HEURLPA, HEURLPT, HEURMPA, HEURSPT
            toPlot = false;
            if nargin == 3, toPlot = varargin{1}; end
            JSSPStepInstance(instance, heurID, toPlot)
        end
        
        
        function s = disp()
            % disp   Overload of the disp() function
            %  This method returns a string with the full name of the
            %  domain, i.e. Job Shop Scheduling Problem.
            s = sprintf('Job Shop Scheduling Problem');
        end
        
    end        
end