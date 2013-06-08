clear
clc
load('trainset.mat');
%load('test.mat');
load('testset.mat');
load('classf.mat');
%options = optimset('maxiter',1000,'largescale','off');
train=trainset;
test=testset;
tile=3;
%num_add=50;

%% build initail training set

topuse=classf.best(1:10);
train.x=train.x(:,topuse);
testset=test(tile).x(:,topuse);

test_lab=test(tile).y;
test_lab2=test_lab;
testset2=testset;
initial=train.x;
ilabel=double(train.y);
total=size(testset,1);
  best=0;
%% only on the trainingset
c=2^(-5);

for i=1:10
    c=c*2^2;
    %train
    %c=0.500000; 
    %trainset
    %c=8.000000;
      g=2^(-15);
    for j=1:9
      g=g*2^2;
      %train,trainset
      %g=0.000122;
    
    model=libsvmtrain(ilabel,initial,sprintf('-t 2 -c %f -g %f',c,g));
    [predict_label,accuracy,dec_values]=libsvmpredict(test_lab,testset,model); 
  
        if(accuracy(1)>best)
            best=accuracy(1);
            fprintf(1, '%f, %f\n', c,g);
        end
        
    end
end



%%


%nam=test(tile).id;
%filename=['./' nam '/Redistrict.mat'];
%save(filename,'accred');

