%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fig_e_contour_and_offset.m
%  - Figure #1: 2D Contour (x=theta, y=SOC, color=gamma)
%  - Figure #2: Offset Plot (x=theta, y=gamma + offset)
%
% Author: (사용자 이름)
% Date:   2023-xx-xx
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear; close all;

%% (1) 사용자 지정 파라미터
figWidth1  = 15;  % cm, Figure #1 크기
figHeight1 = 10;

figWidth2  = 15;  % cm, Figure #2 크기
figHeight2 = 10;

% 폰트, 기타 설정
axisLabelFontSize = 8;
axisTickFontSize  = 7;
annotationFontSize= 9;

% annotation 박스 (원하시면 빼셔도 됩니다) - 일단 주석 처리
annotationOffsetX = -0.06;
annotationOffsetY = 1.05;
annotationBoxW    = 0.03;
annotationBoxH    = 0.03;

%% (2) 데이터 불러오기(실제 경로로 수정)
load('G:\공유 드라이브\Battery Software Lab\Projects\DRT\Wisconsin_DRT\udds_data_soc_results.mat',...
     'udds_data_soc_results');
numTrips = length(udds_data_soc_results);

% 모든 trip에 대해 theta, gamma_est, 중간 SOC(soc_mid) 확보
theta_all = udds_data_soc_results(1).theta_discrete;  % 가정: 모든 trip 동일 길이
nTheta = length(theta_all);

soc_mid_all   = zeros(numTrips-6,1);
gamma_all_mat = zeros(numTrips-6, nTheta);

for s = 1:numTrips-6
    gammaVec = udds_data_soc_results(s).gamma_est(:);
    gamma_all_mat(s,:) = gammaVec';  % 각 row에 저장
    
    % 중간 SOC 계산(예시: DRT 결과 SOC 평균)
    socVals = udds_data_soc_results(s).SOC_DRT;
    soc_mid_all(s) = mean(socVals);
end

% SOC를 기준으로 오름차순 정렬
[soc_mid_sorted, idxSort] = sort(soc_mid_all);
gamma_sorted_mat = gamma_all_mat(idxSort,:);

%% (3) Figure #1: 2D Contour
fig1 = figure('Units','centimeters','Position',[3 3 figWidth1 figHeight1]);
box on; hold on;

[Xgrid, Ygrid] = meshgrid(theta_all, soc_mid_sorted);
% Xgrid : (numTrips행 x nTheta열), Ygrid: 동일, Z = gamma_sorted_mat

contourf(Xgrid, Ygrid, gamma_sorted_mat, 20, 'LineStyle','none');
colormap(parula(256));  % 좀 더 부드럽게 256단계
%caxis([0, 0.1]);         % gamma 값 범위 (0~0.1)
colorbar;               % colorbar 표시

xlabel('\theta = ln(\tau [s])','FontSize',axisLabelFontSize);
ylabel('SOC','FontSize',axisLabelFontSize);
set(gca,'FontSize',axisTickFontSize);
xlim([-1 6]);


% annotation('textbox',...
%    [0.12 + annotationOffsetX, ...
%     0.88 + annotationOffsetY*(0),...
%     annotationBoxW, annotationBoxH],...
%    'String','(e1) Contour',...
%    'FontSize',annotationFontSize,...
%    'FontWeight','bold','LineStyle','none');

% 해상도 300 dpi로 PNG 저장
exportgraphics(fig1, 'Fig_e1_Contour.png','Resolution',300);


%% (4) Figure #2: Offset Plot (x=theta, y=gamma + offset)
fig2 = figure('Units','centimeters','Position',[3 3 figWidth2 figHeight2]);
box on; hold on;

% 실제 사용할 trip 개수 (numTrips - 6)
nUse = size(gamma_sorted_mat, 1);

offsetGap = 0.012;  % SOC별 곡선을 위로 띄울 간격

% parula에서 nUse개 색상 뽑아온다.
% → index=1일 때 보통 파란 쪽, index=nUse일 때 노란 쪽
cmap = parula(nUse);

