%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% - Figure 1: Trip 1~4
% - Figure 2: Trip 5~8
% - Figure 3: Trip 9~11
%
% 각 Trip마다 4개의 subplot (가로):
%   1) 전압/전류 (0~100초)
%   2) 전압/전류 (전체 시간)
%   3) DRT
%   4) SOC
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear; close all;

%% (1) 사용자 지정 파라미터
axisTickFontSize   = 8;   % 축 눈금 폰트
axisLabelFontSize  = 9;   % 축 라벨 폰트
legendFontSize     = 6;   % 범례 폰트 크기

lineWidthMeas = 1;    % Meas.V 선 굵기
lineWidthEst  = 1.2;  % Est.V 선 굵기 (점선)
lineWidthCurr = 1;  
lineWidthSOC  = 1;  

% 전압/전류 축 범위 지정
% voltageYLim_short = [3.85, 3.95];  % 0~100초 구간에서 전압 범위
% currentYLim_short = [-2, 10];      % 0~100초 구간에서 전류 범위
% 
% voltageYLim_full  = [3.70, 4.00];  % 전체 구간에서 전압 범위
% currentYLim_full  = [-5, 12];      % 전체 구간에서 전류 범위

% legend 라인 길이/두께 
legendTokenSize = [10, 4];  % [라인길이, 아이콘높이]

%% (2) 색깔 배열
p_colors = [
    0.00000, 0.45098, 0.76078;  % #1 (blueish)
    0.93725, 0.75294, 0.00000;  % #2 (gold)
    0.80392, 0.32549, 0.29803;  % #3 (red-ish)
    0.12549, 0.52157, 0.30588;  % #4 (green)
    0.57255, 0.36863, 0.62353;  % #5 (purple)
    0.88235, 0.52941, 0.15294;  % #6 (orange)
    0.30196, 0.73333, 0.83529;  % #7 (light blue-cyan)
    0.93333, 0.29803, 0.59216;  % #8 (pinkish)
    0.49412, 0.38039, 0.28235;  % #9 (brownish)
    0.45490, 0.46275, 0.47059;  % #10 (gray)
    0.00000, 0.00000, 0.00000;  % #11 (black)
];

%% (3) Data load

load('G:\공유 드라이브\Battery Software Lab\Projects\DRT\Wisconsin_DRT\udds_data_soc_results.mat',...
     'udds_data_soc_results');

%% (4) Figure 1: Trip 1 ~ 4

figure('Name','Trips 1~4','Units','centimeters','Position',[2 2 28 25]);

numRows = 4;  % Trip 1,2,3,4
numCols = 4;  % (1) 0-100초 (2) 전체 (3) DRT (4) SOC
sp_count = 1;

