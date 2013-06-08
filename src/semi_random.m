function [accred]=semi_random(trainset,test,classf,tile,num_add,times,c,g)
%clear
%clc
%load('trainset.mat');
%load('testset.mat');
%load('classf.mat');


%tile=2;
%num_add=30;
%test=testset;
%train=trainset;

%% buil initail training set

topuse=classf.best(1:10);
trainset.x=trainset.x(:,topuse);
testset=test(tile).x(:,topuse);
testset2=testset;
test_lab=test(tile).y;
test_lab2=test_lab;
initial=trainset.x;
ilabel=double(trainset.y);

%%
for i=1:times
        model=libsvmtrain(ilabel,initial,sprintf('-t 2 -c %f -g %f',c,g));
       
         [predict_label,accuracy,dec_values]=libsvmpredict(test_lab,testset,model);
        accred(i)=accuracy(1);
        
        [predict_label,accuracy,dec_values]=libsvmpredict(test_lab2,testset2,model);
        pailie=randperm(size(testset2,1));   
        ind_add=pailie(1:num_add);
     
        initial=[initial;testset2(ind_add,:)];
     
        ilabel=[ilabel;predict_label(ind_add)];
      
        
        index=ismember(1:size(test_lab2,1),ind_add);
        index=~index;
        test_lab2=test_lab2(index);
        testset2=testset2(index,:);
                       
end

%% for sammons map
train.x=initial;
train.y=ilabel;

nam=test(tile).id;
filename=['./' nam '/train_random.mat'];
save(filename,'train');

