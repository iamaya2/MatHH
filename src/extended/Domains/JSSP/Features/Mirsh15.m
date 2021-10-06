function[FeatureValue] = Mirsh15(JSSPInstance)
 InstanceData=JSSPInstance.updatingData;
 for c=1:JSSPInstance.nbJobs
     subJPT=0;
            for d=1:size(InstanceData(:,:,1),2)
                subJPT=subJPT+InstanceData(c,d,1);
            end
     JPT(c)=subJPT;
 end
      FeatureValue=(std(JPT)/mean(JPT));  

end