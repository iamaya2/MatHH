function[FeatureValue] = Mirsh95(JSSPInstance)
    InstanceData=JSSPInstance.updatingData;
        for y=1:size(InstanceData(:,:,1),2) %repeat for each operation slot 
            iRep=0;
            for x=1:JSSPInstance.nbJobs-1 %repeat for each activity on the operation slot
               bN=true; %indicates if a machine has appeared for the first time                
               RepeatedMachines=[];
               if x>1  %testing after the first machine
                    for z=x-1:-1:1 %looking if this machine has not appeared before
                        if InstanceData(z,y,2)==InstanceData(x,y,2) & InstanceData(x,y,2)~=0 %testing if the machine has appeared before 
                            bN=false; %this machineID has been already processed
                        end
                    end
                    if bN==true %Testing if this machine has not appeared before
                        for a=x+1:JSSPInstance.nbJobs %Compare to the next machines until the last one
                            if InstanceData(a,y,2)==InstanceData(x,y,2) & InstanceData(x,y,2)~=0%testing if the machine has a repetition 
                                iRep=iRep+1; %adding a repetition                              
                            end
                        end
                     end
               else   
                   for a=x+1:JSSPInstance.nbJobs%Compare to the next machines until the last one
                            if InstanceData(a,y,2)==InstanceData(x,y,2) & InstanceData(x,y,2)~=0%testing if the machine has a repetition 
                                iRep=iRep+1;%adding a repetition
                            end
                   end
               end
            end
            iRep = (iRep*(iRep+1))/2;
            OSRMA(y)=iRep;
        end
       
      
       
        
        
        FeatureValue=(mean(OSRMA)/(JSSPInstance.nbMachines));

end