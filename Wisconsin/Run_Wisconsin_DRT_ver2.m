%% Run_Wisconsin_DRT_ver2.m (스크립트)
% -------------------------------------------------------------------------
%  1) 'udds_data.mat'와 'soc_ocv.mat'를 불러와 DRT를 추정합니다.
%  2) 각 Trip별로 단일 DRT 추정과 부트스트랩(500회) 추정을 수행하여,
%     부트스트랩 평균, 5% 및 95% 구간을 계산하고 fill로 음영 표시합니다.
%  3) Trip #1, #8, #16에 대해서 별도 플롯도 생성합니다.
%  4) 최종 결과는 'udds_data.mat' 등으로 저장합니다.
%
%  [주의] DRT_estimation_aug 함수(또는 동일 기능의 함수)가 MATLAB 경로에 있어야 합니다.
% -------------------------------------------------------------------------

%% (0) 초기화
clear; clc; close all;

% (0-1) 폰트 및 색상 설정
axisFontSize   = 14;
titleFontSize  = 16;
legendFontSize = 12;
labelFontSize  = 14;

color_voltage_meas = [0.3, 0.3, 0.3];         % 다크 그레이 (측정 전압)
color_voltage_est  = [0.494, 0.184, 0.556];   % 퍼플 계열 (추정 전압)
color_current      = [0, 0.45, 0.74];         % 딥 블루 (전류)
color_gamma        = [0.4, 0.2, 0.6];         % 보라 계열 (gamma)

%% (1) 데이터 로드
load('udds_data.mat', 'udds_data');  % 'udds_data' 구조체
load('soc_ocv.mat',  'soc_ocv');     % [SOC, OCV] 행렬
soc_values = soc_ocv(:,1);
ocv_values = soc_ocv(:,2);

%% (2) 파라미터 설정
n          = 201;     % RC 소자(또는 tau grid) 개수
dur        = 1370;    % tau_max [sec]
SOC_begin  = 0.9907;  
Q_batt     = 2.8153;  % [Ah]
lambda_hat = 0.385;   % DRT 정칙화 하이퍼파라미터
num_bs     = 500;     % 부트스트랩 반복 횟수

num_trips  = length(udds_data);

% 결과 저장용 변수들
gamma_est_all    = zeros(num_trips, n);
gamma_avg_all    = zeros(num_trips, n);
gamma_lower_all  = zeros(num_trips, n);
gamma_upper_all  = zeros(num_trips, n);

R0_est_all       = zeros(num_trips, 1);
V_est_all        = cell(num_trips, 1);
SOC_all          = cell(num_trips, 1);
SOC_mid_all      = zeros(num_trips, 1);

