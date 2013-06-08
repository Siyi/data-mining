function [accred]=tenclass(trainset,test,classf,tile,num_add,times,c,g)
%clear
%clc
%load('trainset.mat');

%load('train.mat');
%load('testset.mat');
%load('classf.mat');
%trainset=train;
%tile=2;
%num_add=30;
%test=testset;

%% buil initail training set

topuse=classf.best(1:10);
trainset.x=trainset.x(:,topuse);
testset=test(tile).x(:,topuse);
test_lab=test(tile).y;
test_lab2=test_lab;
testset2=testset;
initial=trainset.x;
ilabel=double(trainset.y);
%total=size(testset,1);

%%
for i=1:times
    if(i==1)       
       indices(i).last = crossvalind('Kfold',ilabel,10);
       
       for tencross=1:10
           testcross=(indices(i).last==tencross);
           traincross=~testcross; 
           % libsvm
           model=libsvmtrain(ilabel(traincross),initial(traincross,:),sprintf('-t 2 -c %f -g %f',c,g));
         
           place=find(testcross);
           [predict_label,accuracy,dec_values]=libsvmpredict(ilabel(testcross),initial(testcross,:),model);
           classes(i).predict(place)=predict_label;
           
           %test on the testset               
           model2=libsvmtrain(ilabel(testcross),initial(testcross,:),sprintf('-t 2 -c %f -g %f',c,g));
           [pre,accuracy,dec_values]=libsvmpredict(test_lab2,testset2,model2);
               predict_lab(tencross).pre=pre;
       end
          
       
         model=libsvmtrain(ilabel,initial,sprintf('-t 2 -c %f -g %f',c,g));
        [predict_label,accuracy,dec_values]=libsvmpredict(test_lab,testset,model);
        accred(i)=accuracy(1);
                 
        ip=find(ilabel);
        ncp=size(ip,1);
        ncn=size(ilabel,1)-ncp;
        
        %ind_add=randi(size(testset,1),num_add,1);      
        
        %% test on the left testset
        % model=libsvmtrain(ilabel,initial,'-t 2 -c 1 -g 1');
        %[testpredictLeft,accuracy,dec_values]=libsvmpredict(test_lab2,testset2,model);
        
        ind_add=[];
         for j=1:size(testset2,1)
             if(size(ind_add,1)>=num_add)
                 break;
             end
             pred=[];
            for k=1:10    
               pred=[pred;predict_lab(k).pre(j)];
            end
            major=length(find(pred));
            if(major>5)
                 
                part_p=find(ilabel==1);
                part_n=find(ilabel==0);
                
                avg_pp=getAvg(testset2(j,:),initial(part_p,:));
                avg_pn=getAvg(testset2(j,:),initial(part_n,:));
                d_p=avg_pn-avg_pp;
                if(d_p<0)
                    continue;
                end
                
                
                initial=[initial;testset2(j,:)];
                ilabel=[ilabel;1];
                ind_add=[ind_add;j];
                
            end
            if(major<5)
                part_p=find(ilabel==1);
                part_n=find(ilabel==0);
                
                avg_np=getAvg(testset2(j,:),initial(part_p,:));
                avg_nn=getAvg(testset2(j,:),initial(part_n,:));
                d_n=avg_np-avg_nn;
                if(d_n<0)
                    continue;
                end
                                
                
                initial=[initial;testset2(j,:)];
                ilabel=[ilabel;0];
                ind_add=[ind_add;j];
            end
           clear pred;
         end
                  
      
        index=ismember(1:size(test_lab2,1),ind_add);
        index=~index;
        test_lab2=test_lab2(index);
        testset2=testset2(index,:);
        
                       
    else
        %if 0
        redistrict_p=0;
        redistrict_n=0;
        
        %% ten cross validation
           if(i==2)
               indic= crossvalind('Kfold',ilabel((size(ilabel,1)-num_add+1):size(ilabel,1)),10);     
           else
               indic= crossvalind('Kfold',ilabel((size(ilabel,1)-flag_p-flag_n+1):size(ilabel,1)),10);     
           end
           
           indices(i).last=[indices(i-1).last;indic];
       
       for tencross=1:10
           testcross=(indices(i).last==tencross);
           traincross=~testcross;
           
            model=libsvmtrain(ilabel(traincross),initial(traincross,:),sprintf('-t 2 -c %f -g %f',c,g));
         
           place=find(testcross);
           [predict_label,accuracy,dec_values]=libsvmpredict(ilabel(testcross),initial(testcross,:),model);
           classes(i).predict(place)=predict_label;
           
           model2=libsvmtrain(ilabel(testcross),initial(testcross,:),sprintf('-t 2 -c %f -g %f',c,g));
            [predict_lab(i).pre,accuracy,dec_values]=libsvmpredict(test_lab2,testset2,model2);
             predict_lab(tencross).pre=pre;
          
       end
        
        
        model=libsvmtrain(ilabel,initial,sprintf('-t 2 -c %f -g %f',c,g));
        [predict_label,accuracy,dec_values]=libsvmpredict(test_lab,testset,model);
        accred(i)=accuracy(1);
             
        %num=size(classes(i-1).predict,2)
         num=length(classes(i-1).predict)
        for q=1:num
             if(classes(i-1).predict(q)~=classes(i).predict(q))
                 if(ilabel(q)==1)
                     redistrict_p=redistrict_p+1;
                 else
                   
                     redistrict_n=redistrict_n+1;
                 end
             end
        end
        
         if((redistrict_p==0)&&(redistrict_n==0))
             
              addp=round(num_add/2);
              addn=num_add-addp;
         else
            addp=round((redistrict_p/ncp)/(redistrict_p/ncp+redistrict_n/ncn)*num_add);
            addn=num_add-addp;
         end
         
          ip=find(ilabel);
          ncp=size(ip,1);
          ncn=size(ilabel,1)-ncp;
        %% test on the left testset
        
          flag_p=0;
          flag_n=0;
         ind_add=[];
         for j=1:size(testset2,1)
             if(size(ind_add,1)>=num_add)
                 break;
             end
             pred=[];
            for k=1:10    
               pred=[pred;predict_lab(k).pre(j)];
            end
            
            %major=size(find(pred),1);
            major=length(find(pred));
            
            if(major>5)
                if(flag_p>addp)
                    continue;
                end
                part_p=find(ilabel==1);
                part_n=find(ilabel==0);
                
                avg_pp=getAvg(testset2(j,:),initial(part_p,:));
                avg_pn=getAvg(testset2(j,:),initial(part_n,:));
                d_p=avg_pn-avg_pp;
                if(d_p<0)
                    continue;
                end
                    
                
                initial=[initial;testset2(j,:)];
                ilabel=[ilabel;1];
                ind_add=[ind_add;j];
                flag_p=flag_p+1;
                
                
            end
            if(major<5)
                if(flag_n>addn)
                    continue;
                end
                part_p=find(ilabel==1);
                part_n=find(ilabel==0);
                
                avg_np=getAvg(testset2(j,:),initial(part_p,:));
                avg_nn=getAvg(testset2(j,:),initial(part_n,:));
                d_n=avg_np-avg_nn;
                if(d_n<0)
                    continue;
                end
                                  
                initial=[initial;testset2(j,:)];
                ilabel=[ilabel;0];
                ind_add=[ind_add;j];
                flag_n=flag_n+1;
            end
           clear pred;
         end
                  
      
        index=ismember(1:size(test_lab2,1),ind_add);
        index=~index;
        test_lab2=test_lab2(index);
        testset2=testset2(index,:);
         
      
    end
         
end

%nam=test(tile).id;
%filename=['./' nam '/tenclass.mat'];
%save(filename,'accred');

%% for sammons map
train.x=initial;
train.y=ilabel;

nam=test(tile).id;
filename=['./' nam '/train_tenclass.mat'];
save(filename,'train');
