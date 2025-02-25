%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run_FIG2_Supp.m (Script Version) - Full-width + ItemTokenSize=[2,3]
%  - Trip 1 ~ 16에 대해 (a) Voltage, (b) DRT, (c) SOC를
%    2개의 Figure로 나누어 Supplementary용으로 보여주는 예시
%
% Figure 1: Trip 1 ~ 8  (8행×3열 subplot)
% Figure 2: Trip 9 ~ 16 (8행×3열 subplot)
%
% 마지막 trip 제외 → 실제로는 (num_trips-1)=16개
% 폭(figWidth)=18 cm -> 저널 full-width 정도
% 높이(figHeight)=28 cm -> subplot이 많아 충분한 높이 필요
% Legend ItemTokenSize=[2,3]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear; close all;

%% (1) 기본 파라미터 설정
axisTickFontSize   = 8;
axisLabelFontSize  = 9;
legendFontSize     = 6;
annotationFontSize = 9;

lineWidthMeas = 1;
lineWidthEst  = 1;
lineWidthCurr = 1;
lineWidthSOC  = 1;

% Legend 항목 간 간격
legendItemTokenSize = [2, 3];

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

% Figure 사이즈 (가로×세로, cm) - Full-width 약 17~18cm
figWidth  = 18;
figHeight = 25;

%% (2) 데이터 로드
% 실제 경로/파일명에 맞춰 수정하세요
load('G:\공유 드라이브\Battery Software Lab\Projects\DRT\Wisconsin_DRT\udds_data_soc_results.mat',...
     'udds_data_soc_results');
num_trips = length(udds_data_soc_results);

%% (3) Figure 1: Trip 1 ~ 8
figure('Units','centimeters','Position',[1 1 figWidth figHeight]);

trip_start = 1;
trip_end   = 8;   % Trip 1~8
row_count  = trip_end - trip_start + 1;  % 8행