for trip_idx = 1:4
    
    % === (4-1) subplot: 전압/전류 (0~100초) ===
    subplot(numRows, numCols, sp_count);
    sp_count = sp_count + 1;
    
    t      = udds_data_soc_results(trip_idx).t;
    V_meas = udds_data_soc_results(trip_idx).V;
    V_est  = udds_data_soc_results(trip_idx).V_est;
    I      = udds_data_soc_results(trip_idx).I;

    yyaxis left
    h1 = plot(t, V_meas, 'LineWidth', lineWidthMeas, ...
        'Color', p_colors(1,:), 'LineStyle','-', 'DisplayName','Meas.V');
    hold on;
    h2 = plot(t, V_est, 'LineWidth', lineWidthEst, ...
        'Color', p_colors(3,:), 'LineStyle',':', 'DisplayName','Est.V');
    ylabel('Voltage [V]','FontSize', axisLabelFontSize);

    yyaxis right
    h3 = plot(t, I, 'LineWidth', lineWidthCurr, ...
        'Color', p_colors(4,:), 'LineStyle','-', 'DisplayName','Current');
    ylabel('Current [A]','FontSize', axisLabelFontSize);

    xlim([0 100]);
    xlabel('Time [s]','FontSize', axisLabelFontSize);

    set(gca,'FontSize', axisTickFontSize, 'YColor','k','XColor','k');

    leg1 = legend([h1 h2 h3], 'Location','best','Orientation','horizontal');
    set(leg1, 'FontSize', legendFontSize, 'Box','off',...
        'ItemTokenSize', legendTokenSize);

    % === (4-2) subplot: 전압/전류 (전체) ===
    subplot(numRows, numCols, sp_count);
    sp_count = sp_count + 1;

    yyaxis left
    h4 = plot(t, V_meas, 'LineWidth', lineWidthMeas, ...
        'Color', p_colors(1,:), 'LineStyle','-', 'DisplayName','Meas.V');
    hold on;
    h5 = plot(t, V_est, 'LineWidth', lineWidthEst, ...
        'Color', p_colors(3,:), 'LineStyle',':', 'DisplayName','Est.V');
    ylabel('Voltage [V]','FontSize', axisLabelFontSize);

    yyaxis right
    h6 = plot(t, I, 'LineWidth', lineWidthCurr,...
        'Color', p_colors(4,:), 'LineStyle','-', 'DisplayName','Current');
    ylabel('Current [A]','FontSize', axisLabelFontSize);

    xlim([0, t(end)]);
    xlabel('Time [s]','FontSize', axisLabelFontSize);
    set(gca,'FontSize', axisTickFontSize, 'YColor','k','XColor','k');

    leg2 = legend([h4 h5 h6], 'Location','best','Orientation','horizontal');
    set(leg2, 'FontSize', legendFontSize, 'Box','off',...
        'ItemTokenSize', legendTokenSize);

    % === (4-3) subplot: DRT ===
    subplot(numRows, numCols, sp_count);
    sp_count = sp_count + 1;

    theta_ = udds_data_soc_results(trip_idx).theta_discrete;
    gamma_ = udds_data_soc_results(trip_idx).gamma_est;
    
    plot(theta_, gamma_, 'LineWidth', lineWidthMeas, ...
        'Color', p_colors(1,:), 'LineStyle','-');
    xlabel('\theta = ln(\tau [s])','FontSize', axisLabelFontSize);
    ylabel('\gamma [\Omega]','FontSize', axisLabelFontSize);
    xlim([-1 6]);  % 예시
    set(gca,'FontSize', axisTickFontSize,'XColor','k','YColor','k');

    % === (4-4) subplot: SOC ===
    subplot(numRows, numCols, sp_count);
    sp_count = sp_count + 1;

    True_   = udds_data_soc_results(trip_idx).True_SOC;
    CC_     = udds_data_soc_results(trip_idx).CC_SOC;
    SOC1RC  = udds_data_soc_results(trip_idx).SOC_1RC;
    SOC2RC  = udds_data_soc_results(trip_idx).SOC_2RC;
    SOCDRT  = udds_data_soc_results(trip_idx).SOC_DRT;

    p0 = plot(t, True_, 'LineWidth', lineWidthSOC,...
        'Color',[0.5 0.5 0.5], 'LineStyle','-', 'DisplayName','True');
    hold on;
    p1 = plot(t, CC_, 'LineWidth', lineWidthSOC,...
        'Color', p_colors(1,:), 'LineStyle','-', 'DisplayName','CC');
    p2 = plot(t, SOC1RC, 'LineWidth', lineWidthSOC,...
        'Color', p_colors(3,:), 'LineStyle','-', 'DisplayName','1RC');
    p3 = plot(t, SOC2RC, 'LineWidth', lineWidthSOC,...
        'Color', p_colors(2,:), 'LineStyle','-', 'DisplayName','2RC');
    p4 = plot(t, SOCDRT, 'LineWidth', lineWidthSOC,...
        'Color', p_colors(4,:), 'LineStyle','-', 'DisplayName','DRT');

    xlabel('Time [s]','FontSize', axisLabelFontSize);
    ylabel('SOC','FontSize', axisLabelFontSize);
    xlim([0, t(end)]);
    set(gca,'FontSize', axisTickFontSize,'XColor','k','YColor','k');

    leg3 = legend([p0 p1 p2 p3 p4], 'Location','best','Orientation','horizontal');
    set(leg3, 'FontSize', legendFontSize, 'Box','off',...
        'ItemTokenSize', legendTokenSize);
