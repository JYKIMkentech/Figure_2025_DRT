%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run_supplyfig_compactLegend_16Trips.m
%
% - 16개 Trip, 각 3개 subplot: (a) 전압/전류, (b) DRT, (c) SOC
% - 4개의 Figure 생성 (Trip 1~4, 5~8, 9~12, 13~16)
% - legend를 'compact'하게 만들기 위해:
%    (1) legend FontSize = 6 (줄임)
%    (2) ItemTokenSize = [5,2] (라인 길이/두께 줄임)
%    (3) 'Location','none' & 'Position' 수동 지정
% - annotation( (a), (b), (c) ) 부분은 전부 주석 처리
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear; close all;

%% (1) 사용자 지정 파라미터
axisTickFontSize   = 8;  % 축 눈금 폰트
axisLabelFontSize  = 9;  % 축 라벨 폰트
legendFontSize     = 6;  % 범례 폰트 (작게)
annotationFontSize = 9;  % (a), (b), (c) 등에 사용할 폰트 (지금은 주석)

lineWidthMeas = 1;  
lineWidthEst  = 1;  
lineWidthCurr = 1;  
lineWidthSOC  = 1;  

currentYLim = [-6, 12];  % 전류축 범위 예시

figWidthCM  = 24;  % Figure 너비(cm)
figHeightCM = 24;  % Figure 높이(cm)

numRows = 4;  % subplot 행
numCols = 3;  % subplot 열

% 범례 라인 길이/두께 (compact)
legendTokenManual = [5, 2];  % 첫 번째 값=라인길이, 두 번째=두께(세로높이)

%% (2) 16개 Trip에 대한 legend 위치 (normalized 좌표 예시)
%   전압/전류 subplot용
legendPosVC_16 = [
  0.15, 0.715, 0.3, 0.12;  % Trip 1
  0.15, 0.495, 0.3, 0.12;   % Trip 2
  0.15, 0.275, 0.3, 0.12;  % Trip 3
  0.15, 0.06, 0.3, 0.12;  % Trip 4
  0.15, 0.715, 0.3, 0.12;  % Trip 5
  0.15, 0.495, 0.3, 0.12;   % Trip 6
  0.15, 0.275, 0.3, 0.12;  % Trip 7
  0.15, 0.06, 0.3, 0.12;  % Trip 8
  0.15, 0.715, 0.3, 0.12;  % Trip 9
  0.15, 0.495, 0.3, 0.12;   % Trip 10
  0.15, 0.275, 0.3, 0.12;  % Trip 11
  0.15, 0.06, 0.3, 0.12;  % Trip 12
  0.15, 0.715, 0.3, 0.12;  % Trip 13
  0.15, 0.495, 0.3, 0.12;   % Trip 14
  0.15, 0.275, 0.3, 0.12;  % Trip 15
  0.15, 0.06, 0.3, 0.12;  % Trip 16
];

%   SOC subplot용
legendPosSOC_16 = [
  0.68, 0.715, 0.3, 0.12;  % Trip 1
  0.68, 0.495, 0.3, 0.12;   % Trip 2
  0.68, 0.275, 0.3, 0.12;  % Trip 3
  0.68, 0.06, 0.3, 0.12;  % Trip 4
  0.68, 0.715, 0.3, 0.12;  % Trip 5
  0.68, 0.495, 0.3, 0.12;   % Trip 6
  0.68, 0.275, 0.3, 0.12;  % Trip 7
  0.68, 0.06, 0.3, 0.12;  % Trip 8
  0.68, 0.715, 0.3, 0.12;  % Trip 9
  0.68, 0.495, 0.3, 0.12;   % Trip 10
  0.68, 0.275, 0.3, 0.12;  % Trip 11
  0.68, 0.06, 0.3, 0.12;  % Trip 12
  0.68, 0.715, 0.3, 0.12;  % Trip 13
  0.68, 0.495, 0.3, 0.12;   % Trip 14
  0.68, 0.275, 0.3, 0.12;  % Trip 15
  0.68, 0.06, 0.3, 0.12;  % Trip 16
];

