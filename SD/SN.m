clc; clear; close all;

%% (1) Load Data
file_path = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\SD_lambda\';
mat_files = dir(fullfile(file_path, '*.mat'));
for file = mat_files'
    load(fullfile(file_path, file.name));
end

%% 시나리오 및 subplot 배치
scenarios_to_plot = [1, 2, 3, 4];
labels_for_subplots = {'(b)','(c)','(d)','(e)'};

% Figure 생성 시, 크기 더 축소
f = figure('Name','AS1_1per - Scenarios 1,2,3,4',...
           'NumberTitle','off',...
           'Units','normalized',...
           'Position',[0.35 0.35 0.3 0.3]); 
% ↑ 화면 전체를 (0,0)~(1,1)로 봤을 때, 왼쪽 아래 (0.35,0.35)에 
% 너비 0.3, 높이 0.3만큼 차지하도록 설정

for idx = 1:length(scenarios_to_plot)
    s = scenarios_to_plot(idx);
    % Subplot 생성: 기본 간격을 조정
    ax = subplot(2, 2, idx);
    set(ax, 'Position', get(ax, 'Position') .* [1 1 0.9 0.9]); 
    % ↑ 간격 조정: subplot 크기를 약간 줄여서 더 압축된 레이아웃으로 만듦
    
    % ----- 왼쪽 축: Current (파랑 실선) -----
    yyaxis left
    plot(AS1_1per_new(s).t, AS1_1per_new(s).I, ...
         'Color', 'b', 'LineStyle', '-', 'LineWidth', 2);
    ylabel('Current (A)', 'FontSize', 10); % 폰트 크기 축소
    hold on;

    % ----- 오른쪽 축: Voltage (빨강 실선) -----
    yyaxis right
    plot(AS1_1per_new(s).t, AS1_1per_new(s).V, ...
         'Color', 'r', 'LineStyle', '-', 'LineWidth', 2);
    ylabel('Voltage (V)', 'FontSize', 10); % 폰트 크기 축소

    xlabel('Time (s)', 'FontSize', 10); % 폰트 크기 축소
    title(['Scenario ', num2str(AS1_1per_new(s).SN)], 'FontSize', 12);
    legend('Current', 'Voltage', 'Location', 'best', 'FontSize', 8); % 레전드 축소
    hold off;

    % ----- (b), (c), (d), (e)를 subplot 밖에 표시 -----
    pos = get(ax, 'Position');
    x_anno = pos(1) - 0.06;             % 더 왼쪽으로 이동
    y_anno = pos(2) + pos(4) + 0.01;    % 더 위로 이동
    annotation('textbox', [x_anno, y_anno, 0.03, 0.03], ...
               'String', labels_for_subplots{idx}, ...
               'Units', 'normalized', ...
               'FontSize', 12, ...
               'FontWeight', 'bold', ...
               'EdgeColor', 'none');  % 테두리 없음
end

%% SVG / FIG 저장
saveas(f, 'Figure_Code1_smaller.svg');   % 벡터 포맷 (논문용)
savefig(f, 'Figure_Code1_smaller.fig');  % MATLAB .fig (편집용)

