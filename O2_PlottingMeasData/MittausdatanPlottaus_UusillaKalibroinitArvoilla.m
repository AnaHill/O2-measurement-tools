%% Muuta mittausdata O2% uusilla kalibrointiarvoilla
clear,
pp=0;
% Lue Kalibrointi
load('S:\71301_MST-cells\OxygenMeasurement\MeasurementData\Datoja_Kaisa\kalibraatio\VesiKalibrointiArvot\VesiKalibrointi_CalibrationFrom_kalibraatio_vesi_2018_04_28__12_20_43.mat')
% Lue Data 1: 0%
load('S:\71301_MST-cells\OxygenMeasurement\MeasurementData\Datoja_Kaisa\alumiini_toistoMittaus\CroppedData\0O2_FromDATA_Alumiini_0O2_2018_04_12__11_07_12.mat');
% muuta mittauskulma O2% uudella kalibrointiarvolla
% Tarvitsee SternVolmerC-funktion
pp=pp+1;
O2new{pp}=SternVolmerC(Ksv,phi0,-RawData_time_phase_O2(:,2),caldevi);
time{pp} = RawData_time_phase_O2(:,1);
legs{pp} = '0%';
% Seuraava data: 1% 
load('S:\71301_MST-cells\OxygenMeasurement\MeasurementData\Datoja_Kaisa\alumiini_toistoMittaus\CroppedData\1O2_FromDATA_alumiini_1O2_2018_04_16__11_53_40.mat');
pp=pp+1;
O2new{pp}=SternVolmerC(Ksv,phi0,-RawData_time_phase_O2(:,2),caldevi);
time{pp} = RawData_time_phase_O2(:,1);
legs{pp} = '1%';
% Seuraava data: 5%
load('S:\71301_MST-cells\OxygenMeasurement\MeasurementData\Datoja_Kaisa\alumiini_toistoMittaus\CroppedData\5O2_FromDATA_Alumiini_5O2_2018_04_17__16_22_43.mat');
pp=pp+1;
O2new{pp}=SternVolmerC(Ksv,phi0,-RawData_time_phase_O2(:,2),caldevi);
time{pp} = RawData_time_phase_O2(:,1);
legs{pp} = '5%';
% Seuraava data: 5%
load('S:\71301_MST-cells\OxygenMeasurement\MeasurementData\Datoja_Kaisa\alumiini_toistoMittaus\CroppedData\10O2_FromDATA_alumiini_10O2_2018_04_20__19_45_23.mat');
pp=pp+1;
O2new{pp}=SternVolmerC(Ksv,phi0,-RawData_time_phase_O2(:,2),caldevi);
time{pp} = RawData_time_phase_O2(:,1);
legs{pp} = '10%';
%% Plotataan kaikki samaan
figure, hold all
for kk = 1:length(O2new)
   plot(time{kk}/60/60, O2new{kk})
end
legend(legs(:))

%% Alku ja loppuarvot ka
Montako_Arvoa = 100;
for kk = 1:length(O2new)
   Mean_Alku_Loppu(kk,:) = [mean(O2new{kk}(1:Montako_Arvoa)),...
      mean(O2new{kk}(end-Montako_Arvoa+1:end))];
end
Mean_Alku_Loppu
