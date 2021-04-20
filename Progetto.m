%% Calibrazione modello di Vasicek
%Alberto Bussola- VR436800

%Importo i dati
clear variables
close all
dati=readcell('AAA.xlsx');

for j=1:4
    i(:,j)=str2double(dati(2:34,j+1));
end 

 mat=[0.25,0.5,0.75,1:30]'

%Ottimizzazione della funzione obiettivo
for j=1:4
    [par_est1(:,j),error1(j),residual(:,j),exitflag1(j)] = lsqnonlin(@(par)objective_lsqnonlin(par,mat,i(:,j)),[0.1,i(end,j),0.05,i(1,j)]);
   
    i_fit_lsqnonlin(:,j) = vasicek_zcb(par_est1(1,j),par_est1(2,j),par_est1(3,j),par_est1(4,j),mat).^(-1./mat)-1;
    
    [par_est2(:,j),error2(j),residual2(:,j),exitflag2(j)] =fminsearch(@(par)obj_fmin(par,mat,i(:,j)),[0.1,i(33,1),0.05,i(1,j)]);

    i_fit_fmin(:,j) = vasicek_zcb(par_est2(1,j),par_est2(2,j),par_est2(3,j),par_est2(4,j),mat).^(-1./mat)-1;
end

  

%Visualizzazione fitting

figure('Name', 'Calibrazione del modello di Vasicek'),
subplot(2,2,1),plot(mat,i(:,1),'ko--'),hold
plot(mat,i_fit_fmin(:,1),'r','linewidth',3),
plot(mat,i_fit_lsqnonlin(:,1),'g-','linewidth',3)
legend('Data','Fit (fminsearch)','Fit (lsqnonlin)','Location','SouthEast')
title('2017')
xlabel('Maturity (years)')
ylabel('Annual rates (%)')
grid

subplot(2,2,2),plot(mat,i(:,2),'ko--'),hold
plot(mat,i_fit_fmin(:,2),'r','linewidth',3),
plot(mat,i_fit_lsqnonlin(:,2),'g-','linewidth',3)
legend('Data','Fit (fminsearch)','Fit (lsqnonlin)','Location','SouthEast')
title('2018')
xlabel('Maturity (years)')
ylabel('Annual rates (%)')
grid


subplot(2,2,3),plot(mat,i(:,3),'ko--'),hold
plot(mat,i_fit_fmin(:,3),'r','linewidth',3),
plot(mat,i_fit_lsqnonlin(:,3),'g-','linewidth',3)
legend('Data','Fit (fminsearch)','Fit (lsqnonlin)','Location','SouthEast')
title('2019')
xlabel('Maturity (years)')
ylabel('Annual rates (%)')
grid


subplot(2,2,4),plot(mat,i(:,4),'ko--'),hold
plot(mat,i_fit_fmin(:,4),'r','linewidth',3),
plot(mat,i_fit_lsqnonlin(:,4),'g-','linewidth',3)
legend('Data','Fit (fminsearch)','Fit (lsqnonlin)','Location','SouthEast')
title('2020')
xlabel('Maturity (years)')
ylabel('Annual rates (%)')
grid


%% Simulazione tasso a breve con il modello di Vasicek, 
%struttura per scadenza e tassi Euribor

alpha = par_est2(1,1); %termine di mean-reversion
gamma = par_est2(2,1)/100 ; %tasso di lungo periodo
sigma_vasicek = par_est2(3,1)/100; 
r0=par_est2(4,1)/100; 
dt=1/252;
n_sim=1000;
n=252*10;
dw= randn(n,n_sim)*sqrt(dt);

