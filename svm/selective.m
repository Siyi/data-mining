clear all
clc
load('train.mat');

load('testset.mat');
load('classf.mat');
trainset=train;
tile=2;
num_candi=size(testset(tile).x,1);
num_add=50;
%c=0.5;
c=8;
g=0.000122;
%times=floor(num_candi/num_add)-1;
times=floor(num_candi/(2*num_add))-1;
for j=1:1
   [accred]=semi_random(trainset,testset,classf,tile,num_add,times,c,g);
   fid=fopen([testset(tile).id '\semi_random.csv'],'a');
   fprintf(fid,'%f,%f\n',c,g);
   for k=1:length(accred)
       fprintf(fid,'%f,',accred(k));
   end
   fprintf(fid,'\n');
   fclose(fid);
    
   [accred]=semi_oriprop(trainset,testset,classf,tile,num_add,times,c,g);
   fid=fopen([testset(tile).id '\semi_oriprop.csv'],'a');
   fprintf(fid,'%f,%f\n',c,g);
   for k=1:length(accred)
       fprintf(fid,'%f,',accred(k));
   end
   fprintf(fid,'\n');
   fclose(fid);
   
   [accred]=stable(trainset,testset,classf,tile,num_add,times,c,g);
   fid=fopen([testset(tile).id '\stable.csv'],'a');
   fprintf(fid,'%f,%f\n',c,g);
   for k=1:length(accred)
       fprintf(fid,'%f,',accred(k));
   end
   fprintf(fid,'\n');
   fclose(fid);
   
   
   [accred]=tenclass(trainset,testset,classf,tile,num_add,times,c,g);
   fid=fopen([testset(tile).id '\tenclass.csv'],'a');
   
   fprintf(fid,'%f,%f\n',c,g);
   for k=1:length(accred)
       fprintf(fid,'%f,',accred(k));
   end
   fprintf(fid,'\n');
   fclose(fid);
end
   