for s = 1:nUse
    thisGamma = gamma_sorted_mat(s,:);
    offsetVal = (s-1)*offsetGap;
    
    % s번째 색상 (cmap(s,:)) 적용
    plot(theta_all, thisGamma + offsetVal, ...
         'LineWidth',1.2, 'Color', cmap(s,:));
    
    % 텍스트 위치 (x=6.1 정도) → xlim([-1, 6]) 밖에 표시
    xTextPos = 6.1;
    yTextPos = thisGamma(end) + offsetVal;
    
    % SOC 레이블
    ht = text(xTextPos, yTextPos, ...
        sprintf('SOC=%.2f', soc_mid_sorted(s)), ...
        'FontSize', axisTickFontSize, ...
        'HorizontalAlignment','left','VerticalAlignment','middle');
    
    % 축 범위 밖이라도 텍스트가 잘리지 않도록 처리
    set(ht, 'Clipping','off');
end

% 축 라벨, 폰트
xlabel('\theta = ln(\tau [s])','FontSize',axisLabelFontSize);
ylabel('\gamma (offset) [\Omega]','FontSize',axisLabelFontSize);
set(gca,'FontSize',axisTickFontSize);

% x축 범위 지정
xlim([-1, 6]);
ylim([0, 0.18]);

% % y축 범위 지정 (offset까지 고려)
% minGamma = min(gamma_sorted_mat(:));
% maxGamma = max(gamma_sorted_mat(:));
% ylim([minGamma, maxGamma + offsetGap*(nUse-1)]);







% (옵션) 축 자체도 Clipping off 가능
% set(gca,'Clipping','off');

% 해상도 300 dpi로 PNG 저장 (원하시면)
exportgraphics(fig2, 'Fig_e2_Offset.png','Resolution',300);


%% (5) Additional Figures for Trip #6: Voltage Comparison

% -- Extract time and voltages for trip #6
tripIdx = 6;
time_s = udds_data_soc_results(tripIdx).t;     % time vector
V_meas = udds_data_soc_results(tripIdx).V;     % measured voltage
V_est  = udds_data_soc_results(tripIdx).V_est; % estimated voltage

% For consistency, you can reuse or define figure sizes:
figWidth  = 15;  % cm
figHeight = 8;

%% Figure #3: Voltage comparison in 0–100 s
fig3 = figure('Units','centimeters','Position',[3 3 figWidth figHeight]);
box on; hold on;
plot(time_s, V_meas, 'b','LineWidth',1.2);
plot(time_s, V_est,  'r','LineWidth',1.2);
xlabel('Time [s]','FontSize',axisLabelFontSize);
ylabel('Voltage [V]','FontSize',axisLabelFontSize);
legend({'V_{meas}','V_{est}'},'Location','best');
set(gca,'FontSize',axisTickFontSize);
xlim([0 100]);
title('Trip #6 Voltage Comparison: 0–100 s');
exportgraphics(fig3,'Fig_e3_Trip6_0to100.png','Resolution',300);

%% Figure #4: Voltage comparison in 1300–1400 s
fig4 = figure('Units','centimeters','Position',[3 3 figWidth figHeight]);
box on; hold on;
plot(time_s, V_meas, 'b','LineWidth',1.2);
plot(time_s, V_est,  'r','LineWidth',1.2);
xlabel('Time [s]','FontSize',axisLabelFontSize);
ylabel('Voltage [V]','FontSize',axisLabelFontSize);
legend({'V_{meas}','V_{est}'},'Location','best');
set(gca,'FontSize',axisTickFontSize);
xlim([1300 1400]);
title('Trip #6 Voltage Comparison: 1300–1400 s');
exportgraphics(fig4,'Fig_e4_Trip6_1300to1400.png','Resolution',300);

%% Figure #5: Voltage comparison over full time
fig5 = figure('Units','centimeters','Position',[3 3 figWidth figHeight]);
box on; hold on;
plot(time_s, V_meas, 'b','LineWidth',1);
plot(time_s, V_est,  'r','LineWidth',1);
xlabel('Time [s]','FontSize',axisLabelFontSize);
ylabel('Voltage [V]','FontSize',axisLabelFontSize);
legend({'V_{meas}','V_{est}'},'Location','best');
set(gca,'FontSize',axisTickFontSize);
title('Trip #6 Voltage Comparison: Full Time Range');
exportgraphics(fig5,'Fig_e5_Trip6_FullTime.png','Resolution',300);




