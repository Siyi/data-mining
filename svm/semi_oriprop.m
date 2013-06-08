function [accred]=semi_oriprop(trainset,test,classf,tile,num_add,times,c,g)
%clear
%clc
%load('trainset.mat');
%load('train.mat');
%load('testset.mat');
%load('classf.mat');

%tile=2;
%num_add=30;
%test=testset;
%trainset=train;

%% buil initail training set

topuse=classf.best(1:10);
trainset.x=trainset.x(:,topuse);
testset=test(tile).x(:,topuse);
test_lab=test(tile).y;
test_lab2=test_lab;
testset2=testset;
initial=trainset.x;
ilabel=double(trainset.y);
%total=size(testset,1)
ntr_p=size(find(ilabel==1),1);
ntr_n=size(ilabel,1)-ntr_p;

%%
for i=1:times
    
      
        %% ten cross validation
                 
                
        model=libsvmtrain(ilabel,initial,sprintf('-t 2 -c %f -g %f',c,g));
        [predict_label,accuracy,dec_values]=libsvmpredict(test_lab,testset,model);
        accred(i)=accuracy(1);
             
         [predict_labelLeft,accuracy,dec_values]=libsvmpredict(test_lab2,testset2,model);
         ind_p=find(predict_labelLeft==1);
         ind_n=find(predict_labelLeft==0);
         testset_p=testset2(ind_p,:);
         testset_n=testset2(ind_n,:);
         test_lab2_p=test_lab2(ind_p,:);
         test_lab2_n=test_lab2(ind_n,:);
         
         addp=round(ntr_p/(ntr_p+ntr_n)*num_add);
         addn=num_add-addp;
         if(addp>size(testset_p,1))
             break;
         end
         if(addn>size(testset_n,1))
             break;
         end
         
         pailie2=randperm(size(testset_p,1));
         ind_add_p=pailie2(1:addp);
         
         pailie3=randperm(size(testset_n,1));
         ind_add_n=pailie3(1:addn);
         
         
         initial=[initial;testset_p(ind_add_p,:);testset_n(ind_add_n,:)];
         ilabel=[ilabel;ones(addp,1);zeros(addn,1)];
             
       
         index_p=ismember(1:size(testset_p,1),ind_add_p);
         index_n=ismember(1:size(testset_n,1),ind_add_n);
         index_p=~index_p;
         index_n=~index_n;
         
          test_lab2=[test_lab2_p(index_p,:);test_lab2_n(index_n,:)];
          testset2=[testset_p(index_p,:);testset_n(index_n,:)];
        
         
end

train.x=initial;
train.y=ilabel;


nam=test(tile).id;
%filename=['./' nam '/oriprop.mat'];
%save(filename,'accred');
filename=['./' nam '/train_ori.mat'];
save(filename,'train');