for t=1:n_sim
    r_vasicek(1,t) = r0;        %Simulazione del tasso a breve nel tempo

        for j=2:1:n
        r_vasicek(j,t) = r_vasicek(j-1,t) + alpha*(gamma-r_vasicek(j-1,t))*dt...
                + sigma_vasicek*dw(j,t);
        end
        mat=(1/12):(1/12):30;  %vettore delle maturità mensili fino a 30 anni
        for j=1:n
           
        p(j,:)= vasicek_zcb(alpha, gamma, sigma_vasicek, r_vasicek(j,t), mat); %costruzione struttura per scadenza
        i_sconto(j,:)=(p(j,:).^(-1./mat)-1);
    
        end
i6m(:,t)=i_sconto(:,6);  %simulazione tassi Euribor 6m con t0 da 0 a 10 anni (in giorni) per le 1000 simulazioni
            
 end



%Visualizzazione di alcune traiettorie del tasso a breve

figure('Name', 'Simulazione del tasso a breve con il modello di Vasicek'),hold
for z=1:5
    plot(r_vasicek(:,z)*100)
end
title('Tasso a breve - 5 delle 1000 simulazioni')
xlabel('Maturity (days) - 10 anni')
ylabel('Annual rates (%)')
grid


%% Valutazione opzione floor con maturità 10 anni,tenor semestrale
% k=0.28%, nozionale 100.000 € e sottostante Euribor 6m

euribor=i6m(1:126:end,:); %vettore dei tassi Euribor nelle 1000 simulazioni
s=126:126:2520; %vettore dei flussi di cassa del floor

for k=1:n_sim
    for j= 1:20
        
        s(j,k)= max(100000*0.5*((0.0028-euribor(j,k))),0).*p(1,j*6); 
        %(K -i)+ (flussi scontati del floor)
    end
    end

%Visualizzazione delle prime 5 simulazioni dei flussi del floor

figure('Name','Flussi del floor'),hold
for h=1:5
    plot(s(:,h))
end

title('Prime 5 simulazioni dei flussi del floor scontati')
xlabel('Maturity (semestri) - 10 anni')
ylabel('€')
grid

%calcolo del prezzo del floor come media della somma dei flussi delle 1000 simulazioni

prezzo_floor=mean(sum(s(:,:),1));


%% Valutazione opzione cap con maturità 10 anni,tenor semestrale
% k=0.22%, nozionale 100.000 € e sottostante Euribor 6m

euribor=i6m(1:126:end,:); %vettore dei tassi Euribor nelle 1000 simulazioni

s2=126:126:2520; %vettore dei flussi di cassa del cap

for k=1:n_sim
    for j= 1:20
        
        s2(j,k)= max(100000*0.5*((euribor(j,k)-0.0022)),0)*p(1,j*6); 
        %(i-K)+ (flussi di cassa scontati del cap)
    end
end


%Visualizzazione delle prime 5 simulazioni dei flussi del cap
figure('Name','Flussi del cap'),hold
for h=1:5
    plot(s2(:,h))
   
end
title('Prime 5 simulazioni dei flussi del cap scontati')
xlabel('Maturity (anni) - 10 anni')
ylabel('€')
grid

%Calcolo del prezzo del cap come media della somma del flussi scontati
%delle 1000 simulazioni
prezzo_cap=mean(sum(s2(:,:),1));

%% Funzioni

function [p] = vasicek_zcb(alpha,gamma,sigma,r0,T)
% in questa funzione T può essere anche un vettore; 
% alpha, gamma e sigma costanti
    b = (1-exp(-alpha.*T))/alpha;
    Rinf = gamma-1/2*sigma^2/alpha^2;
    R = Rinf + (r0-Rinf)*b./T+ sigma^2/4*alpha*b.^2./T;
    p = exp(-T.*R);
end



function y = obj_fmin(par,mat,rates)            %funzione obiettivo di fminsearch
    y = sum((rates - (vasicek_zcb(par(1),par(2),par(3),par(4),mat).^(-1./mat)-1)).^2);
end


function y = objective_lsqnonlin(par,mat,rates) %funzione obiettivo di lsqnonlin
    y = rates - (vasicek_zcb(par(1),par(2),par(3),par(4),mat).^(-1./mat)-1);
end
