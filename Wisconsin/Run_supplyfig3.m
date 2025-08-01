%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot_trip_figures_fixed_position.m  (rev‑02)
% -------------------------------------------------------------------------
% * Figure 1 : Trips 1–4
% * Figure 2 : Trips 5–8
% * Figure 3 : Trips 9–11
%   └ Each Trip is drawn in one row with four columns:
%       1) Voltage / Current (0–100 s)
%       2) Voltage / Current (full duration)
%       3) DRT
%       4) SOC
% -------------------------------------------------------------------------
% 2025‑08‑01 • Battery Software Lab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear; close all;

%% (0)  공통 Figure 위치/크기 설정 ---------------------------------------
%  ─────────────────────────────────────────────────────────────────────────
%  MATLAB 의 figure 위치 좌표는 **pixel** 기준이 가장 일관적입니다. 
%  아래 두 파라미터만 변경하면 모든 figure 의 위치와 크기가 한번에 바뀝니다.
figStartPos = [100 , 120];   % [left, bottom]  – 화면 왼쪽‑아래 기준 (px)
figSizePix  = [1100, 900];   % [width, height] – figure 크기        (px)

%% (1) 사용자 지정 파라미터 ----------------------------------------------
axisTickFontSize   = 8;   % 축 눈금 폰트
axisLabelFontSize  = 9;   % 축 라벨 폰트
legendFontSize     = 6;   % 범례 폰트 크기

lineWidthMeas = 1;    % Meas.V 선 굵기
lineWidthEst  = 1.2;  % Est.V 선 굵기 (점선)
lineWidthCurr = 1;  
lineWidthSOC  = 1;  

% legend 라인 길이/두께 
legendTokenSize = [10, 4];  % [라인길이, 아이콘높이]

%% (2) 색깔 배열 -----------------------------------------------------------
p_colors = [
    0.00000, 0.45098, 0.76078;  % #1 (blueish)
    0.93725, 0.75294, 0.00000;  % #2 (gold)
    0.80392, 0.32549, 0.29803;  % #3 (red‑ish)
    0.12549, 0.52157, 0.30588;  % #4 (green)
    0.57255, 0.36863, 0.62353;  % #5 (purple)
    0.88235, 0.52941, 0.15294;  % #6 (orange)
    0.30196, 0.73333, 0.83529;  % #7 (cyan)
    0.93333, 0.29803, 0.59216;  % #8 (pink)
    0.49412, 0.38039, 0.28235;  % #9 (brown)
    0.45490, 0.46275, 0.47059;  % #10 (gray)
    0.00000, 0.00000, 0.00000;  % #11 (black)
];

%% (3) Data load ----------------------------------------------------------
load('G:\공유 드라이브\Battery Software Lab\Projects\DRT\Wisconsin_DRT\udds_data_soc_results.mat', ...
     'udds_data_soc_results');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Figure‑생성용 helper 익명함수 -------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
createFig = @(name) figure('Name',   name,          ...
                           'Units',  'pixels',      ...  % 고정 좌표계
                           'Position',[figStartPos figSizePix]);

%% (4) Figure 1 : Trip 1 ~ 4 ---------------------------------------------
createFig('Trips 1~4');
numRows = 4; numCols = 4; sp = 1;

for tripIdx = 1:4
    [sp] = drawTrip(udds_data_soc_results, tripIdx, numRows, numCols, sp, ...
                    p_colors, axisLabelFontSize, axisTickFontSize, legendFontSize, ...
                    legendTokenSize, lineWidthMeas, lineWidthEst, lineWidthCurr, lineWidthSOC);
end
exportgraphics(gcf,'Fig1_Trips1to4.png','Resolution',300);
savefig(gcf,'Fig1_Trips1to4.fig');

%% (5) Figure 2 : Trip 5 ~ 8 ---------------------------------------------
createFig('Trips 5~8');
numRows = 4; numCols = 4; sp = 1;

for tripIdx = 5:8
    [sp] = drawTrip(udds_data_soc_results, tripIdx, numRows, numCols, sp, ...
                    p_colors, axisLabelFontSize, axisTickFontSize, legendFontSize, ...
                    legendTokenSize, lineWidthMeas, lineWidthEst, lineWidthCurr, lineWidthSOC);
end
exportgraphics(gcf,'Fig2_Trips5to8.png','Resolution',300);
savefig(gcf,'Fig2_Trips5to8.fig');

%% (6) Figure 3 : Trip 9 ~ 11 --------------------------------------------
createFig('Trips 9~11');
numRows = 3; numCols = 4; sp = 1;

for tripIdx = 9:11
    [sp] = drawTrip(udds_data_soc_results, tripIdx, numRows, numCols, sp, ...
                    p_colors, axisLabelFontSize, axisTickFontSize, legendFontSize, ...
                    legendTokenSize, lineWidthMeas, lineWidthEst, lineWidthCurr, lineWidthSOC);
