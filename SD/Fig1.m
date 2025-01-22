clc; clear; close all;

%% (1) Load Data
file_path = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\SD_lambda\';
mat_files = dir(fullfile(file_path, '*.mat'));

% 모든 .mat 파일 불러오기
for file = mat_files'
    load(fullfile(file_path, file.name));
end

scenario_set = [6, 7, 8, 9];
target_type  = 'A';

% 예: AS1_1per에 대해 시나리오 6,7,8,9를 표시하는 2x2 subplot figure
scenarios_to_plot = [6, 7, 8, 9];
figure('Name','AS2_1per - Scenarios 6,7,8,9','NumberTitle','off');

for idx = 1:length(scenarios_to_plot)
    s = scenarios_to_plot(idx);
    subplot(2, 2, idx);
    
    yyaxis left
    plot(AS2_1per_new(s).t, AS2_1per_new(s).I, 'b-', 'LineWidth', 1.5);
    ylabel('Current (A)', 'FontSize', 12);
    hold on;
    
    yyaxis right
    plot(AS2_1per_new(s).t, AS2_1per_new(s).V, 'r-', 'LineWidth', 1.5);
    ylabel('Voltage (V)', 'FontSize', 12);
    
    xlabel('Time (s)', 'FontSize', 12);
    title(['Scenario ', num2str(AS2_1per_new(s).SN)], 'FontSize', 14);  % 시나리오 번호 사용
    legend('Current', 'Voltage', 'Location', 'best');
    hold off;
end

sgtitle('AS2\_1per: Scenarios 6,7,8,9', 'FontSize', 16);