%% (3) 각 Trip 처리 (Trip 1 ~ num_trips-1)
for s = 1:num_trips-1
    fprintf('Processing Trip %d / %d...\n', s, num_trips);
    
    % --- (A) 데이터 추출 ---
    t = udds_data(s).t;
    I = udds_data(s).I;
    V = udds_data(s).V;
    dt = [t(1); diff(t)];
    
    % 현재 Trip의 SOC는 이전 Trip의 마지막 SOC를 시작값으로 함
    current_SOC_begin = SOC_begin;
    SOC = current_SOC_begin + cumtrapz(t, I)/(Q_batt*3600);
    SOC_all{s} = SOC;
    SOC_mid_all(s) = mean(SOC);
    
    % --- (B) 단일 DRT 추정 ---
    % DRT_estimation_aug 함수는 [gamma, R0, V_est, theta_discrete, ...]를 반환한다고 가정
    [gamma_est, R0_est, V_est, theta_discrete, ~, ~, ~] = ...
        DRT_estimation_aug(t, I, V, lambda_hat, n, dt, dur, ...
                           SOC, soc_values, ocv_values);
    
    % --- (C) 부트스트랩을 통한 DRT 재추정 ---
    % 부트스트랩 시에도 현재 Trip의 SOC 시작값, Q_batt, soc_values, ocv_values를 전달
    gamma_resample_all = bootstrap_uncertainty_aug_Wisconsin(...
        t, I, V, lambda_hat, n, dur, num_bs, current_SOC_begin, Q_batt, soc_values, ocv_values);
    
    % 부트스트랩 결과에서 평균, 5%, 95% 구간 계산
    gamma_avg   = mean(gamma_resample_all, 1);
    gamma_lower = prctile(gamma_resample_all,  5, 1);
    gamma_upper = prctile(gamma_resample_all, 95, 1);
    
    % --- (D) 결과 저장 ---
    gamma_est_all(s,:)    = gamma_est(:)';
    gamma_avg_all(s,:)    = gamma_avg;
    gamma_lower_all(s,:)  = gamma_lower;
    gamma_upper_all(s,:)  = gamma_upper;
    R0_est_all(s)         = R0_est;
    V_est_all{s}          = V_est;
    
    % 다음 Trip의 SOC 시작값은 이번 Trip의 마지막 SOC로 업데이트
    SOC_begin = SOC(end);
    
    % udds_data 구조체에 새 필드 추가
    udds_data(s).V_est          = V_est;
    udds_data(s).theta_discrete = theta_discrete;
    udds_data(s).gamma_est      = gamma_est;   % 단일 추정
    udds_data(s).gamma_avg      = gamma_avg;   % 부트스트랩 평균
    udds_data(s).gamma_lower    = gamma_lower; % 5%
    udds_data(s).gamma_upper    = gamma_upper; % 95%
    udds_data(s).R0_est         = R0_est;
    
    % --- (E) 각 Trip별 플롯 ---
    figure('Name', sprintf('Trip %d', s), 'NumberTitle','off');
    set(gcf, 'Position', [150, 150, 1200, 800]);
    
    % (1) Voltage 및 Current 플롯
    subplot(2,1,1);
    yyaxis left
    plot(t, V, 'Color', color_voltage_meas, 'LineWidth', 3, ...
         'DisplayName','Measured Voltage'); hold on;
    plot(t, V_est, '--', 'Color', color_voltage_est, 'LineWidth', 3, ...
         'DisplayName','Estimated Voltage');
    ylabel('Voltage [V]', 'FontSize', labelFontSize, 'Color', color_voltage_meas);
    set(gca, 'YColor', color_voltage_meas);
    
    yyaxis right
    plot(t, I, '-', 'Color', color_current, 'LineWidth', 3, ...
         'DisplayName','Current');
    ylabel('Current [A]', 'FontSize', labelFontSize, 'Color', color_current);
    set(gca, 'YColor', color_current);
    xlabel('Time [s]', 'FontSize', labelFontSize);
    title(sprintf('Trip %d: Voltage and Current', s), 'FontSize', titleFontSize);
    legend('FontSize', legendFontSize, 'Location','best');
    set(gca, 'FontSize', axisFontSize);
    hold off;
    
    % (2) DRT 플롯 (theta vs. gamma)
    subplot(2,1,2);
    hold on;
    % fill: 5% ~ 95% 구간 음영
    x_fill = [theta_discrete(:); flipud(theta_discrete(:))];
    y_fill = [gamma_lower(:);    flipud(gamma_upper(:))];
    hf = fill(x_fill, y_fill, color_gamma, 'LineStyle','none', ...
        'DisplayName','UNC'); % <-- UNC shadow
    set(hf, 'FaceAlpha', 0.2);
    % 부트스트랩 평균 곡선
    plot(theta_discrete, gamma_avg, '-', 'Color', color_gamma, 'LineWidth', 2.5, ...
         'DisplayName','Est.\gamma');  % <-- changed label
    % 단일 추정 결과 (점선) -- 주석 처리
    % plot(theta_discrete, gamma_est, '--', 'Color', color_gamma*0.7, 'LineWidth', 2, ...
    %      'DisplayName','Single-run \gamma');
    
    xlabel('\theta = ln(\tau [s])', 'FontSize', labelFontSize);
    ylabel('\gamma [\Omega]', 'FontSize', labelFontSize);
    title(sprintf('Trip %d: DRT (Bootstrap)', s), 'FontSize', titleFontSize);
    set(gca, 'FontSize', axisFontSize);
    
    legend('FontSize', legendFontSize, 'Location','best');
    hold off;
end

%% (4) 3D DRT Plot (부트스트랩 평균 기준)
soc_min = min(SOC_mid_all);
soc_max = max(SOC_mid_all);
if soc_max == soc_min
    soc_normalized = zeros(size(SOC_mid_all));
else
    soc_normalized = (SOC_mid_all - soc_min) / (soc_max - soc_min);
end

colormap_choice = jet;
num_colors = size(colormap_choice, 1);
colors = interp1(linspace(0, 1, num_colors), colormap_choice, soc_normalized);

figure('Name','3D DRT Plot','NumberTitle','off');
hold on;
for s = 1:num_trips-1
    x = SOC_mid_all(s) * ones(1, n);
    y = udds_data(s).theta_discrete(:);
    z = gamma_avg_all(s, :)';
    plot3(x, y, z, 'Color', colors(s, :), 'LineWidth', 1.5);
end
xlabel('SOC', 'FontSize', labelFontSize);
ylabel('\theta = ln(\tau [s])', 'FontSize', labelFontSize);
zlabel('\gamma [\Omega]', 'FontSize', labelFontSize);
title('Gamma Estimates vs. \theta and SOC (Bootstrap)', 'FontSize', titleFontSize);
grid on; zlim([0, 1.5]);
set(gca, 'FontSize', axisFontSize);
view(135, 30);
hold off;