%% (3) 색깔 배열
p_colors = [
    0.00000, 0.45098, 0.76078;  % (Blue)
    0.93725, 0.75294, 0.00000;  % (Yellow)
    0.80392, 0.32549, 0.29803;  % (Red)
    0.12549, 0.52157, 0.30588;  % (Green)
    0.57255, 0.36863, 0.62353;
    0.88235, 0.52941, 0.15294;
    0.30196, 0.73333, 0.83529;
    0.93333, 0.29803, 0.59216;
    0.49412, 0.38039, 0.28235;
    0.45490, 0.46275, 0.47059
];

%% (4) 데이터 로드 (사용자 환경 맞게 수정)
load('G:\공유 드라이브\Battery Software Lab\Projects\DRT\Wisconsin_DRT\udds_data_soc_results.mat',...
     'udds_data_soc_results');
% 16개 Trip이 있다고 가정

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (5) Figure 1: Trip 1 ~ 4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Units','centimeters','Position',[2 2 figWidthCM figHeightCM]);

trip_start = 1;
trip_end   = 4;
sp_count   = 1;  % subplot 카운트

for trip_idx = trip_start:trip_end
    %% ---- (a) 전압/전류 ----
    subplot(numRows, numCols, sp_count);

    t      = udds_data_soc_results(trip_idx).t;
    V_meas = udds_data_soc_results(trip_idx).V;
    V_est  = udds_data_soc_results(trip_idx).V_est;
    I      = udds_data_soc_results(trip_idx).I;

    yyaxis left
    plot(t, V_meas, 'LineWidth', 0.5, ...
        'Color', [p_colors(1,:) 0.6], 'LineStyle','-', ...
        'HandleVisibility','off');
    hold on;
    p1_legend = plot(nan,nan,'LineWidth',lineWidthMeas,...
        'Color', p_colors(1,:), 'LineStyle','-', 'DisplayName','Meas.V');

    plot(t, V_est, 'LineWidth', lineWidthEst, ...
        'Color', [p_colors(3,:) 0.8], 'LineStyle','--', ...
        'HandleVisibility','off');
    p2_legend = plot(nan,nan,'LineWidth',lineWidthEst,...
        'Color', p_colors(3,:), 'LineStyle','--', 'DisplayName','Est.V');

    ylabel('Voltage [V]', 'FontSize', axisLabelFontSize);

    yyaxis right
    p3 = plot(t, I, 'LineWidth', lineWidthCurr, ...
        'Color', p_colors(4,:), 'LineStyle','-', 'DisplayName','Current');
    ylabel('Current [A]', 'FontSize', axisLabelFontSize);
    ylim(currentYLim);
    xlabel('Time [s]', 'FontSize', axisLabelFontSize);

    yyaxis left;  set(gca,'XColor','k','YColor','k','FontSize',axisTickFontSize);
    yyaxis right; set(gca,'XColor','k','YColor','k','FontSize',axisTickFontSize);

    % legend
    leg_a = legend([p1_legend p2_legend p3], ...
                   'Orientation','horizontal',...
                   'Location','none');
    set(leg_a, 'Box','off');
    set(leg_a, 'FontSize', legendFontSize, 'ItemTokenSize', legendTokenManual);
    set(leg_a, 'Units','normalized', ...
        'Position', legendPosVC_16(trip_idx,:));

    sp_count = sp_count + 1;

    %% ---- (b) DRT (범례 없음) ----
    subplot(numRows, numCols, sp_count);
    theta_ = udds_data_soc_results(trip_idx).theta_discrete;
    gamma_ = udds_data_soc_results(trip_idx).gamma_est;

    plot(theta_, gamma_, 'LineWidth', lineWidthMeas, ...
         'Color', p_colors(1,:), 'LineStyle','-');
    xlabel('\theta = ln(\tau [s])', 'FontSize', axisLabelFontSize);
    ylabel('\gamma [\Omega]',       'FontSize', axisLabelFontSize);
    set(gca,'XColor','k','YColor','k','FontSize',axisTickFontSize);

    sp_count = sp_count + 1;

    %% ---- (c) SOC (True_SOC 포함) ----
    subplot(numRows, numCols, sp_count);

    % True_SOC 먼저 플롯 (회색)
    True_   = udds_data_soc_results(trip_idx).True_SOC;
    p0c = plot(t, True_, ...
               'LineWidth', lineWidthSOC, ...
               'Color', [0.5 0.5 0.5], ...
               'LineStyle','-', ...
               'DisplayName','True');
    hold on;

    CC_    = udds_data_soc_results(trip_idx).CC_SOC;
    SOC1RC = udds_data_soc_results(trip_idx).SOC_1RC;
    SOC2RC = udds_data_soc_results(trip_idx).SOC_2RC;
    SOCDRT = udds_data_soc_results(trip_idx).SOC_DRT;

    p1c = plot(t, CC_, 'LineWidth', lineWidthSOC,...
               'Color', p_colors(1,:), 'LineStyle','-', 'DisplayName','CC');
    p2c = plot(t, SOC1RC, 'LineWidth', lineWidthSOC,...
               'Color', p_colors(3,:), 'LineStyle','-', 'DisplayName','1RC');
    p3c = plot(t, SOC2RC, 'LineWidth', lineWidthSOC,...
               'Color', p_colors(2,:), 'LineStyle','-', 'DisplayName','2RC');
    p4c = plot(t, SOCDRT,'LineWidth', lineWidthSOC,...
               'Color', p_colors(4,:), 'LineStyle','-', 'DisplayName','DRT');

    xlabel('Time [s]', 'FontSize', axisLabelFontSize);
    ylabel('SOC',      'FontSize', axisLabelFontSize);
    set(gca,'XColor','k','YColor','k','FontSize',axisTickFontSize);

    % SOC 범례도 horizontal 설정 (True_SOC 포함)
    leg_c = legend([p0c p1c p2c p3c p4c], ...
                   'Orientation','horizontal',...
                   'Location','none');
    set(leg_c, 'Box','off');
    set(leg_c, 'FontSize', legendFontSize, 'ItemTokenSize', legendTokenManual);
    set(leg_c, 'Units','normalized', ...
        'Position', legendPosSOC_16(trip_idx,:));

    sp_count = sp_count + 1;
