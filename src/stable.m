function [accred]=stable(trainset,test,classf,tile,num_add,times,c,g)
%clear
%clc
%load('trainset.mat');
%load('testset.mat');
%load('classf.mat');

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
       end
          
         model=libsvmtrain(ilabel,initial,sprintf('-t 2 -c %f -g %f',c,g));
        [predict_label,accuracy,dec_values]=libsvmpredict(test_lab,testset,model);
        accred(i)=accuracy(1);
                 
        ip=find(ilabel);
        ncp=size(ip,1);
        ncn=size(ilabel,1)-ncp;
        
        pailie=randperm(size(testset,1));
        %ind_add=randi(size(testset,1),num_add,1);
        ind_add=pailie(1:num_add);
       
        
        %% test on the left testset
         model=libsvmtrain(ilabel,initial,sprintf('-t 2 -c %f -g %f',c,g));
        [testpredictLeft,accuracy,dec_values]=libsvmpredict(test_lab2,testset2,model);
             
        initial=[initial;testset2(ind_add,:)];
        ilabel=[ilabel;testpredictLeft(ind_add)];
        
        %testset2=setdiff(testset2,testset2(ind_add,:),'rows');
        index=ismember(1:size(test_lab2,1),ind_add);
        index=~index;
        test_lab2=test_lab2(index);
        testset2=testset2(index,:);
        
                       
    else
        redistrict_p=0;
        redistrict_n=0;
        
        %% ten cross validation
           if(i==2)
               indic= crossvalind('Kfold',ilabel((size(ilabel,1)-num_add+1):size(ilabel,1)),10);    
           else
               indic= crossvalind('Kfold',ilabel((size(ilabel,1)-addp-addn+1):size(ilabel,1)),10);     
           end
           
           indices(i).last=[indices(i-1).last;indic];
       
       for tencross=1:10
           testcross=(indices(i).last==tencross);
           traincross=~testcross;
           
            model=libsvmtrain(ilabel(traincross),initial(traincross,:),sprintf('-t 2 -c %f -g %f',c,g));
         
           place=find(testcross);
           [predict_label,accuracy,dec_values]=libsvmpredict(ilabel(testcross),initial(testcross,:),model);
           classes(i).predict(place)=predict_label;
           
          
       end
        
        
        model=libsvmtrain(ilabel,initial,sprintf('-t 2 -c %f -g %f',c,g));
        [predict_label,accuracy,dec_values]=libsvmpredict(test_lab,testset,model);
        accred(i)=accuracy(1);
             
        num=size(classes(i-1).predict,2)

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
            addp=round((redistrict_p/ncp)/(redistrict_p/ncp+redistrict_n/ncn)*num_add)+1;
            addn=num_add-addp;
         end
         
          ip=find(ilabel);
          ncp=size(ip,1);
          ncn=size(ilabel,1)-ncp;
        %% test on the left testset
        
        
         model=libsvmtrain(ilabel,initial,sprintf('-t 2 -c %f -g %f',c,g));
        [testpredictLeft,accuracy,dec_values]=libsvmpredict(test_lab2,testset2,model);
        
         ind_p=find(testpredictLeft==1);
         ind_n=find(testpredictLeft==0);
         testset_p=testset2(ind_p,:);
         testset_n=testset2(ind_n,:);
         test_lab2_p=test_lab2(ind_p,:);
         test_lab2_n=test_lab2(ind_n,:);
         
          if (size(testset_p,1)<addp)
            addp=size(testset_p,1);
         end
         if(size(testset_p,1)==0);
             addp=0;
              pailie3=randperm(size(testset_n,1));   
             ind_add_n=pailie3(1:addn);
            initial=[initial;testset_n(ind_add_n,:)];
             ilabel=[ilabel;zeros(addn,1)];
             
        %testset2=setdiff(testset2,testset2(ind_add,:),'rows');
            
             index_n=ismember(1:size(testset_n,1),ind_add_n);
            
             index_n=~index_n;
         
             test_lab2=[test_lab2_p;test_lab2_n(index_n,:)];
             testset2=[testset_p;testset_n(index_n,:)]; 
             continue;
          end
         
         
         pailie2=randperm(size(testset_p,1));        
         ind_add_p=pailie2(1:addp);
         
         if (size(testset_n,1)<addn)
            addn=size(testset_n,1);
         end
         
         if(size(testset_n,1)==0);
             addn=0;    
            initial=[initial;testset_p(ind_add_p,:)];
             ilabel=[ilabel;ones(addp,1)];
             
        %testset2=setdiff(testset2,testset2(ind_add,:),'rows');
            index_p=ismember(1:size(testset_p,1),ind_add_p);
            index_p=~index_p;
                
            test_lab2=[test_lab2_p(index_p,:);test_lab2_n];
            testset2=[testset_p(index_p,:);testset_n];
                   
         else
             pailie3=randperm(size(testset_n,1));   
             ind_add_n=pailie3(1:addn);
            
             initial=[initial;testset_p(ind_add_p,:);testset_n(ind_add_n,:)];
             ilabel=[ilabel;ones(addp,1);zeros(addn,1)];
             
        %testset2=setdiff(testset2,testset2(ind_add,:),'rows');
             index_p=ismember(1:size(testset_p,1),ind_add_p);
             index_n=ismember(1:size(testset_n,1),ind_add_n);
             index_p=~index_p;
             index_n=~index_n;
         
             test_lab2=[test_lab2_p(index_p,:);test_lab2_n(index_n,:)];
             testset2=[testset_p(index_p,:);testset_n(index_n,:)];
         end
      
    end
         
end

%nam=test(tile).id;
%filename=['./' nam '/stable.mat'];
%save(filename,'accred');

%% for sammons map
train.x=initial;
train.y=ilabel;

nam=test(tile).id;
filename=['./' nam '/train_stable.mat'];
save(filename,'train');
