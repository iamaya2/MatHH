function[FeatureValue] = Mirsh222(JSSPInstance)
    InstanceData=JSSPInstance.updatingData;
        for y=1:size(InstanceData(:,:,1),2) %repeat for each operation slot
            subOSCOMBA=0;
            for x=1:JSSPInstance.nbJobs-1 %repeat for each activity on the operation slot
               bN=true; %indicates if a machine has appeared for the first time 
               iRep=0;
               RepeatedMachines=[];
               if x>1  %testing after the first machine
                    for z=x-1:-1:1 %looking if this machine has not appeared before
                        if InstanceData(z,y,2)==InstanceData(x,y,2) & InstanceData(x,y,2)~=0%testing if the machine has appeared before 
                            bN=false; %this machineID has been already processed
                        end
                    end
                    if bN==true %Testing if this machine has not appeared befor
                        for a=x+1:JSSPInstance.nbJobs %Compare to the next machines until the last one
                            if InstanceData(a,y,2)==InstanceData(x,y,2)& InstanceData(x,y,2)~=0%testing if the machine has a repetition 
                                iRep=iRep+1; %adding a repetition
                                RepeatedMachines(iRep)=a; %saving the index of repeated machine
                            end
                        end
                     end
               else   
                   for a=x+1:JSSPInstance.nbJobs%Compare to the next machines until the last one
                            if InstanceData(a,y,2)==InstanceData(x,y,2)& InstanceData(x,y,2)~=0%testing if the machine has a repetition 
                                iRep=iRep+1;%adding a repetition
                                RepeatedMachines(iRep)=a; %saving the index of repeated machine
                            end
                   end
               end

               if iRep>0 %Proceed to calculate the value of subOSCOMBA if machine of index x if has at least one repetition
                 OpValues(1)=InstanceData(x,y,1); %the first OpValue corresponds to the location of the x machine
                 for b=1:length(RepeatedMachines) %appending the OpValues of the repetitions
                   OpValues(b+1)=InstanceData(RepeatedMachines(b),y,1); %appending in the corresponding indexes
                 end
                 ampRep = (iRep*(iRep+1))/2;%Calculating the amplified value of repetitions
                 subOSCOMBA=subOSCOMBA + ampRep*(mean(OpValues));
               end

            end
            OSCOMBA(y)=subOSCOMBA;
        end
       
        %the next loops is to add all Operation Processing Times
        OPT=0;
        for c=1:size(InstanceData(:,:,1),2)
            for d=1:JSSPInstance.nbJobs
                OPT= OPT + InstanceData(d,c,1);
            end
        end
        calls=0;
        for d=1:length(JSSPInstance.jobRegister)
            calls=calls+JSSPInstance.jobRegister(d);
        end
        meanOPT = OPT/(size(InstanceData(:,:,1),2)*JSSPInstance.nbJobs-calls);
        
        
        FeatureValue=(mean(OSCOMBA)/(size(InstanceData(:,:,1),2)*meanOPT));

end