for row_idx = 1:row_count
    trip_idx = trip_start + (row_idx - 1);  % 실제 Trip 번호 (1~8)

    % -- (a) 전압 비교 --
    subplot_idx_a = (row_idx-1)*3 + 1;
    subplot(row_count, 3, subplot_idx_a);

    t      = udds_data_soc_results(trip_idx).t;
    V_meas = udds_data_soc_results(trip_idx).V;
    V_est  = udds_data_soc_results(trip_idx).V_est;
    I      = udds_data_soc_results(trip_idx).I;

    yyaxis left
    p1 = plot(t, V_meas, 'LineWidth', lineWidthMeas, ...
        'Color', p_colors(1,:), 'LineStyle','-','DisplayName','Meas.V');
    hold on;
    p2 = plot(t, V_est,  'LineWidth', lineWidthEst,  ...
        'Color', p_colors(3,:), 'LineStyle','-','DisplayName','Est.V');
    ylabel('Voltage [V]', 'FontSize', axisLabelFontSize);

    yyaxis right
    p3 = plot(t, I, 'LineWidth', lineWidthCurr, ...
        'Color', p_colors(4,:), 'LineStyle','-','DisplayName','Current');
    ylabel('Current [A]', 'FontSize', axisLabelFontSize);
    xlabel('Time [s]',    'FontSize', axisLabelFontSize);

    set(gca, 'FontSize', axisTickFontSize, 'YColor','k','XColor','k');

    leg_a = legend([p1 p2 p3], 'Location','best','Box','off','FontSize',legendFontSize);
    set(leg_a, 'ItemTokenSize', legendItemTokenSize);

    title(sprintf('Trip %d (a) Voltage', trip_idx), 'FontSize', annotationFontSize);

    % -- (b) DRT --
    subplot_idx_b = (row_idx-1)*3 + 2;
    subplot(row_count, 3, subplot_idx_b);

    theta_ = udds_data_soc_results(trip_idx).theta_discrete;
    gamma_ = udds_data_soc_results(trip_idx).gamma_est;
    R0_    = udds_data_soc_results(trip_idx).R0_est;

    plot(theta_, gamma_, 'LineWidth', lineWidthMeas, ...
        'Color', p_colors(8,:), 'LineStyle','-');
    xlabel('\theta = ln(\tau [s])', 'FontSize', axisLabelFontSize);
    ylabel('\gamma [\Omega]',       'FontSize', axisLabelFontSize);
    set(gca, 'FontSize', axisTickFontSize);

    % R0 표기
    xlm = xlim; ylm = ylim;
    text_str = sprintf('R_0 = %.3e \\Omega', R0_);
    text(xlm(1) + 0.05*range(xlm), ylm(2) - 0.15*range(ylm), ...
        text_str, 'FontSize', axisTickFontSize, 'Interpreter','tex','Color','k');

    title(sprintf('Trip %d (b) DRT', trip_idx), 'FontSize', annotationFontSize);

    % -- (c) SOC --
    subplot_idx_c = (row_idx-1)*3 + 3;
    subplot(row_count, 3, subplot_idx_c);

    CC_   = udds_data_soc_results(trip_idx).CC_SOC;
    SOC1RC= udds_data_soc_results(trip_idx).SOC_1RC;
    SOC2RC= udds_data_soc_results(trip_idx).SOC_2RC;
    SOCDRT= udds_data_soc_results(trip_idx).SOC_DRT;

    p1c = plot(t, CC_,   'LineWidth', lineWidthSOC, ...
        'Color', p_colors(1,:), 'LineStyle','-', 'DisplayName','CC'); hold on;
    p2c = plot(t, SOC1RC,'LineWidth', lineWidthSOC, ...
        'Color', p_colors(3,:), 'LineStyle','-', 'DisplayName','1RC');
    p3c = plot(t, SOC2RC,'LineWidth', lineWidthSOC, ...
        'Color', p_colors(2,:), 'LineStyle','-', 'DisplayName','2RC');
    p4c = plot(t, SOCDRT,'LineWidth', lineWidthSOC, ...
        'Color', p_colors(4,:), 'LineStyle','-', 'DisplayName','DRT');

    xlabel('Time [s]', 'FontSize', axisLabelFontSize);
    ylabel('SOC',      'FontSize', axisLabelFontSize);
    set(gca, 'FontSize', axisTickFontSize, 'YColor','k','XColor','k');

    leg_c = legend([p1c p2c p3c p4c], 'Location','best','Box','off','FontSize',legendFontSize);
    set(leg_c, 'ItemTokenSize', legendItemTokenSize);

    title(sprintf('Trip %d (c) SOC', trip_idx), 'FontSize', annotationFontSize);
end

% 첫 번째 Figure 저장
exportgraphics(gcf, 'Supplement_Fig1_Trips1to8.png','Resolution',300);

%% (4) Figure 2: Trip 9 ~ 16
figure('Units','centimeters','Position',[2 2 figWidth figHeight]);

trip_start2 = 9;
trip_end2   = 16;   % Trip 9~16
row_count2  = trip_end2 - trip_start2 + 1;  % 8행

