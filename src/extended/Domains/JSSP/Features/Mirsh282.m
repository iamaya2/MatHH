function[FeatureValue] = Mirsh282(JSSPInstance)

 InstanceData=JSSPInstance.updatingData;
 
  for a=1:size(InstanceData(:,:,1),2)
     subML=0;
     iZeros=0;
     for c=1:size(InstanceData(:,:,1),2)
         iRep=0;
                     for d=1:JSSPInstance.nbJobs
                            if InstanceData(d,c,2)==a 
                                iRep=iRep+1;
                            end    
                     end
         subML(c)=iRep;            
  
     end
     for x=1:length(subML)
         if subML(x)==0
             iZeros=iZeros+1;
         end
     end
     iZeros = (iZeros*(iZeros+1))/2;
     ML(a)=iZeros;
     
  end
FeatureValue= mean(ML)/size(InstanceData(:,:,1),2);
  
  