end

exportgraphics(gcf, 'Fig1_Trips1to4_compactLegend.png','Resolution',300);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (6) Figure 2: Trip 5 ~ 8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Units','centimeters','Position',[2 2 figWidthCM figHeightCM]);

trip_start = 5;
trip_end   = 8;
sp_count   = 1;

for trip_idx = trip_start:trip_end
    % ---- (a) 전압/전류 ----
    subplot(numRows, numCols, sp_count);

    t      = udds_data_soc_results(trip_idx).t;
    V_meas = udds_data_soc_results(trip_idx).V;
    V_est  = udds_data_soc_results(trip_idx).V_est;
    I      = udds_data_soc_results(trip_idx).I;

    yyaxis left
    plot(t, V_meas, 'LineWidth', 0.5, 'Color', [p_colors(1,:) 0.6], ...
         'LineStyle','-', 'HandleVisibility','off');
    hold on;
    p1_legend = plot(nan,nan,'LineWidth',lineWidthMeas,...
        'Color', p_colors(1,:), 'LineStyle','-', 'DisplayName','Meas.V');

    plot(t, V_est, 'LineWidth', lineWidthEst,...
        'Color', [p_colors(3,:) 0.8], 'LineStyle','--','HandleVisibility','off');
    p2_legend = plot(nan,nan,'LineWidth',lineWidthEst,...
        'Color', p_colors(3,:), 'LineStyle','--', 'DisplayName','Est.V');

    ylabel('Voltage [V]', 'FontSize', axisLabelFontSize);

    yyaxis right
    p3 = plot(t, I, 'LineWidth', lineWidthCurr,...
        'Color', p_colors(4,:), 'LineStyle','-', 'DisplayName','Current');
    ylabel('Current [A]', 'FontSize', axisLabelFontSize);
    ylim(currentYLim);
    xlabel('Time [s]',    'FontSize', axisLabelFontSize);

    yyaxis left;  set(gca,'XColor','k','YColor','k','FontSize',axisTickFontSize);
    yyaxis right; set(gca,'XColor','k','YColor','k','FontSize',axisTickFontSize);

    leg_a = legend([p1_legend p2_legend p3], ...
                   'Orientation','horizontal',...
                   'Location','none');
    set(leg_a, 'Box','off', ...
               'FontSize', legendFontSize, ...
               'ItemTokenSize', legendTokenManual, ...
               'Units','normalized', ...
               'Position', legendPosVC_16(trip_idx,:));

    sp_count = sp_count + 1;

    % ---- (b) DRT ----
    subplot(numRows, numCols, sp_count);
    theta_ = udds_data_soc_results(trip_idx).theta_discrete;
    gamma_ = udds_data_soc_results(trip_idx).gamma_est;

    plot(theta_, gamma_, 'LineWidth', lineWidthMeas, ...
         'Color', p_colors(1,:), 'LineStyle','-');
    xlabel('\theta = ln(\tau [s])', 'FontSize', axisLabelFontSize);
    ylabel('\gamma [\Omega]',       'FontSize', axisLabelFontSize);
    set(gca,'XColor','k','YColor','k','FontSize',axisTickFontSize);

    sp_count = sp_count + 1;

    % ---- (c) SOC (True_SOC 포함) ----
    subplot(numRows, numCols, sp_count);

    True_   = udds_data_soc_results(trip_idx).True_SOC;
    p0c = plot(t, True_, ...
               'LineWidth', lineWidthSOC, ...
               'Color', [0.5 0.5 0.5], ...
               'LineStyle','-', ...
               'DisplayName','True');
    hold on;

    CC_    = udds_data_soc_results(trip_idx).CC_SOC;
    SOC1RC = udds_data_soc_results(trip_idx).SOC_1RC;
    SOC2RC = udds_data_soc_results(trip_idx).SOC_2RC;
    SOCDRT = udds_data_soc_results(trip_idx).SOC_DRT;

    p1c = plot(t, CC_, 'LineWidth', lineWidthSOC,...
               'Color', p_colors(1,:), 'LineStyle','-', 'DisplayName','CC');
    p2c = plot(t, SOC1RC,'LineWidth', lineWidthSOC,...
               'Color', p_colors(3,:), 'LineStyle','-', 'DisplayName','1RC');
    p3c = plot(t, SOC2RC,'LineWidth', lineWidthSOC,...
               'Color', p_colors(2,:), 'LineStyle','-', 'DisplayName','2RC');
    p4c = plot(t, SOCDRT,'LineWidth', lineWidthSOC,...
               'Color', p_colors(4,:), 'LineStyle','-', 'DisplayName','DRT');

    xlabel('Time [s]', 'FontSize', axisLabelFontSize);
    ylabel('SOC',      'FontSize', axisLabelFontSize);
    set(gca,'XColor','k','YColor','k','FontSize',axisTickFontSize);

    leg_c = legend([p0c p1c p2c p3c p4c], ...
                   'Orientation','horizontal',...
                   'Location','none');
    set(leg_c, 'Box','off', ...
               'FontSize', legendFontSize, ...
               'ItemTokenSize', legendTokenManual, ...
               'Units','normalized', ...
               'Position', legendPosSOC_16(trip_idx,:));

    sp_count = sp_count + 1;