for row_idx = 1:row_count2
    trip_idx = trip_start2 + (row_idx - 1);  % 실제 Trip 번호 (9~16)

    % -- (a) Voltage --
    subplot_idx_a = (row_idx-1)*3 + 1;
    subplot(row_count2, 3, subplot_idx_a);

    t      = udds_data_soc_results(trip_idx).t;
    V_meas = udds_data_soc_results(trip_idx).V;
    V_est  = udds_data_soc_results(trip_idx).V_est;
    I      = udds_data_soc_results(trip_idx).I;

    yyaxis left
    p1 = plot(t, V_meas, 'LineWidth', lineWidthMeas, ...
        'Color', p_colors(1,:), 'LineStyle','-','DisplayName','Meas.V');
    hold on;
    p2 = plot(t, V_est,  'LineWidth', lineWidthEst,  ...
        'Color', p_colors(3,:), 'LineStyle','-', 'DisplayName','Est.V');
    ylabel('Voltage [V]', 'FontSize', axisLabelFontSize);

    yyaxis right
    p3 = plot(t, I, 'LineWidth', lineWidthCurr, ...
        'Color', p_colors(4,:), 'LineStyle','-', 'DisplayName','Current');
    ylabel('Current [A]', 'FontSize', axisLabelFontSize);
    xlabel('Time [s]',    'FontSize', axisLabelFontSize);

    set(gca, 'FontSize', axisTickFontSize, 'YColor','k','XColor','k');

    leg_a2 = legend([p1 p2 p3], 'Location','best','Box','off','FontSize',legendFontSize);
    set(leg_a2, 'ItemTokenSize', legendItemTokenSize);

    title(sprintf('Trip %d (a) Voltage', trip_idx), 'FontSize', annotationFontSize);

    % -- (b) DRT --
    subplot_idx_b = (row_idx-1)*3 + 2;
    subplot(row_count2, 3, subplot_idx_b);

    theta_ = udds_data_soc_results(trip_idx).theta_discrete;
    gamma_ = udds_data_soc_results(trip_idx).gamma_est;
    R0_    = udds_data_soc_results(trip_idx).R0_est;

    plot(theta_, gamma_, 'LineWidth', lineWidthMeas, ...
        'Color', p_colors(8,:), 'LineStyle','-');
    xlabel('\theta = ln(\tau [s])', 'FontSize', axisLabelFontSize);
    ylabel('\gamma [\Omega]',       'FontSize', axisLabelFontSize);
    set(gca, 'FontSize', axisTickFontSize);

    % R0 표기
    xlm = xlim; ylm = ylim;
    text_str = sprintf('R_0 = %.3e \\Omega', R0_);
    text(xlm(1)+0.05*range(xlm), ylm(2)-0.15*range(ylm), ...
        text_str, 'FontSize', axisTickFontSize, 'Interpreter','tex','Color','k');

    title(sprintf('Trip %d (b) DRT', trip_idx), 'FontSize', annotationFontSize);

    % -- (c) SOC --
    subplot_idx_c = (row_idx-1)*3 + 3;
    subplot(row_count2, 3, subplot_idx_c);

    CC_   = udds_data_soc_results(trip_idx).CC_SOC;
    SOC1RC= udds_data_soc_results(trip_idx).SOC_1RC;
    SOC2RC= udds_data_soc_results(trip_idx).SOC_2RC;
    SOCDRT= udds_data_soc_results(trip_idx).SOC_DRT;

    p1c = plot(t, CC_,   'LineWidth', lineWidthSOC, ...
        'Color', p_colors(1,:), 'LineStyle','-', 'DisplayName','CC'); hold on;
    p2c = plot(t, SOC1RC,'LineWidth', lineWidthSOC, ...
        'Color', p_colors(3,:), 'LineStyle','-', 'DisplayName','1RC');
    p3c = plot(t, SOC2RC,'LineWidth', lineWidthSOC, ...
        'Color', p_colors(2,:), 'LineStyle','-', 'DisplayName','2RC');
    p4c = plot(t, SOCDRT,'LineWidth', lineWidthSOC, ...
        'Color', p_colors(4,:), 'LineStyle','-', 'DisplayName','DRT');

    xlabel('Time [s]', 'FontSize', axisLabelFontSize);
    ylabel('SOC',      'FontSize', axisLabelFontSize);
    set(gca, 'FontSize', axisTickFontSize, 'YColor','k','XColor','k');

    leg_c2 = legend([p1c p2c p3c p4c], 'Location','best','Box','off','FontSize',legendFontSize);
    set(leg_c2, 'ItemTokenSize', legendItemTokenSize);

    title(sprintf('Trip %d (c) SOC', trip_idx), 'FontSize', annotationFontSize);
end

% 두 번째 Figure 저장
exportgraphics(gcf, 'Supplement_Fig2_Trips9to16.png','Resolution',300);

