function[FeatureValue] = Mirsh29(JSSPInstance)
 InstanceData=JSSPInstance.updatingData;

 for a=1:size(InstanceData(:,:,1),2)
     subMPT=0;
     for c=1:JSSPInstance.nbJobs
                     for d=1:size(InstanceData(:,:,1),2)
                            if InstanceData(c,d,2)==a 
                                subMPT=subMPT+ InstanceData(c,d,1);
                            end    
                     end
  
     end
     MPT(a)=subMPT;
 end
          FeatureValue=(std(MPT)/mean(MPT));  

end