end

exportgraphics(gcf, 'Fig2_Trips5to8_compactLegend.png','Resolution',300);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (7) Figure 3: Trip 9 ~ 12
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Units','centimeters','Position',[3 3 figWidthCM figHeightCM]);

trip_start = 9;
trip_end   = 12;
sp_count = 1;

for trip_idx = trip_start:trip_end
    %% (a) Voltage & Current
    subplot(numRows, numCols, sp_count);
    t      = udds_data_soc_results(trip_idx).t;
    V_meas = udds_data_soc_results(trip_idx).V;
    V_est  = udds_data_soc_results(trip_idx).V_est;
    I      = udds_data_soc_results(trip_idx).I;

    yyaxis left
    plot(t, V_meas, 'LineWidth', 0.5, 'Color', [p_colors(1,:) 0.6], ...
         'LineStyle','-', 'HandleVisibility','off');
    hold on;
    p1_legend = plot(nan,nan,'LineWidth',lineWidthMeas,...
        'Color', p_colors(1,:), 'LineStyle','-', 'DisplayName','Meas.V');

    plot(t, V_est, 'LineWidth', lineWidthEst,...
        'Color', [p_colors(3,:) 0.8], 'LineStyle','--','HandleVisibility','off');
    p2_legend = plot(nan,nan,'LineWidth',lineWidthEst,...
        'Color', p_colors(3,:), 'LineStyle','--','DisplayName','Est.V');

    ylabel('Voltage [V]', 'FontSize', axisLabelFontSize);

    yyaxis right
    p3 = plot(t, I, 'LineWidth', lineWidthCurr,...
        'Color', p_colors(4,:), 'LineStyle','-', 'DisplayName','Current');
    ylabel('Current [A]', 'FontSize', axisLabelFontSize);
    ylim(currentYLim);
    xlabel('Time [s]', 'FontSize', axisLabelFontSize);

    yyaxis left;  set(gca,'XColor','k','YColor','k','FontSize',axisTickFontSize);
    yyaxis right; set(gca,'XColor','k','YColor','k','FontSize',axisTickFontSize);

    leg_a = legend([p1_legend p2_legend p3], ...
                   'Orientation','horizontal',...
                   'Location','none');
    set(leg_a, 'Box','off', ...
               'FontSize', legendFontSize, ...
               'ItemTokenSize', legendTokenManual, ...
               'Units','normalized', ...
               'Position', legendPosVC_16(trip_idx,:));

    sp_count = sp_count + 1;

    %% (b) DRT
    subplot(numRows, numCols, sp_count);
    theta_ = udds_data_soc_results(trip_idx).theta_discrete;
    gamma_ = udds_data_soc_results(trip_idx).gamma_est;

    plot(theta_, gamma_, 'LineWidth', lineWidthMeas,...
         'Color', p_colors(1,:), 'LineStyle','-');
    xlabel('\theta = ln(\tau [s])', 'FontSize', axisLabelFontSize);
    ylabel('\gamma [\Omega]', 'FontSize', axisLabelFontSize);
    set(gca,'XColor','k','YColor','k','FontSize',axisTickFontSize);

    sp_count = sp_count + 1;

    %% (c) SOC (True_SOC 포함)
    subplot(numRows, numCols, sp_count);

    True_   = udds_data_soc_results(trip_idx).True_SOC;
    p0c = plot(t, True_, ...
               'LineWidth', lineWidthSOC, ...
               'Color', [0.5 0.5 0.5], ...
               'LineStyle','-', ...
               'DisplayName','True');
    hold on;

    CC_    = udds_data_soc_results(trip_idx).CC_SOC;
    SOC1RC = udds_data_soc_results(trip_idx).SOC_1RC;
    SOC2RC = udds_data_soc_results(trip_idx).SOC_2RC;
    SOCDRT = udds_data_soc_results(trip_idx).SOC_DRT;

    p1c = plot(t, CC_,'LineWidth', lineWidthSOC,...
               'Color', p_colors(1,:), 'LineStyle','-', 'DisplayName','CC');
    p2c = plot(t, SOC1RC,'LineWidth', lineWidthSOC,...
               'Color', p_colors(3,:), 'LineStyle','-', 'DisplayName','1RC');
    p3c = plot(t, SOC2RC,'LineWidth', lineWidthSOC,...
               'Color', p_colors(2,:), 'LineStyle','-', 'DisplayName','2RC');
    p4c = plot(t, SOCDRT,'LineWidth', lineWidthSOC,...
               'Color', p_colors(4,:), 'LineStyle','-', 'DisplayName','DRT');

    xlabel('Time [s]', 'FontSize', axisLabelFontSize);
    ylabel('SOC',      'FontSize', axisLabelFontSize);
    set(gca,'XColor','k','YColor','k','FontSize',axisTickFontSize);

    leg_c = legend([p0c p1c p2c p3c p4c], ...
                   'Orientation','horizontal',...
                   'Location','none');
    set(leg_c, 'Box','off', ...
               'FontSize', legendFontSize, ...
               'ItemTokenSize', legendTokenManual, ...
               'Units','normalized', ...
               'Position', legendPosSOC_16(trip_idx,:));

    sp_count = sp_count + 1;
