clc; clear; close all;

%% (1) Load Data
file_path = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\SD_lambda\';
mat_files = dir(fullfile(file_path, '*.mat'));
for file = mat_files'
    load(fullfile(file_path, file.name));
end

%% 시나리오 1만 단일 subplot으로 그림
s = 1;  % 시나리오 번호
notation_label = '(c)';

f = figure('Name','AS1_1per & AS2_1per - Scenario 1',...
           'NumberTitle','off',...
           'Units','normalized',...
           'Position',[0.35 0.35 0.3 0.3]);

% 원하는 색상 정의
%  - Current는 파랑('b')으로 직접 지정
%  - Unimodal(빨강), Bimodal(다른색: 여기서는 녹색 예시)
p_colors = [1 0 0; 0 0.5 0]; 

% Subplot(1,1,1) 형태로 하나만 만듦
ax = subplot(1,1,1);

%% 왼쪽 축: Current (파랑 실선)
yyaxis left
plot(AS1_1per_new(s).t, AS1_1per_new(s).I, ...
     'Color','b', 'LineStyle','-', 'LineWidth',2);
ylabel('Current (A)','FontSize',10);  
hold on;

% 왼쪽 축 색상 검정으로 설정
set(ax, 'YColor','k');

%% 오른쪽 축: Unimodal(AS1) + Bimodal(AS2) Voltage
yyaxis right
% Unimodal Voltage (빨강)
plot(AS1_1per_new(s).t, AS1_1per_new(s).V, ...
     'Color',p_colors(1,:), 'LineStyle','-', 'LineWidth',2);
hold on;
% Bimodal Voltage (녹색)
plot(AS2_1per_new(s).t, AS2_1per_new(s).V, ...
     'Color',p_colors(2,:), 'LineStyle','-', 'LineWidth',2);

ylabel('Voltage (V)','FontSize',10);
xlabel('Time (s)','FontSize',10);

% 오른쪽 축 색상 검정으로 설정
set(ax, 'YColor','k');

% X축 색상, 박스 테두리 검정
set(ax, 'XColor','k', 'Box','on');

% 제목(시나리오 번호) 폰트 크기 조정
title(['Scenario ', num2str(AS1_1per_new(s).SN)], 'FontSize',10);

% 범례
legend({'Current','Unimodal Voltage','Bimodal Voltage'}, ...
       'Location','best','FontSize',8);

hold off;

%% (c) notation을 subplot 밖에 표시
pos = get(ax, 'Position');
x_anno = pos(1) - 0.08;           % 더 왼쪽으로 이동
y_anno = pos(2) + pos(4) + 0.01;  % 더 위로 이동
annotation('textbox',[x_anno, y_anno, 0.03, 0.03],...
           'String', notation_label,...
           'Units','normalized',...
           'FontSize',12,...
           'FontWeight','bold',...
           'EdgeColor','none');  % 테두리 없음