end

exportgraphics(gcf,'Fig1_Trips1to4.png','Resolution',300);
savefig(gcf,'Fig1_Trips1to4.fig');



%% (5) Figure 2: Trip 5 ~ 8
figure('Name','Trips 5~8','Units','centimeters','Position',[2 2 28 25]);

numRows = 4;  
numCols = 4;
sp_count = 1;

for trip_idx = 5:8

    % --- (5-1) 전압/전류 (0~100초) ---
    subplot(numRows, numCols, sp_count);
    sp_count = sp_count + 1;

    t      = udds_data_soc_results(trip_idx).t;
    V_meas = udds_data_soc_results(trip_idx).V;
    V_est  = udds_data_soc_results(trip_idx).V_est;
    I      = udds_data_soc_results(trip_idx).I;

    yyaxis left
    h1 = plot(t, V_meas, 'LineWidth', lineWidthMeas,...
        'Color', p_colors(1,:), 'LineStyle','-', 'DisplayName','Meas.V');
    hold on;
    h2 = plot(t, V_est, 'LineWidth', lineWidthEst,...
        'Color', p_colors(3,:), 'LineStyle',':', 'DisplayName','Est.V');
    ylabel('Voltage [V]','FontSize', axisLabelFontSize);

    yyaxis right
    h3 = plot(t, I, 'LineWidth', lineWidthCurr,...
        'Color', p_colors(4,:), 'LineStyle','-', 'DisplayName','Current');
    ylabel('Current [A]','FontSize', axisLabelFontSize);

    xlim([0 100]);
    xlabel('Time [s]','FontSize', axisLabelFontSize);
    set(gca,'FontSize', axisTickFontSize,'XColor','k','YColor','k');

    legA = legend([h1 h2 h3], 'Location','best','Orientation','horizontal');
    set(legA, 'FontSize', legendFontSize,'Box','off',...
        'ItemTokenSize', legendTokenSize);

    % --- (5-2) 전압/전류 (전체) ---
    subplot(numRows, numCols, sp_count);
    sp_count = sp_count + 1;

    yyaxis left
    h4 = plot(t, V_meas, 'LineWidth', lineWidthMeas,...
        'Color', p_colors(1,:),'LineStyle','-', 'DisplayName','Meas.V');
    hold on;
    h5 = plot(t, V_est, 'LineWidth', lineWidthEst,...
        'Color', p_colors(3,:),'LineStyle',':', 'DisplayName','Est.V');
    ylabel('Voltage [V]','FontSize', axisLabelFontSize);

    yyaxis right
    h6 = plot(t, I, 'LineWidth', lineWidthCurr,...
        'Color', p_colors(4,:), 'LineStyle','-', 'DisplayName','Current');
    ylabel('Current [A]','FontSize', axisLabelFontSize);

    xlim([0, t(end)]);
    xlabel('Time [s]','FontSize', axisLabelFontSize);
    set(gca,'FontSize', axisTickFontSize,'XColor','k','YColor','k');

    legB = legend([h4 h5 h6], 'Location','best','Orientation','horizontal');
    set(legB, 'FontSize', legendFontSize,'Box','off',...
        'ItemTokenSize', legendTokenSize);

    % --- (5-3) DRT ---
    subplot(numRows, numCols, sp_count);
    sp_count = sp_count + 1;

    theta_ = udds_data_soc_results(trip_idx).theta_discrete;
    gamma_ = udds_data_soc_results(trip_idx).gamma_est;
    plot(theta_, gamma_, 'LineWidth', lineWidthMeas,...
        'Color', p_colors(1,:), 'LineStyle','-');
    xlim([-1 6]);
    xlabel('\theta','FontSize', axisLabelFontSize);
    ylabel('\gamma [\Omega]','FontSize', axisLabelFontSize);
    set(gca,'FontSize', axisTickFontSize,'XColor','k','YColor','k');

    % --- (5-4) SOC ---
    subplot(numRows, numCols, sp_count);
    sp_count = sp_count + 1;

    True_  = udds_data_soc_results(trip_idx).True_SOC;
    CC_    = udds_data_soc_results(trip_idx).CC_SOC;
    SOC1RC = udds_data_soc_results(trip_idx).SOC_1RC;
    SOC2RC = udds_data_soc_results(trip_idx).SOC_2RC;
    SOCDRT = udds_data_soc_results(trip_idx).SOC_DRT;

    p0 = plot(t, True_, 'LineWidth', lineWidthSOC,...
        'Color',[0.5 0.5 0.5], 'LineStyle','-', 'DisplayName','True');
    hold on;
    p1 = plot(t, CC_, 'LineWidth', lineWidthSOC,...
        'Color', p_colors(1,:), 'LineStyle','-', 'DisplayName','CC');
    p2 = plot(t, SOC1RC, 'LineWidth', lineWidthSOC,...
        'Color', p_colors(3,:), 'LineStyle','-', 'DisplayName','1RC');
    p3 = plot(t, SOC2RC, 'LineWidth', lineWidthSOC,...
        'Color', p_colors(2,:), 'LineStyle','-', 'DisplayName','2RC');
    p4 = plot(t, SOCDRT, 'LineWidth', lineWidthSOC,...
        'Color', p_colors(4,:), 'LineStyle','-', 'DisplayName','DRT');

    xlim([0, t(end)]);
    xlabel('Time [s]','FontSize', axisLabelFontSize);
    ylabel('SOC','FontSize', axisLabelFontSize);
    set(gca,'FontSize', axisTickFontSize,'XColor','k','YColor','k');
    legC = legend([p0 p1 p2 p3 p4], 'Location','best','Orientation','horizontal');
    set(legC, 'FontSize', legendFontSize,'Box','off',...
        'ItemTokenSize', legendTokenSize);