end

exportgraphics(gcf, 'Fig3_Trips9to12_compactLegend.png','Resolution',300);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (8) Figure 4: Trip 13 ~ 16
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Units','centimeters','Position',[4 4 figWidthCM figHeightCM]);

trip_start = 13;
trip_end   = 16;
sp_count   = 1;

for trip_idx = trip_start:trip_end
    %% (a) Voltage & Current
    subplot(numRows, numCols, sp_count);
    t      = udds_data_soc_results(trip_idx).t;
    V_meas = udds_data_soc_results(trip_idx).V;
    V_est  = udds_data_soc_results(trip_idx).V_est;
    I      = udds_data_soc_results(trip_idx).I;

    yyaxis left
    plot(t, V_meas, 'LineWidth', 0.5,...
        'Color', [p_colors(1,:) 0.6], 'LineStyle','-',...
        'HandleVisibility','off');
    hold on;
    p1_legend = plot(nan,nan,'LineWidth',lineWidthMeas,...
        'Color', p_colors(1,:), 'LineStyle','-', 'DisplayName','Meas.V');

    plot(t, V_est, 'LineWidth', lineWidthEst,...
        'Color', [p_colors(3,:) 0.8], 'LineStyle','--',...
        'HandleVisibility','off');
    p2_legend = plot(nan,nan,'LineWidth',lineWidthEst,...
        'Color', p_colors(3,:), 'LineStyle','--', 'DisplayName','Est.V');

    ylabel('Voltage [V]', 'FontSize', axisLabelFontSize);

    yyaxis right
    p3 = plot(t, I, 'LineWidth', lineWidthCurr,...
        'Color', p_colors(4,:), 'LineStyle','-', 'DisplayName','Current');
    ylabel('Current [A]', 'FontSize', axisLabelFontSize);
    ylim(currentYLim);
    xlabel('Time [s]', 'FontSize', axisLabelFontSize);

    yyaxis left;  set(gca,'XColor','k','YColor','k','FontSize',axisTickFontSize);
    yyaxis right; set(gca,'XColor','k','YColor','k','FontSize',axisTickFontSize);

    leg_a = legend([p1_legend p2_legend p3], ...
                   'Orientation','horizontal',...
                   'Location','none');
    set(leg_a, 'Box','off', ...
               'FontSize', legendFontSize, ...
               'ItemTokenSize', legendTokenManual, ...
               'Units','normalized', ...
               'Position', legendPosVC_16(trip_idx,:));

    sp_count = sp_count + 1;

    %% (b) DRT
    subplot(numRows, numCols, sp_count);
    theta_ = udds_data_soc_results(trip_idx).theta_discrete;
    gamma_ = udds_data_soc_results(trip_idx).gamma_est;

    plot(theta_, gamma_, 'LineWidth', lineWidthMeas,...
         'Color', p_colors(1,:), 'LineStyle','-');
    xlabel('\theta = ln(\tau [s])', 'FontSize', axisLabelFontSize);
    ylabel('\gamma [\Omega]',       'FontSize', axisLabelFontSize);
    set(gca,'XColor','k','YColor','k','FontSize',axisTickFontSize);

    sp_count = sp_count + 1;

    %% (c) SOC (True_SOC 포함)
    subplot(numRows, numCols, sp_count);

    True_   = udds_data_soc_results(trip_idx).True_SOC;
    p0c = plot(t, True_, ...
               'LineWidth', lineWidthSOC, ...
               'Color', [0.5 0.5 0.5], ...
               'LineStyle','-', ...
               'DisplayName','True');
    hold on;

    CC_    = udds_data_soc_results(trip_idx).CC_SOC;
    SOC1RC = udds_data_soc_results(trip_idx).SOC_1RC;
    SOC2RC = udds_data_soc_results(trip_idx).SOC_2RC;
    SOCDRT = udds_data_soc_results(trip_idx).SOC_DRT;

    p1c = plot(t, CC_, 'LineWidth', lineWidthSOC,...
               'Color', p_colors(1,:), 'LineStyle','-', 'DisplayName','CC');
    p2c = plot(t, SOC1RC,'LineWidth', lineWidthSOC,...
               'Color', p_colors(3,:), 'LineStyle','-', 'DisplayName','1RC');
    p3c = plot(t, SOC2RC,'LineWidth', lineWidthSOC,...
               'Color', p_colors(2,:), 'LineStyle','-', 'DisplayName','2RC');
    p4c = plot(t, SOCDRT,'LineWidth', lineWidthSOC,...
               'Color', p_colors(4,:), 'LineStyle','-', 'DisplayName','DRT');

    xlabel('Time [s]', 'FontSize', axisLabelFontSize);
    ylabel('SOC',      'FontSize', axisLabelFontSize);
    set(gca,'XColor','k','YColor','k','FontSize',axisTickFontSize);

    leg_c = legend([p0c p1c p2c p3c p4c], ...
                   'Orientation','horizontal',...
                   'Location','none');
    set(leg_c, 'Box','off', ...
               'FontSize', legendFontSize, ...
               'ItemTokenSize', legendTokenManual, ...
               'Units','normalized', ...
               'Position', legendPosSOC_16(trip_idx,:));

    sp_count = sp_count + 1;
end

exportgraphics(gcf, 'Fig4_Trips13to16_compactLegend.png','Resolution',300);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 끝
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