end
exportgraphics(gcf,'Fig3_Trips9to11.png','Resolution',300);
savefig(gcf,'Fig3_Trips9to11.fig');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ┌────────────────────────────────────────────────────────────────┐
%  │  Local function : drawTrip                                   │
%  └────────────────────────────────────────────────────────────────┘
function [sp_next] = drawTrip(D, idx, nRows, nCols, sp, p_colors, ...
                    labFS, tickFS, legFS, legTok, ...
                    lwMeas, lwEst, lwI, lwSOC)
% D       : struct array with trip‑wise data
% idx     : current trip index
% nRows   : subplot rows
% nCols   : subplot columns
% sp      : current subplot counter (updated internally)
% returns : next subplot counter value

    t      = D(idx).t;
    V_meas = D(idx).V;
    V_est  = D(idx).V_est;
    I      = D(idx).I;

    %% 1) Voltage / Current (0–100 s) -----------------------------------
    subplot(nRows, nCols, sp);  sp = sp + 1;
    yyaxis left
    h1 = plot(t, V_meas, 'LineWidth', lwMeas, 'Color', p_colors(1,:), 'LineStyle','-','DisplayName','Meas.V'); hold on;
    h2 = plot(t, V_est,  'LineWidth', lwEst,  'Color', p_colors(3,:), 'LineStyle',':','DisplayName','Est.V');
    ylabel('Voltage [V]','FontSize', labFS);
    yyaxis right
    h3 = plot(t, I, 'LineWidth', lwI, 'Color', p_colors(4,:), 'DisplayName','Current');
    ylabel('Current [A]','FontSize', labFS);
    xlim([0 100]); xlabel('Time [s]','FontSize', labFS);
    set(gca,'FontSize',tickFS,'YColor','k','XColor','k');
    lg = legend([h1 h2 h3],'Location','best','Orientation','horizontal');
    set(lg,'FontSize',legFS,'Box','off','ItemTokenSize',legTok);

    %% 2) Voltage / Current (full) --------------------------------------
    subplot(nRows, nCols, sp);  sp = sp + 1;
    yyaxis left
    h4 = plot(t, V_meas, 'LineWidth', lwMeas, 'Color', p_colors(1,:), 'LineStyle','-','DisplayName','Meas.V'); hold on;
    h5 = plot(t, V_est,  'LineWidth', lwEst,  'Color', p_colors(3,:), 'LineStyle',':','DisplayName','Est.V');
    ylabel('Voltage [V]','FontSize', labFS);
    yyaxis right
    h6 = plot(t, I, 'LineWidth', lwI, 'Color', p_colors(4,:), 'DisplayName','Current');
    ylabel('Current [A]','FontSize', labFS);
    xlim([0 t(end)]); xlabel('Time [s]','FontSize', labFS);
    set(gca,'FontSize',tickFS,'YColor','k','XColor','k');
    lg = legend([h4 h5 h6],'Location','best','Orientation','horizontal');
    set(lg,'FontSize',legFS,'Box','off','ItemTokenSize',legTok);

    %% 3) DRT ------------------------------------------------------------
    subplot(nRows, nCols, sp);  sp = sp + 1;
    plot(D(idx).theta_discrete, D(idx).gamma_est, 'LineWidth', lwMeas, 'Color', p_colors(1,:));
    xlabel('\theta = ln(\tau [s])','FontSize', labFS);
    ylabel('\gamma [\Omega]','FontSize', labFS);
    xlim([-1 6]);
    set(gca,'FontSize',tickFS,'XColor','k','YColor','k');

    %% 4) SOC ------------------------------------------------------------
    subplot(nRows, nCols, sp);  sp = sp + 1;
    p0 = plot(t, D(idx).True_SOC, 'LineWidth', lwSOC, 'Color',[.55 .55 .55], 'DisplayName','True'); hold on;
    p1 = plot(t, D(idx).CC_SOC,   'LineWidth', lwSOC, 'Color', p_colors(1,:), 'DisplayName','CC');
    p2 = plot(t, D(idx).SOC_1RC,  'LineWidth', lwSOC, 'Color', p_colors(3,:), 'DisplayName','1RC');
    p3 = plot(t, D(idx).SOC_2RC,  'LineWidth', lwSOC, 'Color', p_colors(2,:), 'DisplayName','2RC');
    p4 = plot(t, D(idx).SOC_DRT,  'LineWidth', lwSOC, 'Color', p_colors(4,:), 'DisplayName','DRT');
    xlabel('Time [s]','FontSize', labFS);
    ylabel('SOC','FontSize', labFS);
    xlim([0 t(end)]); set(gca,'FontSize',tickFS,'XColor','k','YColor','k');
    lg = legend([p0 p1 p2 p3 p4],'Location','best','Orientation','horizontal');
    set(lg,'FontSize',legFS,'Box','off','ItemTokenSize',legTok);

    sp_next = sp;  % return updated subplot index
end

