clear all
clc
load('./tile1_24/oriprop.mat');

x=243:120:(243+120*6);
plot(x,accred,'--rs','LineWidth',4);
hold on

load('./tile1_24/Redistrict.mat');
plot(x,accred,'-.bo','LineWidth',4);

load('./tile1_24/acs_probestimate.mat');
plot(x,accred,'-.md','LineWidth',4);