end

exportgraphics(gcf,'Fig2_Trips5to8.png','Resolution',300);
savefig(gcf,'Fig2_Trips5to8.fig');



%% (6) Figure 3: Trip 9 ~ 11

figure('Name','Trips 9~11','Units','centimeters','Position',[2 2 28 20]);

numRows = 3;  
numCols = 4;
sp_count = 1;

for trip_idx = 9:11

    % --- (6-1) 전압/전류 (0~100초) ---
    subplot(numRows, numCols, sp_count);
    sp_count = sp_count + 1;

    t      = udds_data_soc_results(trip_idx).t;
    V_meas = udds_data_soc_results(trip_idx).V;
    V_est  = udds_data_soc_results(trip_idx).V_est;
    I      = udds_data_soc_results(trip_idx).I;

    yyaxis left
    h1 = plot(t, V_meas, 'LineWidth', lineWidthMeas,...
        'Color', p_colors(1,:), 'LineStyle','-', 'DisplayName','Meas.V');
    hold on;
    h2 = plot(t, V_est, 'LineWidth', lineWidthEst,...
        'Color', p_colors(3,:), 'LineStyle',':', 'DisplayName','Est.V');
    ylabel('Voltage [V]','FontSize', axisLabelFontSize);

    yyaxis right
    h3 = plot(t, I, 'LineWidth', lineWidthCurr,...
        'Color', p_colors(4,:), 'LineStyle','-', 'DisplayName','Current');
    ylabel('Current [A]','FontSize', axisLabelFontSize);

    xlim([0 100]);
    xlabel('Time [s]','FontSize', axisLabelFontSize);
    set(gca,'FontSize', axisTickFontSize,'XColor','k','YColor','k');

    legA = legend([h1 h2 h3], 'Location','best','Orientation','horizontal');
    set(legA, 'FontSize', legendFontSize,'Box','off',...
        'ItemTokenSize', legendTokenSize);

    % --- (6-2) 전압/전류 (전체) ---
    subplot(numRows, numCols, sp_count);
    sp_count = sp_count + 1;

    yyaxis left
    h4 = plot(t, V_meas, 'LineWidth', lineWidthMeas,...
        'Color', p_colors(1,:), 'LineStyle','-', 'DisplayName','Meas.V');
    hold on;
    h5 = plot(t, V_est, 'LineWidth', lineWidthEst,...
        'Color', p_colors(3,:), 'LineStyle',':', 'DisplayName','Est.V');
    ylabel('Voltage [V]','FontSize', axisLabelFontSize);

    yyaxis right
    h6 = plot(t, I, 'LineWidth', lineWidthCurr,...
        'Color', p_colors(4,:), 'LineStyle','-', 'DisplayName','Current');
    ylabel('Current [A]','FontSize', axisLabelFontSize);

    xlim([0, t(end)]);
    xlabel('Time [s]','FontSize', axisLabelFontSize);
    set(gca,'FontSize', axisTickFontSize,'XColor','k','YColor','k');

    legB = legend([h4 h5 h6], 'Location','best','Orientation','horizontal');
    set(legB, 'FontSize', legendFontSize,'Box','off',...
        'ItemTokenSize', legendTokenSize);

    % --- (6-3) DRT ---
    subplot(numRows, numCols, sp_count);
    sp_count = sp_count + 1;

    theta_ = udds_data_soc_results(trip_idx).theta_discrete;
    gamma_ = udds_data_soc_results(trip_idx).gamma_est;
    plot(theta_, gamma_, 'LineWidth', lineWidthMeas,...
        'Color', p_colors(1,:), 'LineStyle','-');
    xlabel('\theta','FontSize', axisLabelFontSize);
    ylabel('\gamma [\Omega]','FontSize', axisLabelFontSize);
    xlim([-1 6]);
    set(gca,'FontSize', axisTickFontSize,'XColor','k','YColor','k');

    % --- (6-4) SOC ---
    subplot(numRows, numCols, sp_count);
    sp_count = sp_count + 1;

    True_  = udds_data_soc_results(trip_idx).True_SOC;
    CC_    = udds_data_soc_results(trip_idx).CC_SOC;
    SOC1RC = udds_data_soc_results(trip_idx).SOC_1RC;
    SOC2RC = udds_data_soc_results(trip_idx).SOC_2RC;
    SOCDRT = udds_data_soc_results(trip_idx).SOC_DRT;

    p0 = plot(t, True_, 'LineWidth', lineWidthSOC,...
        'Color',[0.5 0.5 0.5], 'LineStyle','-', 'DisplayName','True');
    hold on;
    p1 = plot(t, CC_, 'LineWidth', lineWidthSOC,...
        'Color', p_colors(1,:), 'LineStyle','-', 'DisplayName','CC');
    p2 = plot(t, SOC1RC, 'LineWidth', lineWidthSOC,...
        'Color', p_colors(3,:), 'LineStyle','-', 'DisplayName','1RC');
    p3 = plot(t, SOC2RC, 'LineWidth', lineWidthSOC,...
        'Color', p_colors(2,:), 'LineStyle','-', 'DisplayName','2RC');
    p4 = plot(t, SOCDRT, 'LineWidth', lineWidthSOC,...
        'Color', p_colors(4,:), 'LineStyle','-', 'DisplayName','DRT');

    xlim([0, t(end)]);
    xlabel('Time [s]','FontSize', axisLabelFontSize);
    ylabel('SOC','FontSize', axisLabelFontSize);
    set(gca,'FontSize', axisTickFontSize,'XColor','k','YColor','k');

    legC = legend([p0 p1 p2 p3 p4], 'Location','best','Orientation','horizontal');
    set(legC, 'FontSize', legendFontSize,'Box','off',...
        'ItemTokenSize', legendTokenSize);
end

exportgraphics(gcf,'Fig3_Trips9to11.png','Resolution',300);
savefig(gcf,'Fig3_Trips9to11.fig');