colormap(colormap_choice);
c = colorbar;
c.Label.String = 'SOC';
c.Label.FontSize = labelFontSize;
c.Ticks = linspace(0, 1, 5);
c.TickLabels = arrayfun(@(x) sprintf('%.3f', x), linspace(soc_min, soc_max, 5), 'UniformOutput', false);

%% (5) Trip 1, 8, 16에 대한 별도 플롯
special_trips = [1, 8, 16];
for s = special_trips
    if s <= num_trips-1
        t = udds_data(s).t;
        I = udds_data(s).I;
        V = udds_data(s).V;
        V_est = udds_data(s).V_est;
        gamma_est = udds_data(s).gamma_est;     % 단일
        gamma_avg = udds_data(s).gamma_avg;     % 부트스트랩 평균
        gamma_lower = udds_data(s).gamma_lower; % 5%
        gamma_upper = udds_data(s).gamma_upper; % 95%
        theta_disc = udds_data(s).theta_discrete;
        R0_est = udds_data(s).R0_est;
        
        % Voltage & Current 플롯
        figure('Name', sprintf('Trip %d Voltage & Current', s), 'NumberTitle','off');
        yyaxis left
        plot(t, V, 'Color', color_voltage_meas, 'LineWidth', 3, ...
            'DisplayName','Measured Voltage'); hold on;
        plot(t, V_est, '--', 'Color', color_voltage_est, 'LineWidth', 3, ...
            'DisplayName','Estimated Voltage');
        ylabel('Voltage [V]', 'FontSize', labelFontSize, 'Color', color_voltage_meas);
        set(gca, 'YColor', color_voltage_meas);
        
        yyaxis right
        plot(t, I, '-', 'Color', color_current, 'LineWidth', 3, ...
            'DisplayName','Current');
        ylabel('Current [A]', 'FontSize', labelFontSize, 'Color', color_current);
        set(gca, 'YColor', color_current);
        xlabel('Time [s]', 'FontSize', labelFontSize);
        title(sprintf('Trip %d: Voltage and Current', s), 'FontSize', titleFontSize);
        legend('FontSize', legendFontSize, 'Location','best');
        set(gca, 'FontSize', axisFontSize);
        hold off;
        
        % DRT 플롯
        figure('Name', sprintf('Trip %d DRT', s), 'NumberTitle','off');
        hold on;
        x_fill = [theta_disc(:); flipud(theta_disc(:))];
        y_fill = [gamma_lower(:); flipud(gamma_upper(:))];
        hf = fill(x_fill, y_fill, color_gamma, 'LineStyle','none', ...
            'DisplayName','UNC'); % <-- UNC shadow
        set(hf, 'FaceAlpha', 0.2);
        plot(theta_disc, gamma_avg, '-', 'Color', color_gamma, 'LineWidth', 2.5, ...
             'DisplayName','Est.\gamma'); % <-- changed label
        % 단일 추정 결과 (점선) -- 주석 처리
        % plot(theta_disc, gamma_est, '--', 'Color', color_gamma*0.7, 'LineWidth', 2, ...
        %      'DisplayName','Single-run \gamma');
        
        xlabel('\theta = ln(\tau [s])', 'FontSize', labelFontSize);
        ylabel('\gamma [\Omega]', 'FontSize', labelFontSize);
        title(sprintf('Trip %d: DRT (Bootstrap)', s), 'FontSize', titleFontSize);
        set(gca, 'FontSize', axisFontSize);
        
        str_R0 = sprintf('$R_0 = %.1e\\ \\Omega$', R0_est);
        xlims = xlim; ylims = ylim;
        text_x = xlims(1) + 0.05*(xlims(2)-xlims(1));
        text_y = ylims(2) - 0.05*(ylims(2)-ylims(1));
        text(text_x, text_y, str_R0, 'FontSize', labelFontSize, 'Interpreter','latex');
        legend('FontSize', legendFontSize, 'Location','best');
        hold off;
    else
        warning('Trip %d does not exist in udds_data.', s);
    end
end

%% (6) 결과 저장
save('gamma_est_all.mat','gamma_est_all','SOC_mid_all');
save('gamma_avg_all.mat','gamma_avg_all','SOC_mid_all');   % 추가 저장
save('theta_discrete.mat','theta_discrete');
save('R0_est_all.mat','R0_est_all');

% 갱신된 udds_data 저장 (부트스트랩 결과 필드 포함)
save('udds_data.mat','udds_data');
disp('Run_Wisconsin_DRT_ver2: All done!');


