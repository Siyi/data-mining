function avgg=getAvg(seta,setb)

summ=zeros(1,size(seta,1));
avgg=zeros(1,size(seta,1));
for i=1:size(seta,1)
    summ(i)=sum(dist(seta(i,:),setb'));
    avgg(i)=summ(i)/size(setb,1);
    
end